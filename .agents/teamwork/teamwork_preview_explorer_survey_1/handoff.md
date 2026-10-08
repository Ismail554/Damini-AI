# Data & API Layer Comprehensive Audit Report (R1 & R3)

**Author:** Survey Explorer 1 (Data & API Layer Auditor)  
**Date:** 2026-10-08  
**Audit Target:** Braintech Flutter Application (`d:\Ismail_flutter\julkar_vai`)  
**Scope:** `lib/data/`, `lib/core/services/`, `lib/core/constants/`, `lib/views/`, `lib/shared/`  

---

## 1. Observation

### 1.1 Direct Observations: Mock Data, Stubs & Simulated Delays

#### Observation 1.1.1: Orphaned Mock Data Layer in `lib/data/`
* **File Path:** `lib/data/repositories/opportunity_repository.dart`
  * **Lines 13–66:** `final List<OpportunityModel> _mockOpportunities = [ ... ];` defines 4 hardcoded static opportunities ("Lagos Mixed-Use Devel...", "Nairobi Fintech Seed Round", "Cocoa Farm Aggregator", "Greenhouse Tech Hub").
  * **Line 71:** `final isConnected = await ConnectivityService.isConnected();`
  * **Line 77:** `await Future.delayed(const Duration(milliseconds: 800));`
  * **Lines 80–87:** Simulates API response by reading/writing interest IDs to local `SharedPreferences`.
* **File Path:** `lib/data/services/opportunity_service.dart`
  * **Lines 4–24:** `class OpportunityService` wraps `OpportunityRepository`.
  * **Codebase Cross-Check:** Zero files in `lib/views/` or `lib/core/` import or instantiate `OpportunityRepository` or `OpportunityService`. It is orphaned test/prototype code.

#### Observation 1.1.2: Authentication Stub Repositories with `Future.delayed`
* **File Path:** `lib/views/auth/forgot_password/repositories/forgot_password_repository.dart`
  * **Lines 7–14:**
    ```dart
    class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
      @override
      Future<ForgotPasswordResponseModel> forgotPassword(ForgotPasswordRequestModel request) async {
        // Mock API delay (Ready for DioService.client.post)
        await Future.delayed(const Duration(seconds: 1));
        return const ForgotPasswordResponseModel(success: true);
      }
    }
    ```
    No endpoint is called; no endpoint constant exists in `lib/core/constants/api_endpoints.dart`.
* **File Path:** `lib/views/auth/reset_password/repositories/reset_password_repository.dart`
  * **Lines 7–14:**
    ```dart
    class ResetPasswordRepositoryImpl implements ResetPasswordRepository {
      @override
      Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
        // Mock API delay (Ready for DioService.client.post)
        await Future.delayed(const Duration(seconds: 1));
        return const ResetPasswordResponseModel(success: true);
      }
    }
    ```
    No endpoint is called; no endpoint constant exists in `lib/core/constants/api_endpoints.dart`.
* **File Path:** `lib/views/auth/change_password/repositories/change_password_repository.dart`
  * **Lines 6–13:**
    ```dart
    class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
      @override
      Future<bool> changePassword(ChangePasswordModel model) async {
        await Future.delayed(const Duration(milliseconds: 800));
        return true;
      }
    }
    ```
* **File Path:** `lib/views/auth/change_password/controllers/change_password_provider.dart`
  * **Lines 86–91:**
    ```dart
    Future<bool> changePassword() async {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(milliseconds: 1000));
      state = state.copyWith(isLoading: false);
      return true;
    }
    ```
    `ChangePasswordNotifier` does not even invoke `changePasswordRepositoryProvider`. It directly returns `true` after 1 second simulated delay.

#### Observation 1.1.3: Subscription Module Pure Mock
* **File Path:** `lib/views/subscription/controllers/subscription_provider.dart`
  * **Lines 14–42:** Hardcoded static list of 6 features:
    ```dart
    SubscriptionFeatureModel(title: "Basic search", isFree: true, isPro: true),
    SubscriptionFeatureModel(title: "Access to top AI models", isFree: false, isPro: true),
    SubscriptionFeatureModel(title: "Access to Computer", isFree: false, isPro: true),
    SubscriptionFeatureModel(title: "Access to deep research", isFree: false, isPro: true),
    SubscriptionFeatureModel(title: "Premium app connectors", isFree: false, isPro: true),
    SubscriptionFeatureModel(title: "More usage and memory", isFree: false, isPro: true),
    ```
  * **Lines 65–70:**
    ```dart
    Future<bool> subscribe() async {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(milliseconds: 1000));
      state = state.copyWith(isLoading: false);
      return true;
    }
    ```
    No repository, no payment SDK (Stripe/RevenueCat/In-App Purchases), and no backend API integration exists.

#### Observation 1.1.4: Home Unread Notification Count Stub
* **File Path:** `lib/views/home/repositories/home_repository.dart`
  * **Lines 5–10:**
    ```dart
    class HomeRepositoryImpl implements HomeRepository {
      @override
      Future<int> getUnreadNotificationCount() async {
        return 0;
      }
    }
    ```
  * **File Path:** `lib/views/home/controllers/home_provider.dart` lines 40–44 calls this stub. Unread notification badges on the home screen navbar are always hardcoded to 0.

#### Observation 1.1.5: Investor Dashboard Fallback Mocks
* **File Path:** `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart`
  * **Lines 94–100:** In `getCategories()`, if `ApiEndpoints.industries` throws or returns empty, silently catches and returns 5 hardcoded categories ("All", "Tech", "Real Estate", "Health", "Energy").
  * **Lines 169–200:** In `getBanners()`, if `ApiEndpoints.banners` fails or returns empty, catches and returns 3 hardcoded banners with Unsplash URLs ("Exclusive Tech Seed Rounds", "Prime Commercial Real Estate", "Clean Energy Infrastructure").
  * **Lines 248–285:** In `getFeaturedOpportunities()`, if `ApiEndpoints.projects` fails or returns empty, catches and returns 4 hardcoded featured deals ("Downtown Tech Hub", "AI Logistics Platform", "Cyber Security Infra", "Solar Grid Phase II") with Unsplash images.
  * **Lines 333–364:** In `getTrendingProjects()`, if `ApiEndpoints.projects` fails or returns empty, catches and returns 3 hardcoded trending deals ("BioTech Diagnostics Gene Test", "Urban Eco Apartments", "Decentralized GPU Compute Farm") with Unsplash images.

