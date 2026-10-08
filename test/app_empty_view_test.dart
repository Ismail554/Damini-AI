import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/core/widgets/app_state_widgets.dart';

Widget _buildTestableWidget(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppEmptyView Tests', () {
    testWidgets('renders basic AppEmptyView with title and subtitle', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          const AppEmptyView(
            title: 'No Data Here',
            subtitle: 'Please check back later.',
            icon: Icons.info_outline,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Data Here'), findsOneWidget);
      expect(find.text('Please check back later.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('renders AppEmptyView.saved with action button', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.saved(
            title: 'No Saved Projects',
            subtitle: 'You have not saved any projects yet.',
            actionLabel: 'Discover Deals',
            onAction: () {
              actionTriggered = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Saved Projects'), findsOneWidget);
      expect(find.text('You have not saved any projects yet.'), findsOneWidget);
      expect(find.text('Discover Deals'), findsOneWidget);

      await tester.tap(find.text('Discover Deals'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('renders AppEmptyView.search with clear query action', (tester) async {
      bool clearTriggered = false;

      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.search(
            query: 'AI Quantum',
            onClear: () {
              clearTriggered = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Results Found'), findsOneWidget);
      expect(find.textContaining('AI Quantum'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);

      await tester.tap(find.text('Clear Search'));
      expect(clearTriggered, isTrue);
    });

    testWidgets('renders AppEmptyView.investments preset', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.investments(
            title: 'No Investments Found',
            actionLabel: 'Explore Deals',
            onAction: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Investments Found'), findsOneWidget);
      expect(find.text('Explore Deals'), findsOneWidget);
    });

    testWidgets('renders AppEmptyView.messages preset', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.messages(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Messages Yet'), findsOneWidget);
    });

    testWidgets('renders AppEmptyView.projects preset', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.projects(
            title: 'No Projects Found',
            actionLabel: 'Create Project',
            onAction: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Projects Found'), findsOneWidget);
      expect(find.text('Create Project'), findsOneWidget);
    });

    testWidgets('renders AppEmptyView.requests preset', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.requests(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Collaboration Requests'), findsOneWidget);
    });

    testWidgets('renders AppEmptyView.nullState preset', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          AppEmptyView.nullState(
            title: 'Nothing Selected',
            subtitle: 'Choose an item from the list.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing Selected'), findsOneWidget);
      expect(find.text('Choose an item from the list.'), findsOneWidget);
      expect(find.byIcon(Icons.touch_app_outlined), findsOneWidget);
    });

    testWidgets('renders properly in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          const AppEmptyView(
            title: 'Dark Mode Empty State',
            subtitle: 'Testing theme adaptability.',
          ),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark Mode Empty State'), findsOneWidget);
    });
  });
}
