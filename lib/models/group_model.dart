class SafetyGroup {
  final String id;
  final String name;
  final List<GroupMember> members;
  final DateTime createdAt;

  SafetyGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
  });
}

class GroupMember {
  final String id;
  final String name;
  final bool isOnline;
  final GroupLocation lastLocation;
  final DateTime lastActive;

  const GroupMember({
    required this.id,
    required this.name,
    required this.isOnline,
    required this.lastLocation,
    required this.lastActive,
  });
}

class GroupLocation {
  final double lat;
  final double lng;

  const GroupLocation({required this.lat, required this.lng});
}
