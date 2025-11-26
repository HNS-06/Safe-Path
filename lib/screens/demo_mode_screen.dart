import 'package:flutter/material.dart';
import 'package:safepath/theme/colors.dart';
import 'package:safepath/features/voice_navigation/widgets/voice_control_panel.dart';
import 'package:safepath/services/voice_service.dart';

class DemoModeScreen extends StatefulWidget {
  const DemoModeScreen({super.key});

  @override
  State<DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<DemoModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Demo Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDemoCard(
              title: 'Buddy System',
              icon: Icons.people,
              color: AppColors.primary,
              description: 'Real-time location sharing with trusted contacts',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              title: 'Voice Navigation',
              icon: Icons.record_voice_over,
              color: AppColors.safe,
              description: 'Turn-by-turn audio guidance with safety alerts',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              title: 'Offline Maps',
              icon: Icons.cloud_off,
              color: AppColors.warning,
              description: 'Navigate safely without internet connection',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              title: 'Weather & Heat Maps',
              icon: Icons.cloud_circle,
              color: Color(0xFF64B5F6),
              description: 'Real-time weather and safety density visualization',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              title: 'Safety Analytics',
              icon: Icons.analytics,
              color: Color(0xFF81C784),
              description: 'Gamification with points and achievement badges',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              title: 'Dark Mode',
              icon: Icons.dark_mode,
              color: Colors.grey[700]!,
              description: 'Toggle between light and dark themes',
            ),
            const SizedBox(height: 24),
            VoiceControlPanel(
              onEmergency: () async {
                // urgent alert tone / message
                await VoiceService().speak('Emergency alert. Please seek safety and call local emergency services.');
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎮 Demo Features Enabled',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All features are available in demo mode with mock data. Transitions and animations provide a smooth user experience.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
