// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../domain/entities/user_entity.dart';


// /* LocalStorageService
//   Servicio para manejar el almacenamiento local de usuarios y sesión
//   Utiliza SharedPreferences para persistencia de datos
// */

// class LocalStorageService {
//   static const String _userKey = 'user_data';//Clave para guardar los datos del usuario actual.
//   static const String _isLoggedInKey = 'is_logged_in';//Clave para saber si un usuario está logueado.
//   static const String _usersKey = 'all_users'; // Simular BD local

//   // Guardar usuario actual
//   Future<void> saveUser(User user) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userKey, jsonEncode(user.toJson()));
//     await prefs.setBool(_isLoggedInKey, true); //marcar como logueado
//   }

//   // Obtener usuario actual
//   Future<User?> getUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userData = prefs.getString(_userKey);
//     if (userData != null) {
//       return User.fromJson(jsonDecode(userData));
//     }
//     return null;
//   }

//   // Verificar si está logueado
//   Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_isLoggedInKey) ?? false;
//   }

//   // Cerrar sesión
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_userKey);
//     await prefs.setBool(_isLoggedInKey, false);
//   }

//   // Registrar nuevo usuario (simular BD)
//   Future<void> registerUser(User user) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<User> users = await getAllUsers();

//     // Verificar si ya existe
//     final existingIndex = users.indexWhere(
//       (u) => u.phoneNumber == user.phoneNumber,
//     );
//     if (existingIndex >= 0) {
//       users[existingIndex] = user; // Actualizar
//     } else {
//       users.add(user); // Agregar nuevo
//     }

//     final usersJson = users.map((u) => u.toJson()).toList();
//     await prefs.setString(_usersKey, jsonEncode(usersJson));
//   }

//   // Obtener todos los usuarios (simular BD)
//   Future<List<User>> getAllUsers() async {
//     final prefs = await SharedPreferences.getInstance();
//     final usersData = prefs.getString(_usersKey);
//     if (usersData != null) {
//       final List<dynamic> usersList = jsonDecode(usersData);
//       return usersList.map((userData) => User.fromJson(userData)).toList();
//     }
//     return [];
//   }

//   // Buscar usuario por teléfono
//   Future<User?> findUserByPhone(String phoneNumber) async {
//     final users = await getAllUsers();
//     try {
//       return users.firstWhere((user) => user.phoneNumber == phoneNumber);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Actualizar contraseña
//   Future<bool> updatePassword(String phoneNumber, String newPassword) async {
//     final users = await getAllUsers();
//     final userIndex = users.indexWhere((u) => u.phoneNumber == phoneNumber);

//     if (userIndex >= 0) {
//       users[userIndex] = users[userIndex].copyWith(password: newPassword);
//       final prefs = await SharedPreferences.getInstance();
//       final usersJson = users.map((u) => u.toJson()).toList();
//       await prefs.setString(_usersKey, jsonEncode(usersJson));
//       return true;
//     }
//     return false;
//   }
// }
