class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final int reportsSubmitted;
  final int routesCreated;
  final DateTime joinDate;
  final double communityScore;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.reportsSubmitted = 0,
    this.routesCreated = 0,
    required this.joinDate,
    this.communityScore = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'reportsSubmitted': reportsSubmitted,
      'routesCreated': routesCreated,
      'joinDate': joinDate.toIso8601String(),
      'communityScore': communityScore,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      reportsSubmitted: json['reportsSubmitted'] ?? 0,
      routesCreated: json['routesCreated'] ?? 0,
      joinDate: DateTime.parse(json['joinDate']),
      communityScore: (json['communityScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}