#### Observation 1.1.6: Investor Discover Deals Fallback Mock
* **File Path:** `lib/views/investor/discover/repositories/discover_repository.dart`
  * **Lines 54–60:** In `getCategories()`, falls back to 5 hardcoded strings ("All", "Real Estate", "Tech", "Health", "Energy").
  * **Lines 108–240:** In `getDiscoverDeals()`, if `ApiEndpoints.projects` fails or returns empty, catches and returns 8 hardcoded `DiscoverDealItem` objects (`deal_trending_1` to `deal_trending_3` and `deal_1` to `deal_5`) with Unsplash images and artificial dates.

#### Observation 1.1.7: Investor Investment History Fallback Mock
* **File Path:** `lib/views/investor/investment_history/repositories/investment_history_repository.dart`
  * **Lines 79–144:** In `getInvestmentHistory()`, calls `ApiEndpoints.investorInvestments`. If empty or throws, catches and returns hardcoded `InvestmentPortfolioSummary` (`totalInvested: "$560,000"`, `totalCurrentValue: "$644,200"`, `totalProfitLoss: "+$84,200 (+15.0%)"`, `activeDealsCount: 4`) and 4 hardcoded records (`inv_hist_1` to `inv_hist_4`).

#### Observation 1.1.8: Investor Saved Projects Fallback Mock
* **File Path:** `lib/views/investor/saved/repositories/investor_saved_repository.dart`
  * **Lines 67–120:** In `getSavedItems()`, calls `ApiEndpoints.savedProjects`. If empty or throws, catches and returns 4 hardcoded `InvestorSavedItemModel` items (`inv_saved_1` to `inv_saved_4`: "Downtown Tech Hub", "AI Logistics Platform", "EcoTech Solar Farm", "BioMed Research Lab") with Unsplash images.

#### Observation 1.1.9: Investor Chat Fallback Mock & Broken Group Chat Route
* **File Path:** `lib/views/investor/chat/repositories/investor_chat_repository.dart`
  * **Lines 61–90:** In `getChats()`, calls `ApiEndpoints.conversations`. If empty or throws, catches and returns 3 hardcoded `InvestorChatItemModel` items (`chat_1`: Acme Investments, `chat_2`: Downtown Tech Hub Syndicate, `chat_3`: Marcus Vance).
* **File Path:** `lib/views/investor/chat/screens/investor_chat_view.dart`
  * **Line 138:** `context.push('/group-chat', extra: chat.name);` passes only `chat.name` as `String`.
  * **Contrast with:** `lib/views/sponsor/chat/screens/sponsor_chat_view.dart:93–99`, which passes `{'title': chatItem.name, 'conversationId': int.tryParse(chatItem.id), 'projectId': chatItem.projectId}`.
  * In `lib/views/sponsor/group_chat/controllers/group_chat_provider.dart:154–160`, when `conversationId` and `projectId` are null, it sets `messages: const []` and `suggestions: const []`, displaying an empty dead-end screen.

#### Observation 1.1.10: Direct Chat Fallback Mock
* **File Path:** `lib/views/sponsor/chat/repositories/chat_repository.dart`
  * **Lines 107–162:** Synchronous mock `fetchChats()` returning 5 static contacts ("Ahmad Al-Rashid", "Downtown Tech Hub || Group Chat", "Marcus Webb", "Priya Mehta", "Venture Partners LLC").
  * **Lines 164–210:** Synchronous mock `fetchMessagesForChat(chatId)` returning 4 hardcoded messages for `'vp_1'` ("Hi there! I reviewed your proposal...", etc.).
* **File Path:** `lib/views/sponsor/chat/controllers/direct_chat_provider.dart`
  * **Lines 111–116 & 122–129:**
    ```dart
    if (fetched.isNotEmpty) {
      // map real messages
    } else {
      _loadFallback();
    }
    // ...
    void _loadFallback() {
      final fallback = _chatRepo.fetchMessagesForChat(chatItem.id);
      state = state.copyWith(messages: List.from(fallback), isLoading: false);
      _scrollToBottom();
    }
    ```
    If conversation has no messages or API fails, it injects fake messages into the live UI.

#### Observation 1.1.11: Group Chat Repository Stub
* **File Path:** `lib/views/sponsor/group_chat/repositories/group_chat_repository.dart`
  * **Lines 9–37:** `GroupChatRepositoryImpl` implements `fetchInitialMessages() => []`, `fetchSuggestions() => []`, and `sendMessage(text)` by creating an in-memory `GroupChatMessage` with timestamp ID.
  * Note: `GroupChatNotifier` in `group_chat_provider.dart:95` initializes `_fallbackRepo = GroupChatRepositoryImpl();` but never uses it.

#### Observation 1.1.12: Sponsor Project Details In-Memory Request Management & Mock Initialization
* **File Path:** `lib/views/sponsor/project_details/controllers/sponsor_project_details_provider.dart`
  * **Lines 20–26:** `build()` initializes state with:
    * `project: SponsorProjectDetailsModel.mockData()`
    * `pendingList: CollaborationRequestModel.mockPendingList()`
    * `approvedList: CollaborationRequestModel.mockHistoryList()`
    * `confirmationList: CollaborationRequestModel.mockConfirmationList()`
  * **Lines 61–86 (`approvePendingRequest`):** Purely in-memory list mutation. Does **not** call `CollaborationRequestsRepository.approveRequest()`.
  * **Lines 88–92 (`rejectPendingRequest`):** Purely in-memory list removal. Does **not** call `CollaborationRequestsRepository.rejectRequest()`.
  * **Lines 94–138 (`addContribution`):** Purely in-memory list insertion. Does **not** call `confirmInvestors()`.
  * **Lines 140–187 (`markFundReceived`):** Purely in-memory list mutation. Does **not** call `CollaborationRequestsRepository.fundReceivedRequest()`.
* **File Path:** `lib/views/sponsor/project_details/models/sponsor_project_details_model.dart`
  * **Lines 514–560:** `SponsorProjectDetailsModel.mockData()` defines "Downtown Tech Hub" ($1.00M raised, $5.00M goal, 20% progress, 3 investors).

#### Observation 1.1.13: Sponsor NDA Submission Stub & Fallback
* **File Path:** `lib/views/sponsor/nda/repositories/nda_repository.dart`
  * **Lines 42–45:** `fetchSponsorNda()` falls back to `NdaAgreementModel.mockData(disclosingParty)` on error.
  * **Lines 105–111:**
    ```dart
    Future<bool> submitSignature({
      required String ndaId,
      required String signatureText,
      String? signatureImagePath,
    }) async {
      return true;
    }
    ```
    Synchronously returns `true` without making any HTTP request.
