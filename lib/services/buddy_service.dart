import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:safepath/models/buddy.dart';

import 'package:flutter/foundation.dart';

class BuddyService {
  BuddyService._();
  static final BuddyService _instance = BuddyService._();
  factory BuddyService() => _instance;

  static const _kKey = 'safepath_buddies_v1';

  final ValueNotifier<List<Buddy>> buddiesNotifier = ValueNotifier<List<Buddy>>([]);

  Future<List<Buddy>> getBuddies() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kKey) ?? <String>[];
    final list = raw.map((e) => Buddy.fromJson(json.decode(e) as Map<String, dynamic>)).toList();
    buddiesNotifier.value = list;
    return list;
  }

  Future<void> saveBuddies(List<Buddy> buddies) async {
    final sp = await SharedPreferences.getInstance();
    final encoded = buddies.map((b) => json.encode(b.toJson())).toList();
    await sp.setStringList(_kKey, encoded);
    buddiesNotifier.value = List<Buddy>.from(buddies);
  }

  Future<void> addBuddy(Buddy buddy) async {
    final list = await getBuddies();
    if (!list.any((b) => b.id == buddy.id)) {
      list.add(buddy);
      await saveBuddies(list);
    }
  }

  Future<void> removeBuddy(String id) async {
    final list = await getBuddies();
    list.removeWhere((b) => b.id == id);
    await saveBuddies(list);
  }

  Future<void> updateBuddy(Buddy buddy) async {
    final list = await getBuddies();
    final idx = list.indexWhere((b) => b.id == buddy.id);
    if (idx >= 0) {
      list[idx] = buddy;
      await saveBuddies(list);
    } else {
      await addBuddy(buddy);
    }
  }

  Future<void> init() async {
    await getBuddies();
    if (buddiesNotifier.value.isEmpty) {
      // seed some demo buddies
      final demo = [
        Buddy(id: 'b1', name: 'Alex', phone: '+1 555 0101', isVerified: true, lastSeen: DateTime.now().subtract(const Duration(hours: 2))),
        Buddy(id: 'b2', name: 'Sam', phone: '+1 555 0202', isVerified: false, lastSeen: DateTime.now().subtract(const Duration(days: 1))),
      ];
      await saveBuddies(demo);
    }
  }
}
