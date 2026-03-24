import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final prefs = await SharedPreferences.getInstance();
  final prefsService = PreferencesService(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: prefsService),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefsService),
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (_) => GameProvider()..initialize(),
        ),
      ],
      child: const StoryPathApp(),
    ),
  );
}

class StoryPathApp extends StatelessWidget {
  const StoryPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'StoryPath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D6F),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D6F),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(themeProvider.fontScale)),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
