import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Braintech/shared/screens/interests_screen.dart';
import 'package:Braintech/views/role_selection/models/onboarding_models.dart';
import 'package:Braintech/views/role_selection/provider/onboarding_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget({
    required Widget child,
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  testWidgets('InterestsScreen renders 17 static industries and toggles selection', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    List<int>? submittedIds;

    await tester.pumpWidget(
      createTestWidget(
        overrides: [
          industriesProvider.overrideWith((ref) async => []),
        ],
        child: InterestsScreen(
          role: 'sponsor',
          onNext: (ids) => submittedIds = ids,
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check title and subtitle
    expect(find.text('What industries interest you?'), findsOneWidget);
    expect(find.text("Pick as many as you like we'll tailor your feed."), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);

    // Initial counter
    expect(find.text('0 selected'), findsOneWidget);

    // Check static pills
    expect(find.text('Real Estate'), findsOneWidget);
    expect(find.text('Technology & AI'), findsOneWidget);
    expect(find.text('Fintech & Financial Services'), findsOneWidget);
    expect(find.text('Renewable Energy & Climate Tech'), findsOneWidget);

    // Tap 'Real Estate'
    await tester.ensureVisible(find.text('Real Estate'));
    await tester.tap(find.text('Real Estate'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    // Tap 'Technology & AI'
    await tester.ensureVisible(find.text('Technology & AI'));
    await tester.tap(find.text('Technology & AI'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    // Tap Finish & continue
    await tester.ensureVisible(find.text('Finish & continue'));
    await tester.tap(find.text('Finish & continue'));
    await tester.pumpAndSettle();

    expect(submittedIds, isNotNull);
    expect(submittedIds, containsAll([1, 3])); // Real Estate (id 1) and Technology & AI (id 3)
  });

  testWidgets('InterestsScreen merges API industries with static list', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    List<int>? submittedIds;

    await tester.pumpWidget(
      createTestWidget(
        overrides: [
          industriesProvider.overrideWith((ref) async => [
            const IndustryModel(id: 101, name: 'Real Estate'),
            const IndustryModel(id: 102, name: 'Technology'),
          ]),
        ],
        child: InterestsScreen(
          role: 'investor',
          onNext: (ids) => submittedIds = ids,
          onBack: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap 'Real Estate' (which should have merged id 101 from API)
    await tester.ensureVisible(find.text('Real Estate'));
    await tester.tap(find.text('Real Estate'));
    await tester.pumpAndSettle();

    // Tap 'Technology & AI' (which should match API 'Technology' with id 102)
    await tester.ensureVisible(find.text('Technology & AI'));
    await tester.tap(find.text('Technology & AI'));
    await tester.pumpAndSettle();

    // Finish & continue
    await tester.ensureVisible(find.text('Finish & continue'));
    await tester.tap(find.text('Finish & continue'));
    await tester.pumpAndSettle();

    expect(submittedIds, isNotNull);
    expect(submittedIds, containsAll([101, 102]));
  });
}
