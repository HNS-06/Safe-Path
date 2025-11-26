import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:safepath/emergency/models/emergency_alert.dart';
import 'package:safepath/emergency/models/emergency_contact.dart';

class EmergencyService {
  EmergencyService._() {
    _initMockStream();
  }

  static final EmergencyService _instance = EmergencyService._();
  factory EmergencyService() => _instance;

  final _controller = StreamController<List<EmergencyAlert>>.broadcast();
  late Timer _timer;
  final Random _random = Random();

  final List<EmergencyAlert> _baseAlerts = [
    EmergencyAlert(
      id: 'alert-101',
      title: 'Crowd density rising',
      description: 'Higher than usual crowd near Metro Gate 3.',
      type: EmergencyType.crowdAlert,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      locationName: 'Metro Plaza',
      distanceInMeters: 180,
      severity: 3,
      isActive: true,
    ),
    EmergencyAlert(
      id: 'alert-102',
      title: 'Street light outage',
      description: 'Temporary visibility issue reported in Sector 21.',
      type: EmergencyType.infrastructure,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      locationName: 'Sector 21 Walkway',
      distanceInMeters: 420,
      severity: 2,
      isActive: true,
    ),
    EmergencyAlert(
      id: 'alert-103',
      title: 'Weather alert',
      description: 'Drizzle expected within 15 minutes. Surfaces may be slippery.',
      type: EmergencyType.weather,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      locationName: 'City Center',
      distanceInMeters: 90,
      severity: 4,
      isActive: true,
    ),
  ];

  void _initMockStream() {
    _controller.add(_baseAlerts);
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      final updated = _baseAlerts.map((alert) {
        final randomSeverity = (alert.severity + _random.nextInt(3) - 1)
            .clamp(1, 5)
            .toInt();
        final driftingDistance = (alert.distanceInMeters + _random.nextInt(40) - 20)
            .clamp(40, 1200)
            .toDouble();
        final isActive = _random.nextBool() || randomSeverity >= 3;
        return alert.copyWith(
          severity: randomSeverity,
          distanceInMeters: driftingDistance,
          isActive: isActive,
        );
      }).toList();
      _controller.add(updated);
    });
  }

  Stream<List<EmergencyAlert>> watchAlerts() => _controller.stream;

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      EmergencyContact(
        name: 'City Guardian Desk',
        role: 'Verified helper',
        phone: '+1 202 555 0147',
        icon: Icons.shield,
      ),
      EmergencyContact(
        name: 'Local Police',
        role: 'Emergency',
        phone: '112',
        icon: Icons.local_police,
      ),
      EmergencyContact(
        name: 'Medical Response',
        role: 'Rapid care',
        phone: '+1 202 555 0114',
        icon: Icons.health_and_safety,
      ),
    ];
  }

  Future<String> triggerHelpRequest({
    required String message,
    required bool shareLocation,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final ticketId = 'SOS-${1000 + _random.nextInt(9000)}';
    return ticketId;
  }

  void dispose() {
    _timer.cancel();
    _controller.close();
  }
}

