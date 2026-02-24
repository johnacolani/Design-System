import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final int projectsCreated;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.projectsCreated = 0,
  });

  factory User.guest() => User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest User',
        email: 'guest@example.com',
        role: UserRole.free,
        createdAt: DateTime.now(),
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.free,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLoginAt: json['lastLoginAt'] != null
            ? DateTime.parse(json['lastLoginAt'] as String)
            : null,
        isPremium: json['isPremium'] as bool? ?? false,
        projectsCreated: json['projectsCreated'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'isPremium': isPremium,
        'projectsCreated': projectsCreated,
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    int? projectsCreated,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      projectsCreated: projectsCreated ?? this.projectsCreated,
    );
  }
}

enum UserRole {
  free,
  pro,
  enterprise,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.free:
        return 'Free Member';
      case UserRole.pro:
        return 'Pro Member';
      case UserRole.enterprise:
        return 'Enterprise';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.free:
        return Colors.grey;
      case UserRole.pro:
        return Colors.blue;
      case UserRole.enterprise:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
    }
  }
}
