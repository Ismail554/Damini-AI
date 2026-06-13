import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Braintech/app.dart';
import 'package:Braintech/controllers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_provider.dart';
import 'controllers/theme_provider.dart';
import 'controllers/opportunity_provider.dart';
import 'core/services/app_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AppService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => OpportunityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
