import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:Braintech/core/theme/app_theme.dart';
import 'package:Braintech/views/auth/change_password/screens/change_password_view.dart';
import 'package:Braintech/views/auth/forgot_password/screens/forgot_password_view.dart';
import 'package:Braintech/views/auth/login/screens/login_view.dart';
import 'package:Braintech/views/auth/signup/screens/signup_view.dart';
import 'package:Braintech/views/profile/company_verification/screens/company_verification_view.dart';
import 'package:Braintech/views/profile/personal_info/screens/personal_info_view.dart';
import 'package:Braintech/views/role_selection/role_selection_view.dart';
import 'package:Braintech/views/settings/screens/settings_view.dart';
import 'package:Braintech/views/subscription/subscription_view.dart';

Widget buildTestableScreen(Widget screen) {
  return ProviderScope(
    child: MediaQuery(
      data: const MediaQueryData(
        size: Size(390, 844),
        devicePixelRatio: 2.0,
      ),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: Material(child: screen),
        ),
      ),
    ),
  );
}

Future<void> loadOutfitFonts() async {
  final fontMap = <FontWeight, String>{
    FontWeight.w100: 'assets/fonts/Outfit-Thin.ttf',
    FontWeight.w200: 'assets/fonts/Outfit-ExtraLight.ttf',
    FontWeight.w300: 'assets/fonts/Outfit-Light.ttf',
    FontWeight.w400: 'assets/fonts/Outfit-Regular.ttf',
    FontWeight.w500: 'assets/fonts/Outfit-Medium.ttf',
    FontWeight.w600: 'assets/fonts/Outfit-SemiBold.ttf',
    FontWeight.w700: 'assets/fonts/Outfit-Bold.ttf',
    FontWeight.w800: 'assets/fonts/Outfit-ExtraBold.ttf',
    FontWeight.w900: 'assets/fonts/Outfit-Black.ttf',
  };

  for (final entry in fontMap.entries) {
    final fontData = await rootBundle.load(entry.value);
    final fontName = GoogleFonts.outfit(fontWeight: entry.key).fontFamily;
    if (fontName != null) {
      final loader = FontLoader(fontName)..addFont(Future.value(fontData));
      await loader.load();
    }
  }

  final baseData = await rootBundle.load('assets/fonts/Outfit-Regular.ttf');
  final baseLoader = FontLoader('Outfit')..addFont(Future.value(baseData));
  await baseLoader.load();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadAppFonts();
    await loadOutfitFonts();
  });

  testGoldens('Export Screens to Images', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    final screens = <String, Widget>{
      'login_view': const LoginView(),
      'signup_view': const SignUpView(),
      'forgot_password_view': const ForgotPasswordView(),
      'role_selection_view': const RoleSelectionView(),
      'settings_view': const SettingsView(),
      'subscription_view': const SubscriptionView(),
      'change_password_view': const ChangePasswordView(),
      'company_verification_view': const CompanyVerificationView(),
      'personal_information_view': const PersonalInformationView(),
    };

    for (final entry in screens.entries) {
      await tester.pumpWidget(buildTestableScreen(entry.value));
      await tester.pump(const Duration(milliseconds: 300));
      tester.takeException();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
    }
  });
}
