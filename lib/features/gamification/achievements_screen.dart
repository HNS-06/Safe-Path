import 'package:flutter/material.dart';
import 'package:safepath/theme/colors.dart';
import 'package:safepath/services/gamification_service.dart';
import 'package:safepath/models/analytics_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = GamificationService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : AppColors.textPrimary,
      ),
      body: ValueListenableBuilder<UserAnalytics?>(
        valueListenable: service.analyticsNotifier,
        builder: (context, analytics, _) {
          if (analytics == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final points = analytics.totalPoints;
          final badge = service.getAchievementBadge(points);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(badge, style: const TextStyle(fontSize: 28)),
                    const Spacer(),
                    Chip(label: Text('$points pts')),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Total Points: $points', style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                )),
                const SizedBox(height: 16),
                Text('Milestones', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                )),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: analytics.reportsSubmitted >= 1,
                  onChanged: null,
                  title: const Text('First Report'),
                ),
                CheckboxListTile(
                  value: analytics.reportsSubmitted >= 5,
                  onChanged: null,
                  title: const Text('5 Reports Submitted'),
                ),
                CheckboxListTile(
                  value: analytics.buddiesHelped >= 1,
                  onChanged: null,
                  title: const Text('Community Helper'),
                ),
                const SizedBox(height: 16),
                Text('Recent Activity', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                )),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: analytics.events.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    ),
                    itemBuilder: (context, i) {
                      final e = analytics.events.reversed.toList()[i];
                      return ListTile(
                        title: Text(e.description,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text('${e.points} pts • ${e.type}',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        trailing: Text('${e.timestamp.toLocal().toString().split('.').first}',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
