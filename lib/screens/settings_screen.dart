import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safepath/services/auth_service.dart';
import 'package:safepath/theme/colors.dart';
import 'package:safepath/features/group_safety/guardian_list_screen.dart';
import 'package:safepath/features/gamification/analytics_dashboard_screen.dart';
import 'package:safepath/screens/demo_mode_screen.dart';
import 'package:safepath/services/voice_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _voiceAssistantEnabled = true;
  bool _locationTrackingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeModeIndex];
      _voiceAssistantEnabled = prefs.getBool('voice_assistant') ?? true;
      _locationTrackingEnabled = prefs.getBool('location_tracking') ?? true;
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    setState(() => _themeMode = mode);
  }

  Future<void> _saveVoiceAssistant(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_assistant', enabled);
    setState(() => _voiceAssistantEnabled = enabled);
    try {
      // Apply immediately to runtime voice service
      await VoiceService().setEnabled(enabled);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveLocationTracking(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_tracking', enabled);
    setState(() => _locationTrackingEnabled = enabled);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme Mode'),
                  subtitle: Text(_getThemeModeText(_themeMode)),
                  trailing: PopupMenuButton<ThemeMode>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (mode) {
                      _saveThemeMode(mode);
                      // Update app theme
                      if (mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Default'),
                      ),
                      const PopupMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Mode'),
                      ),
                      const PopupMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Mode'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.mic),
                  title: const Text('Voice Assistant'),
                  subtitle: const Text('Enable voice commands for reporting'),
                  value: _voiceAssistantEnabled,
                  onChanged: _saveVoiceAssistant,
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.location_on),
                  title: const Text('Location Tracking'),
                  subtitle: const Text('Enable accurate location tracking'),
                  value: _locationTrackingEnabled,
                  onChanged: _saveLocationTracking,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Safety Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Guardians & Buddies'),
                  subtitle: const Text('Manage trusted contacts'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GuardianListScreen(),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: const Text('Safety Analytics'),
                  subtitle: const Text('View your contributions & points'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalyticsDashboardScreen(
                        userId: AuthService().currentUser?.id ?? 'demo-user',
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.gamepad),
                  title: const Text('View Demo Features'),
                  subtitle: const Text('See all new SafePath capabilities'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DemoModeScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AuthService().currentUser?.name ?? 'User'),
                  subtitle: Text(AuthService().currentUser?.email ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }
}

