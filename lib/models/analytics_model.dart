class SafetyAnalyticsEvent {
  final String id;
  final String type;
  final int points;
  final String description;
  final DateTime timestamp;

  SafetyAnalyticsEvent({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'points': points,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SafetyAnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      SafetyAnalyticsEvent(
        id: json['id'] as String,
        type: json['type'] as String,
        points: json['points'] as int,
        description: json['description'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class UserAnalytics {
  final String userId;
  final int totalPoints;
  final int reportsSubmitted;
  final int buddiesHelped;
  final List<SafetyAnalyticsEvent> events;
  final DateTime lastActivityTime;

  UserAnalytics({
    required this.userId,
    required this.totalPoints,
    required this.reportsSubmitted,
    required this.buddiesHelped,
    required this.events,
    required this.lastActivityTime,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'totalPoints': totalPoints,
        'reportsSubmitted': reportsSubmitted,
        'buddiesHelped': buddiesHelped,
        'events': events.map((e) => e.toJson()).toList(),
        'lastActivityTime': lastActivityTime.toIso8601String(),
      };

  factory UserAnalytics.fromJson(Map<String, dynamic> json) => UserAnalytics(
        userId: json['userId'] as String,
        totalPoints: json['totalPoints'] as int,
        reportsSubmitted: json['reportsSubmitted'] as int,
        buddiesHelped: json['buddiesHelped'] as int,
        events: (json['events'] as List?)
                ?.map((e) => SafetyAnalyticsEvent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        lastActivityTime: DateTime.parse(json['lastActivityTime'] as String),
      );
}
