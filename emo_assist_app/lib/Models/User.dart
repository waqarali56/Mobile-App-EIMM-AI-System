class User {
  final String id;
  final String email;
  final String? name;
  final String? profileImage;
  final UserTier tier;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    this.name,
    this.profileImage,
    this.tier = UserTier.guest,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      profileImage: json['profileImage'],
      tier: _parseUserTier(json['tier']),
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'tier': tier.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  static UserTier _parseUserTier(String tier) {
    switch (tier) {
      case 'premium':
        return UserTier.premium;
      case 'free':
        return UserTier.free;
      default:
        return UserTier.guest;
    }
  }
}

enum UserTier {
  guest,
  free,
  premium,
}