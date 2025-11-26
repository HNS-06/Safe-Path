import 'dart:async';
import 'package:safepath/models/group_model.dart';

class GroupSafetyService {
  final List<SafetyGroup> _groups = [];
  final StreamController<List<SafetyGroup>> _groupsController = 
      StreamController<List<SafetyGroup>>.broadcast();
  
  // Mock data
  GroupSafetyService() {
    _initializeMockData();
  }
  
  void _initializeMockData() {
    _groups.addAll([
      SafetyGroup(
        id: '1',
        name: 'Evening Walk Group',
        members: [
          GroupMember(
            id: 'user1',
            name: 'You',
            isOnline: true,
            lastLocation: const GroupLocation(lat: 28.6139, lng: 77.2090),
            lastActive: DateTime.now(),
          ),
          GroupMember(
            id: 'user2', 
            name: 'Alex Chen',
            isOnline: true,
            lastLocation: const GroupLocation(lat: 28.6145, lng: 77.2100),
            lastActive: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SafetyGroup(
        id: '2',
        name: 'Work Commute',
        members: [
          GroupMember(
            id: 'user1',
            name: 'You',
            isOnline: true,
            lastLocation: const GroupLocation(lat: 28.6139, lng: 77.2090),
            lastActive: DateTime.now(),
          ),
          GroupMember(
            id: 'user3',
            name: 'Sarah Wilson',
            isOnline: false,
            lastLocation: const GroupLocation(lat: 28.6120, lng: 77.2080),
            lastActive: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);
  }
  
  Stream<List<SafetyGroup>> get groupsStream => _groupsController.stream;
  
  Future<List<SafetyGroup>> getGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_groups);
  }
  
  Future<void> createGroup(String name, List<String> memberIds) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newGroup = SafetyGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      members: [
        GroupMember(
          id: 'user1', // Current user
          name: 'You',
          isOnline: true,
          lastLocation: const GroupLocation(lat: 28.6139, lng: 77.2090),
          lastActive: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
    );
    
    _groups.add(newGroup);
    _groupsController.add(List.from(_groups));
  }
  
  Future<void> sendSafetyCheckIn(String groupId, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real app, this would send to backend
    print('Safety check-in sent: $message');
  }
  
  Future<void> updateLocation(String groupId, double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In real app, this would update in backend
    print('Location updated: $lat, $lng');
  }
  
  void dispose() {
    _groupsController.close();
  }
}