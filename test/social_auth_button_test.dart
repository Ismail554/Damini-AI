import 'package:Braintech/core/theme/app_theme.dart';
import 'package:Braintech/views/auth/widgets/social_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestWidget(Widget child, {ThemeData? theme}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      theme: theme ?? AppTheme.darkTheme,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocialAuthButton Widget Tests', () {
    testWidgets('renders label and icon correctly with default constructor',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Continue with Google',
            icon: const Icon(Icons.g_mobiledata, key: Key('custom_icon')),
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byKey(const Key('custom_icon')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('triggers onPressed when tapped and not loading',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Test Button',
            icon: const Icon(Icons.star),
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays CircularProgressIndicator when isLoading is true',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Continue with Apple',
            icon: const Icon(Icons.apple),
            isLoading: true,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue with Apple'), findsNothing);

      // Attempt tapping while loading
      await tester.tap(find.byType(SocialAuthButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('disabled state when onPressed is null', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          const SocialAuthButton(
            label: 'Disabled Button',
            icon: Icon(Icons.lock),
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final outlinedButton =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(outlinedButton.onPressed, isNull);
    });

    testWidgets('supports leading icon when iconTrailing is false',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Leading Icon',
            icon: const Icon(Icons.login, key: Key('leading_icon')),
            iconTrailing: false,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leading Icon'), findsOneWidget);
      expect(find.byKey(const Key('leading_icon')), findsOneWidget);

      final row = tester.widget<Row>(find.byType(Row));
      // First child should be the icon
      expect(row.children.first, isA<Icon>());
    });

    testWidgets('supports trailing icon when iconTrailing is true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Trailing Icon',
            icon: const Icon(Icons.arrow_forward, key: Key('trailing_icon')),
            iconTrailing: true,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final row = tester.widget<Row>(find.byType(Row));
      // Last child should be the icon
      expect(row.children.last, isA<Icon>());
    });

    testWidgets('SocialAuthButton.apple factory creates functional button',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton.apple(
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);

      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('SocialAuthButton.google factory creates functional button',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton.google(
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continue with Google'), findsOneWidget);

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('applies custom styling (colors, height, borderRadius)',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Custom Styled',
            icon: const Icon(Icons.star),
            height: 56,
            borderRadius: 16,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.amber,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(find.ancestor(
        of: find.byType(OutlinedButton),
        matching: find.byType(SizedBox),
      ).first);
      expect(sizedBox.height, 56);

      final text = tester.widget<Text>(find.text('Custom Styled'));
      expect(text.style?.color, Colors.amber);
    });

    testWidgets('handles narrow width and long label without RenderFlex overflow',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            width: 140,
            label: 'Continue with Very Long Provider Name Here',
            icon: const Icon(Icons.login),
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders correctly without an icon when icon is omitted',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Text Only Button',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Text Only Button'), findsOneWidget);
      // When icon is omitted, it should return Text directly without a Row
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('handles high accessibility text scaling safely without crash',
        (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            theme: AppTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: Scaffold(
                body: Center(
                  child: SocialAuthButton.google(
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('dims content opacity to 0.6 when disabled', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          const SocialAuthButton(
            label: 'Disabled Opacity Check',
            icon: Icon(Icons.lock),
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final opacityFinder = find.descendant(
        of: find.byType(OutlinedButton),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(opacityFinder);
      expect(opacityWidget.opacity, 0.6);
    });

    testWidgets('keeps content opacity at 1.0 when active', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Active Opacity Check',
            icon: const Icon(Icons.check),
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final opacityFinder = find.descendant(
        of: find.byType(OutlinedButton),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(opacityFinder);
      expect(opacityWidget.opacity, 1.0);
    });

    testWidgets('loading indicator has accessibility semantics label',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Google Sign In',
            icon: const Icon(Icons.g_mobiledata),
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );
      await tester.pump();

      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(cpi.semanticsLabel, 'Google Sign In loading');
    });

    testWidgets('suppresses multiple rapid taps during loading',
        (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton(
            label: 'Rapid Tap Button',
            icon: const Icon(Icons.touch_app),
            isLoading: true,
            onPressed: () {
              tapCount++;
            },
          ),
        ),
      );
      await tester.pump();

      // Tap 5 times rapidly
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(SocialAuthButton), warnIfMissed: false);
      }
      await tester.pump();

      expect(tapCount, 0);
    });

    testWidgets('SocialAuthButton.apple adapts icon color in light mode',
        (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SocialAuthButton.apple(onPressed: () {}),
          theme: ThemeData.light(),
        ),
      );
      await tester.pumpAndSettle();

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.apple));
      // In light mode, default icon color should match textPrimary (not white)
      expect(iconWidget.color, isNot(Colors.white));
    });
  });
}
