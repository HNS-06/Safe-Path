class Buddy {
  final String id;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? lastSeen;

  Buddy({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.isVerified = false,
    this.lastSeen,
  });

  Buddy copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatarUrl,
    bool? isVerified,
    DateTime? lastSeen,
  }) {
    return Buddy(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
        'lastSeen': lastSeen?.toIso8601String(),
      };

  factory Buddy.fromJson(Map<String, dynamic> json) => Buddy(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        lastSeen: json['lastSeen'] != null
            ? DateTime.parse(json['lastSeen'] as String)
            : null,
      );

  @override
  String toString() => 'Buddy(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Buddy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
