import 'package:flutter/material.dart';
import 'package:safepath/features/gamification/achievements_screen.dart';
import 'package:safepath/features/gamification/leaderboard_screen.dart';
import 'package:safepath/features/gamification/analytics_dashboard_screen.dart';

class SafePathAchievementsRoute extends StatelessWidget {
  const SafePathAchievementsRoute({super.key});

  @override
  Widget build(BuildContext context) => const AchievementsScreen();
}

class SafePathLeaderboardRoute extends StatelessWidget {
  const SafePathLeaderboardRoute({super.key});

  @override
  Widget build(BuildContext context) => const LeaderboardScreen();
}

class SafePathAnalyticsRoute extends StatelessWidget {
  const SafePathAnalyticsRoute({super.key});

  @override
  Widget build(BuildContext context) => AnalyticsDashboardScreen(userId: 'user1');
}
