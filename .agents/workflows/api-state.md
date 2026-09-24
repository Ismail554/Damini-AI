---
description: Workflow 2 — Two-Tier State Strategy & Workflow 6 — Performance: Prefetch, Cache, Notify, Refresh
---

Goal: stop treating every state update the same way. A screen title, a balance figure, or a "3 new updates" badge should update in place. A project card, a list, an investor's portfolio — those need the full loading → data → error/empty cycle.

2.1 Tier A — Text-only updates

If a value is a single piece of text (or a small primitive: a count, a toggle, a badge) and its absence isn't a "the feature is broken" situation, don't route it through shimmer/error machinery. Expose it as a plain field on the existing provider and rebuild only the Text widget that shows it.

dart
class ProjectDetailProvider extends ChangeNotifier {
  String _statusLabel = 'Pending';
  String get statusLabel => _statusLabel;

  void updateStatusLabel(String value) {
    if (_statusLabel == value) return;
    _statusLabel = value;
    notifyListeners();
  }
}

In the UI, scope the rebuild so this doesn't repaint the whole screen:

dart
Selector<ProjectDetailProvider, String>(
  selector: (_, p) => p.statusLabel,
  builder: (_, statusLabel, __) => Text(statusLabel),
)

No shimmer, no error card, no empty state — if the text genuinely can't be fetched yet, show a short placeholder ('—') rather than building a whole skeleton for one line.

Use Tier A for: field labels, counters, timestamps ("Last updated 3m ago"), toggle states, single balances, form-field echoes.

2.2 Tier B — Card / list / project data

Anything that represents a record — a project card, a sponsor's list of campaigns, an investor's portfolio, a detail screen for one project — always carries all three states.

dart
enum ViewStatus { initial, loading, refreshing, data, empty, error }

class ListState<T> {
  const ListState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.message = '',
  });

  final ViewStatus status;
  final List<T> items;
  final String message;

  ListState<T> copyWith({
    ViewStatus? status,
    List<T>? items,
    String? message,
  }) {
    return ListState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }
}

Provider contract — every list/card provider exposes the same three intent methods, so screens are predictable to write:

dart
class SponsorProjectsProvider extends ChangeNotifier {
  SponsorProjectsProvider(this._repository);
  final ProjectRepository _repository;

  ListState<Project> _state = const ListState();
  ListState<Project> get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(status: ViewStatus.loading);
    notifyListeners();

    final result = await _repository.getSponsorProjects();

    result.when(
      success: (projects) {
        _state = projects.isEmpty
            ? _state.copyWith(status: ViewStatus.empty, items: [])
            : _state.copyWith(status: ViewStatus.data, items: projects);
      },
      failure: (message) {
        _state = _state.copyWith(status: ViewStatus.error, message: message);
      },
    );
    notifyListeners();
  }

  Future<void> refresh() async {
    _state = _state.copyWith(status: ViewStatus.refreshing);
    notifyListeners();
    await load();
  }
}

Screen-side, the three states map to three widgets and nothing else is allowed to leak between them:

dart
Widget build(BuildContext context) {
  final state = context.watch<SponsorProjectsProvider>().state;

  return switch (state.status) {
    ViewStatus.initial || ViewStatus.loading => const ProjectCardShimmerList(),
    ViewStatus.error => AppErrorView(
        message: state.message,
        onRetry: () => context.read<SponsorProjectsProvider>().load(),
      ),
    ViewStatus.empty => const AppEmptyView(message: 'No projects yet'),
    ViewStatus.data ||
    ViewStatus.refreshing =>
      ProjectCardList(projects: state.items),
  };
}

Note refreshing still renders ProjectCardList — see Workflow 6 for why (pull-to-refresh must never blank out existing data).

2.3 The deciding question

When you're not sure which tier something belongs in, ask: "If this fails to load, does the user lose context, or just miss a detail?"

