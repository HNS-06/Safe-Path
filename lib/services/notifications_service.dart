import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        read: j['read'] as bool,
      );
}

class NotificationsService {
  NotificationsService._internal();
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;

  final ValueNotifier<List<NotificationItem>> notifications = ValueNotifier([]);

  ValueListenable<int> get unreadCount => ValueNotifier<int>(_getUnreadCount())..value = _getUnreadCount();

  Future<void> init() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('safepath_notifications');
      if (raw != null && raw.isNotEmpty) {
        final List decoded = json.decode(raw) as List;
        final items = decoded.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
        notifications.value = items;
      }
    } catch (e) {
      // ignore errors and start empty
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(notifications.value.map((e) => e.toJson()).toList());
      await prefs.setString('safepath_notifications', encoded);
    } catch (e) {
      // ignore
    }
  }

  int _getUnreadCount() {
    return notifications.value.where((n) => !n.read).length;
  }

  void add(NotificationItem item) {
    final list = List<NotificationItem>.from(notifications.value);
    list.insert(0, item);
    notifications.value = list;
    _saveToPrefs();
  }

  void markRead(String id) {
    final list = notifications.value.map((n) {
      if (n.id == id) {
        n.read = true;
      }
      return n;
    }).toList();
    notifications.value = list;
    _saveToPrefs();
  }

  void markAllRead() {
    for (var n in notifications.value) {
      n.read = true;
    }
    notifications.value = List<NotificationItem>.from(notifications.value);
    _saveToPrefs();
  }

  // Helper to seed a couple of demo notifications if the list is empty
  void seedDemoIfEmpty() {
    if (notifications.value.isEmpty) {
      add(NotificationItem(
        id: 'welcome',
        title: 'Welcome to SafePath',
        body: 'Turn on voice assistant and permissions to use safety features.',
      ));
      add(NotificationItem(
        id: 'getting_started',
        title: 'Getting Started',
        body: 'Add a guardian, submit your first report, and earn achievements.',
      ));
    }
  }
}