* **File Path:** `lib/views/sponsor/nda/models/nda_model.dart`
  * **Lines 98–111:** `NdaAgreementModel.mockData()` hardcodes "NDA_Standard_Terms.pdf" with external dummy URL `https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf`.

#### Observation 1.1.14: Public Project View Fallback Mock
* **File Path:** `lib/views/sponsor/public_view/repositories/project_public_repository.dart`
  * **Lines 60–94:** `fetchProjectPublicDetails([String? id])`: If `id == null`, or starts with `pub_` or `draft_`, or if API call fails, returns `ProjectPublicViewModel.mockData()`.
* **File Path:** `lib/views/sponsor/public_view/models/project_public_view_model.dart`
  * **Lines 128–184:** `ProjectPublicViewModel.mockData()` defines hardcoded "Downtown Tech Hub" (`id: "pub_1"`).
* **File Path:** `lib/views/sponsor/public_view/screens/project_public_view.dart`
  * **Lines 61–63:** Falls back to `ProjectPublicViewModel.mockData()` if no project or ID is passed.
  * **Lines 68–72:** Ignores API fetch if `targetId.startsWith('pub_') || targetId.startsWith('draft_')`.

#### Observation 1.1.15: Synthetic Deal Card -> Public View Mapping with Injected Mock Team
Four separate deal card widgets synthesize `ProjectPublicViewModel` on tap instead of passing real project data:
1. `lib/views/investor/discover/screens/discover_screen.dart` (lines 375–396): Synthesizes `ProjectPublicViewModel` with `sponsorName: "Acme Investments"`, `timeline: "24 Months"`, `teamMembers: ProjectPublicViewModel.mockData().teamMembers`.
2. `lib/views/investor/dashboard/widgets/featured_opportunity_card.dart` (lines 37–60): Synthesizes `ProjectPublicViewModel` with `sponsorName: "Acme Corp"`, `teamMembers: ProjectPublicViewModel.mockData().teamMembers`.
3. `lib/views/investor/saved/widgets/investor_saved_project_card.dart` (lines 58–84): Synthesizes `ProjectPublicViewModel` with `teamMembers: ProjectPublicViewModel.mockData().teamMembers`.
4. `lib/views/sponsor/saved/widgets/sponsor_saved_project_card.dart` (lines 29–57): Synthesizes `ProjectPublicViewModel` with `teamMembers: ProjectPublicViewModel.mockData().teamMembers`.

#### Observation 1.1.16: Request Collaboration Mock Fallback
* **File Path:** `lib/views/investor/request_collaboration/screens/request_collaboration_screen.dart`
  * **Line 36:** `_project = widget.project ?? ProjectPublicViewModel.mockData();`
  * If navigated to `/request-collaboration` without extra parameter, submits proposal with `projectId: "pub_1"` (lines 55–61), triggering backend 404.

#### Observation 1.1.17: Notification Provider Fallback Mock
* **File Path:** `lib/shared/screens/notifications/controllers/notification_provider.dart`
  * **Lines 39–42:** `build()` returns initial state with `NotificationModel.mockNotifications()`.
  * **Lines 50–60:** In `_loadNotifications()`, if `list.isEmpty` OR if an exception is caught, sets `state = state.copyWith(notifications: NotificationModel.mockNotifications())`.
* **File Path:** `lib/shared/screens/notifications/models/notification_model.dart`
  * **Lines 81–116:** `mockNotifications()` returns 4 hardcoded notifications (`notif_1` to `notif_4`).

#### Observation 1.1.18: Interests Screen Hardcoded Fallback
* **File Path:** `lib/shared/screens/interests_screen.dart`
  * **Lines 29–36:** `_fallbackIndustries`: 6 hardcoded industry maps with static IDs 1 through 6. If `industriesProvider` errors or returns empty (lines 86, 95), it renders these fallback items.

#### Observation 1.1.19: Create Project Image Picker Mock Fallback
* **File Path:** `lib/views/sponsor/create_project/widgets/additional_images_section.dart`
  * **Lines 50–55:**
    ```dart
    // Mock fallback image if picking unavailable or cancelled on platform
    setState(() {
      if (_images.length < 10) {
        _images.add('assets/images/onboarding${(_images.length % 3) + 1}.png');
      }
    });
    ```
    If file picking fails or is cancelled, inserts mock asset images.

---

### 1.2 Direct Observations: ApiService, Network Layer & Robustness

#### Observation 1.2.1: SSL Certificate Validation Bypassed
* **File Path:** `lib/core/services/dio_service.dart`
  * **Line 38:** `client.badCertificateCallback = (cert, host, port) => true;`
  * Configured in `_configureHttpClient(Dio dio)` on non-web platforms. Disables TLS certificate validation for all network requests.

#### Observation 1.2.2: Hardcoded Ngrok Tunnel & Dev Header
* **File Path:** `lib/core/constants/api_endpoints.dart`
  * **Line 11:** `return "https://clubby-andy-irksomely.ngrok-free.dev";` (default fallback when `BASE_URL` in `.env` is absent or uninitialized).
* **File Path:** `lib/core/services/dio_service.dart`
  * **Line 25 & 47:** `options.headers['ngrok-skip-browser-warning'] = '69420';` added in `BaseOptions` and `_ngrokInterceptor`.
* **File Path:** `lib/core/services/auth_interceptor.dart`
  * **Line 25 & 47:** Same ngrok header hardcoded in `_refreshDio` options and `onRequest`.

#### Observation 1.2.3: `ApiErrorHandler` Exception Hierarchy Disconnect
* **File Path:** `lib/core/services/api_error_handler.dart`
  * **Lines 4–39:** Defines sealed `AppException` with subtypes `NetworkException`, `TimeoutException`, `UnauthorizedException`, `ForbiddenException`, `ServerException`, `ParsingException`, `ValidationException`.
  * **Lines 51–146:** In `ApiErrorHandler.handle(dynamic error)`, every `DioExceptionType` case (`connectionTimeout`, `sendTimeout`, `receiveTimeout`, `badResponse`, `cancel`, `connectionError`, `badCertificate`, `unknown`) explicitly instantiates and returns `ApiException`.
  * **Result:** None of `NetworkException`, `TimeoutException`, `UnauthorizedException`, `ForbiddenException`, `ServerException`, or `ParsingException` are ever thrown by the error handler.