Loses context (can't see their projects, their portfolio, their bids) → Tier B.
Misses a detail (a stale counter, an unlabeled status) → Tier A.
Goal: the app should feel instant for data it's already seen, and never block on data it can fetch ahead of time.

6.1 Prefetching on entry points

Kick off likely-next-screen requests in parallel with the current screen's own load, instead of waiting for navigation to trigger them:

dart
Future<void> initializeSession() async {
  // Splash / post-login — fire together, don't await sequentially
  await Future.wait([
    context.read<SessionProvider>().loadProfile(),
    context.read<NotificationsProvider>().loadUnreadCount(), // Tier A badge
    role == UserRole.sponsor
        ? context.read<SponsorProjectsProvider>().load()
        : context.read<InvestorOpportunitiesProvider>().load(),
  ]);
}

Sequential awaits here would mean each request waits for the previous one to fully round-trip before starting — Future.wait runs them concurrently, so total wait time is bounded by the slowest single call, not the sum of all of them.

6.2 Caching

Two tiers, matching how long the data stays useful:

In-memory (session-lived) — a simple map on a singleton cache service, cleared on logout. Good for lists that don't change often within a session (categories, static config).
Persistent (survives app restart) — Hive or a wrapped SharedPreferences, for things like the last-loaded project list, so a cold start can render immediately from cache while a fresh fetch runs behind it.
dart
class CacheService {
  CacheService._();
  static final instance = CacheService._();

  final Map<String, ({dynamic data, DateTime storedAt})> _memory = {};

  T? read<T>(String key, {Duration maxAge = const Duration(minutes: 5)}) {
    final entry = _memory[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.storedAt) > maxAge) return null;
    return entry.data as T;
  }

  void write(String key, dynamic data) {
    _memory[key] = (data: data, storedAt: DateTime.now());
  }

  void clear() => _memory.clear();
}

Stale-while-revalidate pattern in the provider — show cached data immediately, then quietly replace it once the fresh response lands:

dart
Future<void> load() async {
  final cached = CacheService.instance.read<List<Project>>('sponsor_projects');
  if (cached != null) {
    _state = _state.copyWith(status: ViewStatus.data, items: cached);
    notifyListeners(); // instant paint from cache
  } else {
    _state = _state.copyWith(status: ViewStatus.loading);
    notifyListeners();
  }

  final result = await _repository.getSponsorProjects();
  result.when(
    success: (projects) {
      CacheService.instance.write('sponsor_projects', projects);
      _state = _state.copyWith(status: ViewStatus.data, items: projects);
    },
    failure: (message) {
      if (cached == null) {
        _state = _state.copyWith(status: ViewStatus.error, message: message);
      }
      // if cached data is already showing, a failed background refresh
      // shouldn't rip it away — fail silently or show a small toast instead
    },
  );
  notifyListeners();
}
6.3 Cross-screen data-update notifier

When a Sponsor creates a project, the Investor-side opportunities list (possibly already loaded, possibly cached) needs to know it's stale — even though these live in different feature folders. A lightweight broadcast notifier avoids tightly coupling providers to each other:

dart
enum DataTopic { projects, portfolio, notifications }

class DataUpdateNotifier {
  DataUpdateNotifier._();
  static final instance = DataUpdateNotifier._();

  final _controller = StreamController<DataTopic>.broadcast();
  Stream<DataTopic> get stream => _controller.stream;

  void notify(DataTopic topic) => _controller.add(topic);
}

Providers that care about a topic subscribe once, in their constructor:

dart
class InvestorOpportunitiesProvider extends ChangeNotifier {
  InvestorOpportunitiesProvider(this._repository) {
    _sub = DataUpdateNotifier.instance.stream
        .where((topic) => topic == DataTopic.projects)
        .listen((_) => refresh());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

And the Sponsor's create-project flow fires it on success:

dart
CacheService.instance.clear(); // or scope to the 'projects' key
DataUpdateNotifier.instance.notify(DataTopic.projects);

This keeps the two role features decoupled — neither imports the other's provider — while still staying in sync.

6.4 Pull-to-refresh

Already reflected in the refreshing status in Workflow 2 — the contract is:

Old data stays visible during the refresh (no flash-to-shimmer).
Reset paging to page one.
Replace data only on a successful response.
On failure, keep showing the old data; don't demote a working screen to an error state just because a background refresh failed.
dart
RefreshIndicator(
  onRefresh: () => context.read<SponsorProjectsProvider>().refresh(),
  child: ProjectCardList(projects: state.items),
)
6.5 Debounce for search/filter inputs

Any text field that triggers a network call on every keystroke needs a debounce — 300–400ms is a reasonable default:

dart
Timer? _debounce;

void onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 350), () {
    context.read<SearchProvider>().search(query);
  });
}