import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safepath/models/safety_report.dart';
import 'package:safepath/models/user_model.dart';
import 'package:safepath/services/map_service.dart';

// Mock database service - in real app, this would connect to Firebase/Firestore/API
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final List<SafetyReport> _reports = [];
  final List<UserModel> _users = [];

  // Safety Reports Methods
  Future<void> addSafetyReport(SafetyReport report) async {
    _reports.add(report);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<SafetyReport>> getSafetyReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_reports);
  }

  Future<List<SafetyReport>> getSafetyReportsInArea(LatLng center, double radiusKm) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _reports.where((report) {
      final distance = MapService.calculateDistance(center, report.location);
      return distance <= radiusKm;
    }).toList();
  }

  Future<void> updateSafetyReport(String reportId, SafetyReport updatedReport) async {
    final index = _reports.indexWhere((report) => report.id == reportId);
    if (index != -1) {
      _reports[index] = updatedReport;
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // User Methods
  Future<void> addUser(UserModel user) async {
    _users.add(user);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<UserModel?> getUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }
}