#### Observation 1.2.4: Token Refresh Architecture & Side-Effects
* **File Path:** `lib/core/services/auth_interceptor.dart`
  * **Lines 37, 89–97:** Implements concurrency lock via `Completer<bool>? _refreshCompleter` to prevent duplicate refresh calls.
  * **Lines 133–165:** `_refreshToken()` posts `{'refresh': refreshToken}` to `ApiEndpoints.refreshToken`. Successfully extracts tokens across multiple formats (`data.access`, `token`, `accessToken`).
  * **Lines 114–120:** If token refresh fails, it clears storage (`StorageService.clearAll()`) and invokes `AppRouter.router.go('/login')`.
  * **Side-Effect Risk:** If a background request (e.g., token check, notification registration) triggers a 401 when the app is in public/onboarding mode, it abruptly forces redirection to `/login`.

#### Observation 1.2.5: Near-Total Absence of Connectivity Checks
* **File Path:** `lib/core/services/connectivity_service.dart`
  * **Lines 3–8:** `class ConnectivityService { static Future<bool> isConnected() async ... }` wraps `connectivity_plus`.
* **Codebase Cross-Check (`grep_search`):**
  * `ConnectivityService.isConnected()` is called in exactly **one** file: `lib/data/repositories/opportunity_repository.dart:71`, which is an orphaned, unused prototype file.
  * No active repository, controller, or view checks connectivity prior to network requests.

#### Observation 1.2.6: Profile PATCH Data Truncation
* **File Path:** `lib/views/profile/personal_info/repositories/personal_info_repository.dart`
  * **Lines 68–84:**
    ```dart
    final response = await _apiService.patch(
      ApiEndpoints.currentUser,
      data: {
        'first_name': profile.fullName.split(' ').first,
        'last_name': profile.fullName.split(' ').length > 1
            ? profile.fullName.split(' ').sublist(1).join(' ')
            : '',
      },
      requireAuth: true,
    );
    ```
    The model has `phone`, `country`, `location`, `companyName`, `position`, `website`, `bio`, but `updateProfile()` only sends `first_name` and `last_name`, discarding all other 7 fields.

---

## 2. Logic Chain

```
[Observation 1.1.1: lib/data/ is completely unlinked from lib/views/]
  ──> Step 1: The architecture was refactored into feature-first views, leaving lib/data/ as dead code with simulated delays.
  
[Observations 1.1.2, 1.1.3, 1.1.4: Auth & Subscription repositories use Future.delayed or static returns]
  ──> Step 2: Forgot Password, Reset Password, Change Password, and Subscription were designed as frontend prototypes without corresponding backend API integrations.
  
[Observations 1.1.5, 1.1.6, 1.1.7, 1.1.8, 1.1.9: Repositories catch all errors and return hardcoded lists]
  ──> Step 3: To prevent app crashes during backend development or ngrok downtime, repositories wrapped API calls in generic `catch (_) {}` blocks and populated screens with realistic fallback mock data.
  
[Observations 1.2.3 & 1.2.5: ApiErrorHandler returns only ApiException, ConnectivityService is unused]
  ──> Step 4: Because fallback mocks silently swallow errors, robust error handling and connectivity checking were bypassed in the presentation layer. Offline users see fictional mock data instead of connectivity errors.
  
[Observation 1.1.12: sponsor_project_details_provider mutates lists in memory]
  ──> Step 5: Sponsor collaboration requests and fund confirmations exist in UI and in CollaborationRequestsRepository, but the state controller was never wired to the repository, leaving the feature operating as an in-memory mock.
  
[Observations 1.2.1 & 1.2.2: Bad certificate callback = true, hardcoded ngrok tunnel URL and headers]
  ──> Step 6: The network layer contains critical development shortcuts that compromise TLS security and couple the application to a temporary ngrok tunnel rather than a configurable production environment.
```

---

## 3. Comprehensive Mock & Static Data Classification (R1 Deliverable)

