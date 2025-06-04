import 'package:flutter/material.dart';
import 'package:joya_express/presentation/modules/auth/screens/phone_verification_screen.dart';
import 'package:joya_express/presentation/modules/pasajero/profile/screens/profile_screen.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/phone_input_screen.dart';
import '../auth/screens/create_password_screen.dart';
import '../auth/screens/account_setup_screen.dart';
import '../auth/screens/forgot_password_screen.dart';
import '../auth/screens/welcome_screen.dart';
import '../home/screens/home_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String phoneInput = '/phone-input';
  static const String verifyPhone = '/verify-phone';
  static const String createPassword = '/create-password';
  static const String accountSetup = '/account-setup';
  static const String forgotPassword = '/forgot-password';
  // HOME con mapa integrado
  static const String home = '/home';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    phoneInput: (context) => const PhoneInputScreen(),
    verifyPhone: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final phoneNumber = args?['phoneNumber'] ?? '';
      return VerifyPhoneScreen(phoneNumber: phoneNumber);
    },
    createPassword: (context) => const CreatePasswordScreen(),
    accountSetup: (context) => const AccountSetupScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    // HOME = Mapa principal de la app
    home: (context) => const MapMainScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
