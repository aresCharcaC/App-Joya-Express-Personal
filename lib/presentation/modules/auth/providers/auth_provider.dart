// import 'package:flutter/foundation.dart';
// import '../../../../domain/entities/user_entity.dart';
// import '../../../../data/services/local_storage_service.dart';

// class AuthProvider with ChangeNotifier {
//   final LocalStorageService _storage = LocalStorageService();

//   User? _currentUser;
//   bool _isLoading = false;
//   String? _errorMessage;

//   // Getters
//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isAuthenticated => _currentUser != null;

//   // Limpiar errores
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   // Verificar si ya está logueado al iniciar app
//   Future<void> checkAuthStatus() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final isLoggedIn = await _storage.isLoggedIn();
//       if (isLoggedIn) {
//         _currentUser = await _storage.getUser();
//       }
//     } catch (e) {
//       _errorMessage = 'Error verificando estado de autenticación';
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   // Registrar nuevo usuario (después de verificar SMS)
//   Future<bool> registerUser(String phoneNumber, String password) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final user = User(
//         phoneNumber: phoneNumber,
//         password: password,
//         isVerified: true,
//         createdAt: DateTime.now(),
//       );

//       await _storage.registerUser(user);
//       await _storage.saveUser(user);
//       _currentUser = user;

//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _errorMessage = 'Error al registrar usuario';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // Login con teléfono y contraseña
//   Future<bool> login(String phoneNumber, String password) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final user = await _storage.findUserByPhone(phoneNumber);

//       if (user == null) {
//         _errorMessage = 'Usuario no encontrado';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }

//       if (user.password != password) {
//         _errorMessage = 'Contraseña incorrecta';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }

//       await _storage.saveUser(user);
//       _currentUser = user;

//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _errorMessage = 'Error al iniciar sesión';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // Verificar si usuario existe
//   Future<bool> userExists(String phoneNumber) async {
//     try {
//       final user = await _storage.findUserByPhone(phoneNumber);
//       return user != null;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Actualizar contraseña
//   Future<bool> updatePassword(String phoneNumber, String newPassword) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final success = await _storage.updatePassword(phoneNumber, newPassword);

//       if (success) {
//         // Si es el usuario actual, actualizar
//         if (_currentUser?.phoneNumber == phoneNumber) {
//           _currentUser = _currentUser!.copyWith(password: newPassword);
//           await _storage.saveUser(_currentUser!);
//         }
//       } else {
//         _errorMessage = 'Error al actualizar contraseña';
//       }

//       _isLoading = false;
//       notifyListeners();
//       return success;
//     } catch (e) {
//       _errorMessage = 'Error al actualizar contraseña';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // Cerrar sesión
//   Future<void> logout() async {
//     _isLoading = true;
//     notifyListeners();

//     await _storage.logout();
//     _currentUser = null;

//     _isLoading = false;
//     notifyListeners();
//   }

//   // Validar formato de contraseña
//   String? validatePassword(String password) {
//     if (password.length < 8) {
//       return 'La contraseña debe tener al menos 8 caracteres';
//     }

//     if (!password.contains(RegExp(r'[A-Z]'))) {
//       return 'La contraseña debe tener al menos una mayúscula';
//     }

//     if (!password.contains(RegExp(r'[a-z]'))) {
//       return 'La contraseña debe tener al menos una minúscula';
//     }

//     if (!password.contains(RegExp(r'[0-9]'))) {
//       return 'La contraseña debe tener al menos un número';
//     }

//     return null;
//   }
// }