| # | Exact File Path | Line Range | Variable / Function Name | Classification | Rationale |
|---|---|---|---|---|---|
| 1 | `lib/data/repositories/opportunity_repository.dart` | 13–66, 77 | `_mockOpportunities`, `getOpportunities()` | **Stub Service/Repository** | Orphaned mock list with `Future.delayed(800ms)` and SharedPreferences persistence. |
| 2 | `lib/views/auth/forgot_password/repositories/forgot_password_repository.dart` | 7–14 | `forgotPassword()` | **Stub Service/Repository** | Simulates API with `Future.delayed(1s)`, returns static `ForgotPasswordResponseModel(success: true)`. No backend call. |
| 3 | `lib/views/auth/reset_password/repositories/reset_password_repository.dart` | 7–14 | `resetPassword()` | **Stub Service/Repository** | Simulates API with `Future.delayed(1s)`, returns static `ResetPasswordResponseModel(success: true)`. No backend call. |
| 4 | `lib/views/auth/change_password/repositories/change_password_repository.dart` | 6–13 | `changePassword()` | **Stub Service/Repository** | Returns `true` after `Future.delayed(800ms)`. No backend call. |
| 5 | `lib/views/auth/change_password/controllers/change_password_provider.dart` | 86–91 | `changePassword()` | **Pure Mock** | Controller bypasses repository entirely, executes `Future.delayed(1000ms)` and returns `true`. |
| 6 | `lib/views/subscription/controllers/subscription_provider.dart` | 14–42, 65–70 | `features`, `subscribe()` | **Pure Mock** | 6 hardcoded feature models; `subscribe()` executes `Future.delayed(1000ms)`. No repository or payment backend. |
| 7 | `lib/views/home/repositories/home_repository.dart` | 5–10 | `getUnreadNotificationCount()` | **Pure Mock** | Returns hardcoded integer `0`. No API endpoint called. |
| 8 | `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart` | 94–100 | `getCategories()` | **Fallback Mock** | Calls `/api/v1/profiles/industries/`; on error/empty falls back to 5 hardcoded category chips. |
| 9 | `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart` | 169–200 | `getBanners()` | **Fallback Mock** | Calls `/api/v1/banners/?role=investor`; on error/empty falls back to 3 hardcoded banners with Unsplash images. |
| 10 | `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart` | 248–285 | `getFeaturedOpportunities()` | **Fallback Mock** | Calls `/api/v1/projects/`; on error/empty falls back to 4 hardcoded featured deals with Unsplash images. |
| 11 | `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart` | 333–364 | `getTrendingProjects()` | **Fallback Mock** | Calls `/api/v1/projects/`; on error/empty falls back to 3 hardcoded trending deals with Unsplash images. |
| 12 | `lib/views/investor/discover/repositories/discover_repository.dart` | 54–60 | `getCategories()` | **Fallback Mock** | Calls `/api/v1/profiles/industries/`; on error/empty falls back to 5 hardcoded category strings. |
| 13 | `lib/views/investor/discover/repositories/discover_repository.dart` | 108–240 | `getDiscoverDeals()` | **Fallback Mock** | Calls `/api/v1/projects/`; on error/empty falls back to 8 hardcoded `DiscoverDealItem` objects. |
| 14 | `lib/views/investor/investment_history/repositories/investment_history_repository.dart` | 79–144 | `getInvestmentHistory()` | **Fallback Mock** | Calls `/api/v1/investor/investments/`; on error/empty falls back to hardcoded summary & 4 mock records. |
| 15 | `lib/views/investor/saved/repositories/investor_saved_repository.dart` | 67–120 | `getSavedItems()` | **Fallback Mock** | Calls `/api/v1/projects/saved/`; on error/empty falls back to 4 hardcoded saved items (`inv_saved_1`–`4`). |
| 16 | `lib/views/investor/chat/repositories/investor_chat_repository.dart` | 61–90 | `getChats()` | **Fallback Mock** | Calls `/api/v1/notifications/chat/conversations/`; on error/empty falls back to 3 hardcoded chat items. |
| 17 | `lib/views/sponsor/chat/repositories/chat_repository.dart` | 107–162, 164–210 | `fetchChats()`, `fetchMessagesForChat()` | **Pure Mock** | Synchronously returns 5 mock contacts and 4 mock messages for conversation `'vp_1'`. |
| 18 | `lib/views/sponsor/chat/controllers/direct_chat_provider.dart` | 111–116, 122–129 | `_loadFallback()` | **Fallback Mock** | If API message fetch returns empty or throws, injects static messages from `fetchMessagesForChat()`. |
| 19 | `lib/views/sponsor/group_chat/repositories/group_chat_repository.dart` | 9–37 | `GroupChatRepositoryImpl` | **Stub Service/Repository** | Empty stub returning `[]` and synthesized local messages. Unused by active provider. |
| 20 | `lib/views/sponsor/project_details/controllers/sponsor_project_details_provider.dart` | 20–26 | `build()` initial state | **Pure Mock** | Initializes state with `SponsorProjectDetailsModel.mockData()` and 3 mock collaboration lists. |
| 21 | `lib/views/sponsor/project_details/controllers/sponsor_project_details_provider.dart` | 61–187 | `approvePendingRequest()`, `rejectPendingRequest()`, `addContribution()`, `markFundReceived()` | **Pure Mock** | Request approval, rejection, and funding mark mutate local memory only; no API calls. |
| 22 | `lib/views/sponsor/project_details/models/sponsor_project_details_model.dart` | 514–560 | `mockData()` | **Pure Mock** | Static mock data for "Downtown Tech Hub" ($1M raised, $5M goal). |
| 23 | `lib/views/sponsor/all_projects/models/sponsor_project_model.dart` | 139–245 | `mockActiveList()`, `mockCompletedList()`, `mockTerminatedList()` | **Pure Mock** | 12 static project models in model file (orphaned mock helpers). |
| 24 | `lib/views/sponsor/saved/models/sponsor_saved_project_model.dart` | 218–267 | `mockList()` | **Pure Mock** | 3 static saved project models (orphaned mock helper). |
| 25 | `lib/views/sponsor/saved/models/sponsor_saved_profile_model.dart` | 206–252 | `mockList()` | **Pure Mock** | 4 static saved profile models (orphaned mock helper). |
| 26 | `lib/views/sponsor/nda/repositories/nda_repository.dart` | 42–45 | `fetchSponsorNda()` | **Fallback Mock** | On error, falls back to `NdaAgreementModel.mockData()`. |
| 27 | `lib/views/sponsor/nda/repositories/nda_repository.dart` | 105–111 | `submitSignature()` | **Stub Service/Repository** | Returns `true` synchronously without executing HTTP call. |
| 28 | `lib/views/sponsor/nda/models/nda_model.dart` | 98–111 | `mockData()` | **Pure Mock** | Hardcoded NDA terms with external dummy W3C sample PDF URL. |
| 29 | `lib/views/sponsor/public_view/repositories/project_public_repository.dart` | 60–94 | `fetchProjectPublicDetails()` | **Fallback Mock** | On null ID, prefix `pub_`/`draft_`, or error, returns `ProjectPublicViewModel.mockData()`. |
| 30 | `lib/views/sponsor/public_view/models/project_public_view_model.dart` | 128–184 | `mockData()` | **Pure Mock** | Hardcoded public project "Downtown Tech Hub" (`id: "pub_1"`). |
| 31 | `lib/views/investor/discover/screens/discover_screen.dart` | 375–396 | Deal item tap handler | **Pure Mock** | Synthesizes `ProjectPublicViewModel` on the fly with mock team members and dummy sponsor text. |
| 32 | `lib/views/investor/dashboard/widgets/featured_opportunity_card.dart` | 37–60 | Card tap handler | **Pure Mock** | Synthesizes `ProjectPublicViewModel` with mock team members and dummy sponsor text. |
| 33 | `lib/views/investor/saved/widgets/investor_saved_project_card.dart` | 58–84 | Card tap handler | **Pure Mock** | Synthesizes `ProjectPublicViewModel` with mock team members and dummy sponsor text. |
| 34 | `lib/views/sponsor/saved/widgets/sponsor_saved_project_card.dart` | 29–57 | Card tap handler | **Pure Mock** | Synthesizes `ProjectPublicViewModel` with mock team members. |
| 35 | `lib/views/investor/request_collaboration/screens/request_collaboration_screen.dart` | 36 | `_project` initialization | **Fallback Mock** | Falls back to `ProjectPublicViewModel.mockData()` (`id: "pub_1"`), submitting requests against invalid mock ID. |
| 36 | `lib/shared/screens/notifications/controllers/notification_provider.dart` | 39–42, 50–60 | `build()`, `_loadNotifications()` | **Fallback Mock** | Initial state and empty/error states inject `NotificationModel.mockNotifications()`. |
| 37 | `lib/shared/screens/notifications/models/notification_model.dart` | 81–116 | `mockNotifications()` | **Pure Mock** | 4 static notification models (`notif_1` to `notif_4`). |
| 38 | `lib/shared/screens/interests_screen.dart` | 29–36 | `_fallbackIndustries` | **Fallback Mock** | 6 hardcoded industry maps used when `industriesProvider` fails or returns empty. |
| 39 | `lib/views/sponsor/create_project/widgets/additional_images_section.dart` | 50–55 | Image picker catch block | **Fallback Mock** | Injects asset image paths (`onboarding1.png` etc.) if image picker throws or is cancelled. |

