import 'package:flutter/material.dart';
import 'package:joya_express/presentation/modules/auth/Driver/screens/driver_home_screen.dart';
import 'package:joya_express/presentation/modules/auth/Driver/screens/driver_login_screen.dart';
import 'package:joya_express/presentation/modules/auth/Driver/screens/driver_pending_approval_screen.dart';
import 'package:joya_express/presentation/modules/auth/Driver/screens/driver_profile_screen.dart';
import 'package:joya_express/presentation/modules/auth/Driver/screens/driver_register_screen.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/screens/phone_verification_screen.dart';
import 'package:joya_express/presentation/modules/profile/Passenger/screens/profile_screen.dart';
import '../auth/Passenger/screens/login_screen.dart';
import '../auth/Passenger/screens/phone_input_screen.dart';
import '../auth/Passenger/screens/create_password_screen.dart';
import '../auth/Passenger/screens/account_setup_screen.dart';
import '../auth/Passenger/screens/forgot_password_screen.dart';
import '../auth/Passenger/screens/welcome_screen.dart';
import '../home/screens/home_screen.dart';

class AppRoutes {
  // RUTAS DE PASAJERO
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

  // RUTAS DE CONDUCTOR
  static const String driverLogin = '/driver-login';
  static const String driverRegister = '/driver-register';
  static const String driverPendingApproval = '/driver-pending-approval'; 
  static const String driverHome = '/driver-home';
  static const String driverProfile = '/driver-profile';

  

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

    // RUTAS DE CONDUCTOR
    driverLogin: (context) => DriverLoginScreen(),
    driverRegister: (context) => DriverRegisterScreen(),
    driverPendingApproval: (context) => DriverPendingApprovalScreen(),
    driverHome: (context) => DriverHomeScreen(),
    driverProfile: (context) => DriverProfileScreen(),
  };
}


