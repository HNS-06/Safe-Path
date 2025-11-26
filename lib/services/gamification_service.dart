import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safepath/models/analytics_model.dart';

class GamificationService {
  GamificationService._();
  static final GamificationService _instance = GamificationService._();
  factory GamificationService() => _instance;

  static const _kAnalyticsKey = 'safepath_analytics_v1';

  final ValueNotifier<UserAnalytics?> analyticsNotifier = ValueNotifier<UserAnalytics?>(null);

  Future<void> init({String userId = 'user1'}) async {
    final data = await getUserAnalytics(userId);
    if (data.totalPoints == 0 && data.events.isEmpty) {
      // seed demo events
      final seeded = UserAnalytics(
        userId: userId,
        totalPoints: 430,
        reportsSubmitted: 3,
        buddiesHelped: 1,
        events: [
          SafetyAnalyticsEvent(
            id: 'e1',
            type: 'report_submitted',
            points: 50,
            description: 'Submitted first safety report',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
          SafetyAnalyticsEvent(
            id: 'e2',
            type: 'report_submitted',
            points: 50,
            description: 'Submitted second safety report',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ),
          SafetyAnalyticsEvent(
            id: 'e3',
            type: 'achievement',
            points: 330,
            description: 'Community helper recognition',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        lastActivityTime: DateTime.now(),
      );
      await saveUserAnalytics(seeded);
      analyticsNotifier.value = seeded;
    } else {
      analyticsNotifier.value = data;
    }
  }

  Future<UserAnalytics> getUserAnalytics(String userId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kAnalyticsKey);
    if (raw == null) {
      return UserAnalytics(
        userId: userId,
        totalPoints: 0,
        reportsSubmitted: 0,
        buddiesHelped: 0,
        events: [],
        lastActivityTime: DateTime.now(),
      );
    }
    return UserAnalytics.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> saveUserAnalytics(UserAnalytics analytics) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAnalyticsKey, json.encode(analytics.toJson()));
    analyticsNotifier.value = analytics;
  }

  Future<void> awardPoints(String userId, int points, String reason) async {
    final analytics = await getUserAnalytics(userId);
    final event = SafetyAnalyticsEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: reason,
      points: points,
      description: reason,
      timestamp: DateTime.now(),
    );

    final updated = UserAnalytics(
      userId: analytics.userId,
      totalPoints: analytics.totalPoints + points,
      reportsSubmitted: analytics.reportsSubmitted,
      buddiesHelped: analytics.buddiesHelped,
      events: [...analytics.events, event],
      lastActivityTime: DateTime.now(),
    );

    await saveUserAnalytics(updated);
  }

  Future<void> recordReportSubmission(String userId) async {
    final analytics = await getUserAnalytics(userId);
    final updated = UserAnalytics(
      userId: analytics.userId,
      totalPoints: analytics.totalPoints + 50,
      reportsSubmitted: analytics.reportsSubmitted + 1,
      buddiesHelped: analytics.buddiesHelped,
      events: analytics.events,
      lastActivityTime: DateTime.now(),
    );
    await saveUserAnalytics(updated);
  }

  String getAchievementBadge(int totalPoints) {
    if (totalPoints >= 1000) return '🏆 Legendary Guardian';
    if (totalPoints >= 500) return '⭐ Gold Member';
    if (totalPoints >= 250) return '🥈 Silver Member';
    if (totalPoints >= 100) return '🥉 Bronze Member';
    return '🌱 Newcomer';
  }

  /// Returns a simple leaderboard (mocked for demo). This could be replaced by a backend call.
  List<Map<String, dynamic>> getLeaderboard() {
    final analytics = analyticsNotifier.value;
    final youPoints = analytics?.totalPoints ?? 0;
    return [
      {'name': 'Alex', 'points': 1240},
      {'name': 'Sam', 'points': 980},
      {'name': 'You', 'points': youPoints},
      {'name': 'Rita', 'points': 320},
    ];
  }
}