---

## 4. Backend Integration & API Robustness Audit (R3 Deliverable)

### 4.1 Error Handling Robustness
* **Issue:** `ApiErrorHandler` defines an expressive sealed hierarchy of `AppException` types (`NetworkException`, `TimeoutException`, `UnauthorizedException`, `ForbiddenException`, `ServerException`, `ParsingException`, `ValidationException`), but `ApiErrorHandler.handle()` **only ever instantiates `ApiException`**.
* **Impact:** Pattern-matching on specific exception types (e.g. `on NetworkException`) in repositories or UI controllers is non-functional because they are never thrown.
* **Silent Error Swallowing:** 8 distinct repositories (`InvestorDashboardRepositoryImpl`, `DiscoverRepositoryImpl`, `InvestmentHistoryRepositoryImpl`, `InvestorSavedRepositoryImpl`, `InvestorChatRepositoryImpl`, `NdaRepository`, `ProjectPublicRepository`, `NotificationNotifier`) wrap network calls in `try { ... } catch (_) {}` and return fallback mock lists. Errors are hidden from both the user and logging systems.

### 4.2 Token Expiration & Refresh Logic
* **Mechanism:** `AuthInterceptor` uses a dedicated `_refreshDio` instance and a `Completer<bool>` concurrency lock to ensure exactly 1 refresh call executes for concurrent 401s.
* **Header Injection:** `onRequest` attaches `Authorization: Bearer <token>` from `FlutterSecureStorage` if not explicitly opted out via `requiresAuth: false`.
* **Robustness Gap:** If a background 401 occurs when the user is logged out or browsing unauthenticated, `AuthInterceptor` triggers `AppRouter.router.go('/login')`, creating unexpected navigational disruption.
* **Storage Inconsistency:** JWT parsing in `StorageService.extractUserIdFromJwt` looks for `user_id`, `userId`, `id`, `sub`. If a token is malformed, it silently returns `null` without re-authenticating.

### 4.3 Network Security & Environment Configuration
* **Critical Security Risk:** `DioService.dart:38` sets `client.badCertificateCallback = (cert, host, port) => true;`. This completely disables TLS certificate validation and exposes all client communication to Man-in-the-Middle (MITM) attacks.
* **Tunnel Hardcoding:** `ApiEndpoints.baseUrl` defaults to `"https://clubby-andy-irksomely.ngrok-free.dev"` when `.env` is absent. `DioService` and `AuthInterceptor` inject `'ngrok-skip-browser-warning': '69420'` into every request.

### 4.4 Offline Resilience
* **Connectivity Checks:** `ConnectivityService.isConnected()` is completely omitted from production repositories.
* **Offline UI Experience:** When the device is offline, Dio triggers `DioExceptionType.connectionError`. In the Investor role screens, because repositories swallow errors and return fallback mocks, the user is presented with synthetic mock data rather than an offline banner, retry prompt, or cache indicator.

---

## 5. Comprehensive Missing Endpoints Catalog

For every unintegrated or mock-backed feature, the exact HTTP contract required from the backend is cataloged below.

---

### Endpoint 1: Home Unread Notification Count
* **Feature:** Home Dashboard Navigation Badge
* **Screen / View:** `lib/views/home/screens/home_view.dart` & `lib/views/home/repositories/home_repository.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/notifications/unread-count/`
* **Headers:** `Authorization: Bearer <token>`
* **Request Payload:** None (Query params optional: `?role=investor|sponsor`)
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "unread_count": 3
  }
}
```

---

### Endpoint 2: Forgot Password Request OTP
* **Feature:** Authentication — Password Recovery
* **Screen / View:** `lib/views/auth/forgot_password/screens/forgot_password_view.dart` & `lib/views/auth/forgot_password/repositories/forgot_password_repository.dart`
* **Method:** `POST`
* **URL Path:** `/api/v1/auth/forgot-password/`
* **Headers:** `Content-Type: application/json`
* **Request JSON Payload Schema:**
```json
{
  "email": "user@example.com"
}
```
* **Payload Fields:**
  * `email` (`string`, mandatory): Registered account email address.
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "message": "OTP verification code sent to user@example.com."
}
```

---

### Endpoint 3: Reset Password with OTP
* **Feature:** Authentication — Password Reset
* **Screen / View:** `lib/views/auth/reset_password/screens/reset_password_view.dart` & `lib/views/auth/reset_password/repositories/reset_password_repository.dart`
* **Method:** `POST`
* **URL Path:** `/api/v1/auth/reset-password/`
* **Headers:** `Content-Type: application/json`
* **Request JSON Payload Schema:**
```json
{
  "email": "user@example.com",
  "otp": "123456",
  "new_password": "NewSecurePassword123!",
  "confirm_password": "NewSecurePassword123!"
}
```
* **Payload Fields:**
  * `email` (`string`, mandatory): Email address.
  * `otp` (`string`, mandatory): 4 to 6 digit verification code.
  * `new_password` (`string`, mandatory): New password meeting security criteria.
  * `confirm_password` (`string`, mandatory): Confirmation password matching `new_password`.
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "message": "Password has been reset successfully. Please log in with your new credentials."
}
```

---

### Endpoint 4: In-App Change Password
* **Feature:** Account Security / Profile Settings
* **Screen / View:** `lib/views/auth/change_password/screens/change_password_view.dart` & `lib/views/auth/change_password/repositories/change_password_repository.dart`
* **Method:** `POST`
* **URL Path:** `/api/v1/auth/change-password/`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request JSON Payload Schema:**
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword456!",
  "confirm_password": "NewPassword456!"
}
```
* **Payload Fields:**
  * `current_password` (`string`, mandatory): User's current valid password.
  * `new_password` (`string`, mandatory): Desired new password.
  * `confirm_password` (`string`, mandatory): Confirmation matching `new_password`.
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "message": "Password updated successfully."
}
```

---

### Endpoint 5: Subscription Plans & Feature Matrix
* **Feature:** Subscription / Membership Upgrade
* **Screen / View:** `lib/views/subscription/subscription_view.dart` & `lib/views/subscription/controllers/subscription_provider.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/subscriptions/plans/`
* **Headers:** `Authorization: Bearer <token>`
* **Request Payload:** None
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "current_plan": "free",
    "plans": [
      {
        "id": "plan_free",
        "name": "Basic",
        "price_monthly": 0.00,
        "price_yearly": 0.00,
        "currency": "USD"
      },
      {
        "id": "plan_pro",
        "name": "Pro Investor / Sponsor",
        "price_monthly": 49.00,
        "price_yearly": 470.00,
        "currency": "USD"
      }
    ],
    "features": [
      {
        "title": "Basic search",
        "is_free": true,
        "is_pro": true
      },
      {
        "title": "Access to top AI models",
        "is_free": false,
        "is_pro": true
      },
      {
        "title": "Access to deep research",
        "is_free": false,
        "is_pro": true
      },
      {
        "title": "Direct syndication chat",
        "is_free": false,
        "is_pro": true
      }
    ]
  }
}
```

