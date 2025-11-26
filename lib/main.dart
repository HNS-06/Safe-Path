import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safepath/screens/home_screen.dart';
import 'package:safepath/screens/login_screen.dart';
import 'package:safepath/screens/signup_screen.dart';
import 'package:safepath/services/auth_service.dart';
import 'package:safepath/services/voice_service.dart';
import 'package:safepath/features/voice_navigation/voice_navigation_service.dart';
import 'package:safepath/features/ai/ai_routes.dart';
import 'package:safepath/features/group_safety/groups_routes.dart';
import 'package:safepath/features/gamification/gamification_routes.dart';
import 'package:safepath/theme/app_theme.dart';
import 'package:safepath/emergency/presentation/emergency_center_screen.dart';
import 'package:safepath/services/notifications_service.dart';
import 'package:safepath/services/gamification_service.dart';
import 'package:safepath/services/buddy_service.dart';
import 'package:safepath/screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  await SharedPreferences.getInstance();
  
  // Initialize voice service
  try {
    await VoiceService().initialize();
  } catch (e) {
    print('Failed to initialize voice service: $e');
  }
  // Initialize new TTS voice navigation
  try {
    await VoiceNavigationService().init();
  } catch (e) {
    print('Failed to initialize voice navigation TTS: $e');
  }
  
  // Load user data
  try {
    await AuthService().loadUser();
  } catch (e) {
    print('Failed to load user: $e');
    // Continue with app - user will need to log in
  }

  // Initialize notifications service
  try {
    await NotificationsService().init();
    // seed some demo notifications if empty
    NotificationsService().seedDemoIfEmpty();
  } catch (e) {
    print('Failed to initialize notifications service: $e');
  }
  
  // Initialize gamification and buddy services (seed demo data)
  try {
    await GamificationService().init();
  } catch (e) {
    print('Failed to init gamification: $e');
  }

  try {
    await BuddyService().init();
  } catch (e) {
    print('Failed to init buddy service: $e');
  }

  runApp(const SafePathApp());
}

class SafePathApp extends StatefulWidget {
  const SafePathApp({super.key});

  @override
  State<SafePathApp> createState() => _SafePathAppState();
}

class _SafePathAppState extends State<SafePathApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    // Greet the user with a welcome message once the app is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        await VoiceService().speak('Hi, welcome to SafePath. Where can I get you today?');
      } catch (_) {}
    });
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
      if (mounted) {
        setState(() {
          _themeMode = ThemeMode.values[themeModeIndex];
        });
      }
    } catch (e) {
      print('Failed to load theme mode: $e');
      // Use system default if loading fails
    }
  }

  void _updateThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      print('Failed to save theme mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafePath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: _authService.isLoggedIn ? '/home' : '/login',
      routes: {
        // Authentication Routes
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => HomeScreen(
          onThemeChanged: _updateThemeMode,
          currentThemeMode: _themeMode,
        ),
        
        // Emergency Routes
        '/emergency-center': (context) => const EmergencyCenterScreen(),
        // Feature Routes
        '/ai-predictor': (context) => const SafePathAiRoute(),
        '/groups': (context) => const SafePathGroupsRoute(),
        '/notifications': (context) => const NotificationsScreen(),
        '/achievements': (context) => const SafePathAchievementsRoute(),
        '/leaderboard': (context) => const SafePathLeaderboardRoute(),
        '/analytics': (context) => const SafePathAnalyticsRoute(),
      },
      onUnknownRoute: (settings) {
        // Fallback route - redirect to home
        return MaterialPageRoute(
          builder: (context) => _authService.isLoggedIn 
              ? HomeScreen(
                  onThemeChanged: _updateThemeMode,
                  currentThemeMode: _themeMode,
                )
              : const LoginScreen(),
        );
      },
    );
  }
}