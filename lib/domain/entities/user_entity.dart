class UserEntity {
  final String id;
  final String phone;
  final String fullName;
  final String? email;
  final String? profilePhoto;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.phone,
    required this.fullName,
    this.email,
    this.profilePhoto,
    required this.createdAt,
  });
}