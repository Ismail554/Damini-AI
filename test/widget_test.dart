// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Braintech/app.dart';
import 'package:Braintech/controllers/auth_provider.dart';
import 'package:Braintech/controllers/navigation_provider.dart';
import 'package:Braintech/controllers/opportunity_provider.dart';
import 'package:Braintech/controllers/sponsor_project_provider.dart';
import 'package:Braintech/controllers/theme_provider.dart';
import 'package:Braintech/views/sponsor/create_project/controllers/project_draft_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => OpportunityProvider()),
          ChangeNotifierProvider(create: (_) => SponsorProjectProvider()),
          ChangeNotifierProvider(create: (_) => ProjectDraftProvider()),
        ],
        child: const MyApp(),
      ),
    );
    expect(find.byType(MyApp), findsOneWidget);
  });
}
