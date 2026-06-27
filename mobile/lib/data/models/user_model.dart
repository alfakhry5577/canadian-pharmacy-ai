import 'package:equatable/equatable.dart';

enum UserRole { admin, pharmacist, customer }

UserRole userRoleFromString(String value) {
  switch (value) {
    case 'admin':
      return UserRole.admin;
    case 'pharmacist':
      return UserRole.pharmacist;
    default:
      return UserRole.customer;
  }
}

String userRoleToString(UserRole role) => role.name;

class UserModel extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final String? dateOfBirth;
  final bool isPregnant;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.dateOfBirth,
    required this.isPregnant,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: userRoleFromString(json['role'] as String),
        dateOfBirth: json['date_of_birth'] as String?,
        isPregnant: json['is_pregnant'] as bool? ?? false,
        createdAt: json['created_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': userRoleToString(role),
        'date_of_birth': dateOfBirth,
        'is_pregnant': isPregnant,
        'created_at': createdAt,
      };

  @override
  List<Object?> get props => [id, fullName, email, phone, role, dateOfBirth, isPregnant, createdAt];
}
