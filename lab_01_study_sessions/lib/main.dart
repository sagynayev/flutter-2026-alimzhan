import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'models/study_session.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/session_form_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final seed = ThemeData().colorScheme.primary;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.shell,
      routes: {
        Routes.shell: (_) => AppShell(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      },
      onGenerateRoute: (settings) => switch (settings.name) {
        Routes.detail => MaterialPageRoute<void>(
          builder: (_) =>
              DetailScreen(arguments: settings.arguments as DetailArguments),
        ),
        Routes.form => MaterialPageRoute<StudySession>(
          builder: (_) => SessionFormScreen(
            initial: (settings.arguments as FormArguments).session,
          ),
        ),
        _ => null,
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const NotFoundScreen()),
    );
  }
}
