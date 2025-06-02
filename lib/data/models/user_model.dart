class UserModel {
  final String id;
  final String telefono;
  final String nombreCompleto;
  final String? email;
  final String? fotoPerfil;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.telefono,
    required this.nombreCompleto,
    this.email,
    this.fotoPerfil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      telefono: json['telefono'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      email: json['email'],
      fotoPerfil: json['foto_perfil'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telefono': telefono,
      'nombre_completo': nombreCompleto,
      'email': email,
      'foto_perfil': fotoPerfil,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}