---

### Endpoint 6: Create Subscription Checkout / Purchase
* **Feature:** Subscription Activation
* **Screen / View:** `lib/views/subscription/subscription_view.dart` & `lib/views/subscription/controllers/subscription_provider.dart`
* **Method:** `POST`
* **URL Path:** `/api/v1/subscriptions/subscribe/`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request JSON Payload Schema:**
```json
{
  "plan_id": "plan_pro",
  "billing_cycle": "yearly",
  "payment_method_token": "pm_tok_123456789"
}
```
* **Payload Fields:**
  * `plan_id` (`string`, mandatory): Plan identifier.
  * `billing_cycle` (`string`, mandatory): `'monthly'` or `'yearly'`.
  * `payment_method_token` (`string`, optional): Token from payment provider.
* **Response JSON Schema (`200 OK` / `201 Created`):**
```json
{
  "status": "success",
  "message": "Subscription activated successfully.",
  "data": {
    "subscription_id": "sub_987654321",
    "status": "ACTIVE",
    "plan_id": "plan_pro",
    "current_period_end": "2027-10-08T00:00:00Z"
  }
}
```

---

### Endpoint 7: Investor Dashboard Featured Deals Feed
* **Feature:** Investor Dashboard
* **Screen / View:** `lib/views/investor/dashboard/screens/investor_dashboard.dart` & `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/projects/featured/`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:** `?category=Tech&limit=10`
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "count": 4,
  "results": [
    {
      "id": 12,
      "title": "Downtown Tech Hub",
      "location": "Austin, TX, United States",
      "category": "Real Estate",
      "cover_image_url": "https://cdn.example.com/projects/downtown.jpg",
      "target_raise": 5000000.00,
      "target_roi": "18.0%",
      "funded_percentage": 0.20,
      "minimum_investment": 50000.00
    }
  ]
}
```

---

### Endpoint 8: Investor Dashboard Trending Deals Feed
* **Feature:** Investor Dashboard
* **Screen / View:** `lib/views/investor/dashboard/screens/investor_dashboard.dart` & `lib/views/investor/dashboard/repositories/investor_dashboard_repository.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/projects/trending/`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:** `?limit=10`
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "count": 3,
  "results": [
    {
      "id": 15,
      "title": "BioTech Diagnostics Gene Test",
      "location": "Zurich, Switzerland",
      "category": "Health",
      "cover_image_url": "https://cdn.example.com/projects/biotech.jpg",
      "funded_percentage": 0.82,
      "minimum_investment": 10000.00,
      "days_left": 5,
      "target_roi": "26.0%"
    }
  ]
}
```

---

### Endpoint 9: Investor Discover Deals with Pagination & Sorting
* **Feature:** Deal Flow Discovery
* **Screen / View:** `lib/views/investor/discover/screens/discover_screen.dart` & `lib/views/investor/discover/repositories/discover_repository.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/projects/discover/`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:**
  * `category` (`string`, optional): e.g., `'Tech'`, `'Real Estate'`.
  * `ordering` (`string`, optional): e.g., `'-created_at'`, `'-target_roi'`, `'target_raise'`.
  * `search` (`string`, optional): Keyword search string.
  * `page` (`int`, optional, default 1).
  * `page_size` (`int`, optional, default 20).
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "count": 48,
  "next": "/api/v1/projects/discover/?page=2",
  "previous": null,
  "results": [
    {
      "id": 101,
      "title": "Decentralized GPU Compute Farm",
      "location": "Singapore",
      "category": "Tech",
      "cover_image_url": "https://cdn.example.com/projects/gpu.jpg",
      "target_raise": 4800000.00,
      "min_investment": 5000.00,
      "target_roi": "28.0%",
      "roi_value": 28.0,
      "raise_value": 4800000,
      "funded_percentage": 0.94,
      "days_left": 2,
      "is_trending": true,
      "created_at": "2026-10-07T12:00:00Z"
    }
  ]
}
```

---

### Endpoint 10: Investor Portfolio & Investment History
* **Feature:** Portfolio Tracking
* **Screen / View:** `lib/views/investor/investment_history/screens/investment_history_screen.dart` & `lib/views/investor/investment_history/repositories/investment_history_repository.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/investor/investments/`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:**
  * `status` (`string`, optional): `'All'`, `'Active'`, `'Completed'`, `'Pending'`.
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "summary": {
      "total_invested": "$560,000",
      "total_current_value": "$644,200",
      "total_profit_loss": "+$84,200 (+15.0%)",
      "active_deals_count": 4
    },
    "results": [
      {
        "id": "inv_rec_1",
        "project_id": 12,
        "title": "Downtown Tech Hub",
        "category": "Real Estate",
        "sponsor_name": "Acme Corp",
        "investment_date": "2026-03-14",
        "status": "Active",
        "invested_amount": 250000.00,
        "current_value": 288000.00,
        "roi_percentage": "+15.2%",
        "cover_image_url": "https://cdn.example.com/projects/downtown.jpg"
      }
    ]
  }
}
```

---

