import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safepath/models/safety_report.dart';
import 'package:safepath/theme/colors.dart';

class SafetyMarker {
  static BitmapDescriptor getIcon(SafetyType type) {
    switch (type) {
      case SafetyType.safe:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case SafetyType.moderate:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case SafetyType.unsafe:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  static String getTitle(SafetyType type) {
    switch (type) {
      case SafetyType.safe:
        return 'Safe Area';
      case SafetyType.moderate:
        return 'Moderate Safety';
      case SafetyType.unsafe:
        return 'Unsafe Area';
      default:
        return 'Unknown';
    }
  }

  static Color getColor(SafetyType type) {
    switch (type) {
      case SafetyType.safe:
        return AppColors.safe;
      case SafetyType.moderate:
        return AppColors.moderate;
      case SafetyType.unsafe:
        return AppColors.unsafe;
      default:
        return AppColors.unknown;
    }
  }
}

