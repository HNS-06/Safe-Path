import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EmergencyContact extends Equatable {
  const EmergencyContact({
    required this.name,
    required this.role,
    required this.phone,
    required this.icon,
  });

  final String name;
  final String role;
  final String phone;
  final IconData icon;

  @override
  List<Object?> get props => [name, role, phone, icon];
}