### Endpoint 11: Investor Chat Conversations List
* **Feature:** Messaging
* **Screen / View:** `lib/views/investor/chat/screens/investor_chat_view.dart` & `lib/views/investor/chat/repositories/investor_chat_repository.dart`
* **Method:** `GET`
* **URL Path:** `/api/v1/notifications/chat/conversations/`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:** `?role=investor`
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "results": [
    {
      "id": 42,
      "project_id": 12,
      "project_title": "Downtown Tech Hub",
      "target_user_id": 8,
      "target_user_name": "Marcus Vance",
      "target_user_role": "Sponsor",
      "last_message": "The term sheet has been uploaded to the data room.",
      "last_message_at": "2026-10-08T09:42:00Z",
      "unread_count": 2,
      "avatar_url": "https://cdn.example.com/avatars/marcus.jpg",
      "is_group_chat": true
    }
  ]
}
```

---

### Endpoint 12: Sponsor NDA Sign Submission
* **Feature:** Legal Compliance & NDA Management
* **Screen / View:** `lib/views/sponsor/nda/screens/nda_view.dart` & `lib/views/sponsor/nda/repositories/nda_repository.dart`
* **Method:** `POST`
* **URL Path:** `/api/v1/profiles/sponsor/nda/sign/`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Request JSON/Form Payload Schema:**
```json
{
  "signature_text": "Marcus Vance",
  "signature_image": "<Binary File (PNG/JPEG)>"
}
```
* **Payload Fields:**
  * `signature_text` (`string`, mandatory): Full legal signature string.
  * `signature_image` (`file`, optional): Image of drawn or uploaded handwritten signature.
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "message": "NDA signature recorded successfully.",
  "data": {
    "signed_at": "2026-10-08T12:00:00Z",
    "is_signed": true
  }
}
```

---

### Endpoint 13: Full User Profile Update (Personal Information)
* **Feature:** Profile Management
* **Screen / View:** `lib/views/profile/personal_info/screens/personal_info_view.dart` & `lib/views/profile/personal_info/repositories/personal_info_repository.dart`
* **Method:** `PATCH`
* **URL Path:** `/api/v1/users/me/`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`
* **Request JSON Payload Schema:**
```json
{
  "first_name": "Alex",
  "last_name": "Vance",
  "phone": "+1-555-019-2834",
  "country": "United States",
  "location": "Austin, Texas",
  "company_name": "Vance Capital",
  "position": "Managing Director",
  "website": "https://vancecap.com",
  "bio": "Private equity investor specializing in real estate and deep tech syndicates."
}
```
* **Payload Fields:**
  * `first_name` (`string`, optional)
  * `last_name` (`string`, optional)
  * `phone` (`string`, optional)
  * `country` (`string`, optional)
  * `location` (`string`, optional)
  * `company_name` (`string`, optional)
  * `position` (`string`, optional)
  * `website` (`string`, optional)
  * `bio` (`string`, optional)
* **Response JSON Schema (`200 OK`):**
```json
{
  "status": "success",
  "message": "Profile updated successfully.",
  "data": {
    "id": 14,
    "email": "alex@vancecap.com",
    "first_name": "Alex",
    "last_name": "Vance",
    "phone": "+1-555-019-2834",
    "country": "United States",
    "location": "Austin, Texas",
    "company_name": "Vance Capital",
    "position": "Managing Director",
    "website": "https://vancecap.com",
    "bio": "Private equity investor specializing in real estate and deep tech syndicates."
  }
}
```

---

## 6. Caveats

1. **Ngrok Tunnel Ephemerality:** All baseline API calls rely on `https://clubby-andy-irksomely.ngrok-free.dev`. If this tunnel is offline or expired, real endpoint calls will fail and cause fallback mocks to engage immediately.
2. **Backend Server-Side Code Uninspected:** This audit was strictly black-box/client-side static analysis of `d:\Ismail_flutter\julkar_vai`. Whether endpoints exist in the backend Django/Node project but were never connected on the client side cannot be confirmed without inspecting the backend repository.
3. **Web Platform Specifics:** Analysis of `IOHttpClientAdapter` was focused on mobile platforms (Android/iOS). The web build uses standard browser Fetch/XHR adapters which do not use `badCertificateCallback`.

---

## 7. Conclusion

The Braintech Flutter application possesses a sophisticated UI and modern architecture (Riverpod, ScreenUtil, GoRouter), but exhibits a high volume of **mock data remnants (39 cataloged occurrences)** across both the Investor and Sponsor roles.

### Summary of Critical Findings:
1. **Critical Mock Modules:**
   * **Subscription Module:** 100% mocked frontend UI with zero payment or API connectivity.
   * **Auth Password Recovery & Reset:** 3 stub repositories using artificial `Future.delayed` delays without real endpoints.
   * **Investor Experience:** 5 core screens (Dashboard Banners/Opportunities, Discover, Portfolio History, Saved Items, Chat) operate on **Fallback Mocks** that conceal API failures by rendering static mock data.
   * **Sponsor Project Management:** `SponsorProjectNotifier` manages collaboration approvals, rejections, and fund receipts entirely in local memory, bypassing existing API endpoints in `CollaborationRequestsRepository`.
2. **Critical Security Vulnerabilities:**
   * `DioService.dart:38` sets `badCertificateCallback = (cert, host, port) => true;`, disabling TLS certificate verification globally on native devices.
   * Hardcoded `ngrok` bypass headers and fallback URLs permeate `api_endpoints.dart`, `dio_service.dart`, and `auth_interceptor.dart`.
3. **Data Loss on Profile Update:**
   * `PersonalInfoRepositoryImpl.updateProfile()` silently truncates 7 out of 9 profile fields (`phone`, `country`, `location`, `company_name`, `position`, `website`, `bio`).

---

## 8. Verification Method

To independently verify the observations in this report, execute the following commands and code inspections:

### 8.1 Grep Verifications
```powershell
# Verify Future.delayed occurrences in repositories and controllers
git grep -n "Future.delayed" lib/

# Verify badCertificateCallback security bypass
git grep -n "badCertificateCallback" lib/

# Verify hardcoded ngrok headers and tunnel URLs
git grep -n "ngrok" lib/

# Verify fallback mock data invocations
git grep -n "mockData" lib/
git grep -n "mockNotifications" lib/
git grep -n "mockOpportunities" lib/

# Verify ConnectivityService usage isolation
git grep -n "ConnectivityService" lib/
```

### 8.2 Code Inspection Checkpoints
* Inspect `lib/core/services/dio_service.dart:38` for TLS bypass.
* Inspect `lib/views/subscription/controllers/subscription_provider.dart:65–70` for `Future.delayed(1000ms)` subscription stub.
* Inspect `lib/views/auth/forgot_password/repositories/forgot_password_repository.dart:10–13` for 1-second delay stub.
* Inspect `lib/views/sponsor/project_details/controllers/sponsor_project_details_provider.dart:61–187` for in-memory request state mutations.
* Inspect `lib/views/profile/personal_info/repositories/personal_info_repository.dart:68–84` for PATCH payload field truncation.
