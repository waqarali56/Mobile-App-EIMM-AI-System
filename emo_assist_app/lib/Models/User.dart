// lib/Models/User.dart
import 'package:emo_assist_app/Enums/AppEnums.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserType type;
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    this.createdAt,
    this.phoneNumber,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['userId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['fullName'] ?? json['username'] ?? 'User',
      type: _parseUserType(json['userType'] ?? json['role']),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }

  static UserType _parseUserType(dynamic type) {
    if (type == null) return UserType.free;
    
    final typeStr = type.toString().toLowerCase();
    
    if (typeStr.contains('premium')) return UserType.premium;
    if (typeStr.contains('admin')) return UserType.premium;
    if (typeStr.contains('free')) return UserType.free;
    if (typeStr.contains('guest')) return UserType.guest;
    
    return UserType.free;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': type.index,
      'createdAt': createdAt?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
    };
  }

  bool get isPremium => type == UserType.premium;
  bool get isGuest => type == UserType.guest;
  
  // User doesn't need to know about tokens
}