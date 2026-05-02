import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'backend/firebase/firebase_config.dart';
import 'craveshield/screens/dashboard_placeholder_screen.dart';
import 'craveshield/screens/disclaimer_screen.dart';
import 'craveshield/screens/home_screen.dart';
import 'craveshield/screens/login_screen.dart';
import 'craveshield/screens/my_breathing_screen.dart';
import 'craveshield/screens/memory_vault_screen.dart';
import 'craveshield/screens/my_games_screen.dart';
import 'craveshield/screens/my_shield_screen.dart';
import 'craveshield/screens/register_screen.dart';
import 'craveshield/screens/splash_screen.dart';
import 'craveshield/theme/craveshield_colors.dart';
import 'quit_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await initFirebase();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() => _themeMode = themeMode);
  }

  String getRoute() => '';

  List<String> getRouteStack() => const [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRAVESHIELD',
      scrollBehavior: MyAppScrollBehavior(),
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CraveShieldColors.blue,
          brightness: Brightness.light,
          primary: CraveShieldColors.blue,
          secondary: CraveShieldColors.sky,
          surface: CraveShieldColors.panel,
        ),
        scaffoldBackgroundColor: CraveShieldColors.navy,
        fontFamily: 'Inter',
      ),
      home: const QuitSelectionScreen(),
      routes: {
        CraveSplashScreen.routePath: (context) => const CraveSplashScreen(),
        CraveDisclaimerScreen.routePath: (context) =>
            const CraveDisclaimerScreen(),
        CraveRegisterScreen.routePath: (context) => const CraveRegisterScreen(),
        CraveLoginScreen.routePath: (context) => const CraveLoginScreen(),
        HomeScreen.routePath: (context) => const HomeScreen(),
        MyShieldScreen.routePath: (context) => const MyShieldScreen(),
        MyBreathingScreen.routePath: (context) => const MyBreathingScreen(),
        MyGamesScreen.routePath: (context) => const MyGamesScreen(),
        MemoryVaultScreen.routePath: (context) => const MemoryVaultScreen(),
        '/crave-select-addiction': (context) => const QuitSelectionScreen(),
        CraveDashboardPlaceholderScreen.routePath: (context) =>
            const CraveDashboardPlaceholderScreen(),
      },
    );
  }
}