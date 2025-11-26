import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:safepath/screens/map_screen.dart';
import 'package:safepath/screens/routes_screen.dart';
import 'package:safepath/screens/report_screen.dart';
import 'package:safepath/screens/profile_screen.dart';
import 'package:safepath/widgets/gradient_app_bar.dart';
import 'package:safepath/services/notifications_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _screens = [
    const MapScreen(),
    const RoutesScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: _getAppBarTitle(),
        showBackButton: false,
        actions: _buildAppBarActions(),
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).primaryColor,
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(Icons.map, color: Colors.white, size: 30),
          Icon(Icons.route, color: Colors.white, size: 30),
          Icon(Icons.add_location, color: Colors.white, size: 30),
          Icon(Icons.person, color: Colors.white, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _animationController.reset();
            _animationController.forward();
          });
        },
      ),
      drawer: _buildDrawer(),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      // Notifications bell with unread badge
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
          child: ValueListenableBuilder(
            valueListenable: NotificationsService().notifications,
            builder: (context, List list, _) {
              final unread = list.where((n) => !(n as dynamic).read).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications, size: 26),
                  if (unread > 0)
                    Positioned(
                      right: 0,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unread > 99 ? '99+' : unread.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColorDark,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  'SafePath User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Community Guardian',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            Icons.psychology,
            'AI Safety Predictor',
            () => Navigator.pushNamed(context, '/ai-predictor'),
          ),
          _buildDrawerItem(
            Icons.group,
            'Group Safety',
            () => Navigator.pushNamed(context, '/groups'),
          ),
          _buildDrawerItem(
            Icons.emoji_events,
            'Achievements',
            () => Navigator.pushNamed(context, '/achievements'),
          ),
          _buildDrawerItem(
            Icons.leaderboard,
            'Leaderboard',
            () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          _buildDrawerItem(
            Icons.analytics,
            'Safety Analytics',
            () => Navigator.pushNamed(context, '/analytics'),
          ),
          _buildDrawerItem(
            Icons.emergency,
            'Emergency Center',
            () => Navigator.pushNamed(context, '/emergency-center'),
          ),
          const Divider(),
          _buildThemeSwitch(),
          _buildDrawerItem(
            Icons.settings,
            'Settings',
            () {
              // Navigate to settings
            },
          ),
          _buildDrawerItem(
            Icons.help,
            'Help & Support',
            () {
              // Navigate to help
            },
          ),
          _buildDrawerItem(
            Icons.logout,
            'Logout',
            () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  Widget _buildThemeSwitch() {
    return ListTile(
      leading: Icon(
        widget.currentThemeMode == ThemeMode.dark 
            ? Icons.dark_mode 
            : Icons.light_mode,
      ),
      title: const Text('Theme'),
      trailing: Switch(
        value: widget.currentThemeMode == ThemeMode.dark,
        onChanged: (value) {
          widget.onThemeChanged(
            value ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement logout logic
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0: return 'SafePath Map';
      case 1: return 'Safe Routes';
      case 2: return 'Report Issue';
      case 3: return 'My Profile';
      default: return 'SafePath';
    }
  }
}