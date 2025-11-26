import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum EmergencyType { suspiciousActivity, medical, crowdAlert, infrastructure, weather }

class EmergencyAlert extends Equatable {
  const EmergencyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.locationName,
    required this.distanceInMeters,
    required this.severity,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final EmergencyType type;
  final DateTime timestamp;
  final String locationName;
  final double distanceInMeters;
  final int severity; // 1 (low) - 5 (critical)
  final bool isActive;

  Color get severityColor {
    switch (severity) {
      case 5:
      case 4:
        return const Color(0xFFEF476F);
      case 3:
        return const Color(0xFFFFD166);
      default:
        return const Color(0xFF06D6A0);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case EmergencyType.suspiciousActivity:
        return Icons.report_problem;
      case EmergencyType.medical:
        return Icons.medical_services;
      case EmergencyType.crowdAlert:
        return Icons.groups;
      case EmergencyType.infrastructure:
        return Icons.construction;
      case EmergencyType.weather:
        return Icons.cloud;
    }
  }

  EmergencyAlert copyWith({
    bool? isActive,
    int? severity,
    double? distanceInMeters,
  }) {
    return EmergencyAlert(
      id: id,
      title: title,
      description: description,
      type: type,
      timestamp: timestamp,
      locationName: locationName,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      severity: severity ?? this.severity,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        timestamp,
        locationName,
        distanceInMeters,
        severity,
        isActive,
      ];
}

