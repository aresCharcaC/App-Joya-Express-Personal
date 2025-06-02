import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/presentation/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables para manejar el estado de validación
  String? _numberError;
  String? _passwordError;
  bool _isLoading = false;
  
  // Variables para controlar cuándo mostrar validación
  bool _numberTouched = false;
  bool _passwordTouched = false;

  // Getters para validar campos en tiempo real
  bool get isNumberValid => _numberController.text.length >= 8;
  bool get isPasswordValid => _passwordController.text.length >= 6;
  bool get isFormValid => isNumberValid && isPasswordValid;
  
  // Getters para determinar cuándo mostrar errores
  bool get shouldShowNumberError => _numberTouched && _numberError != null;
  bool get shouldShowPasswordError => _passwordTouched && _passwordError != null;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Navegar a la pantalla de recuperación de contraseña
  void _goToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  // Marcar campo como tocado cuando el usuario interactúa
  void _onNumberFocusChange(bool hasFocus) {
    if (!hasFocus && !_numberTouched) {
      setState(() {
        _numberTouched = true;
      });
      _validateNumber(_numberController.text);
    }
  }

  void _onPasswordFocusChange(bool hasFocus) {
    if (!hasFocus && !_passwordTouched) {
      setState(() {
        _passwordTouched = true;
      });
      _validatePassword(_passwordController.text);
    }
  }

  // Validar el campo de número de teléfono
  void _validateNumber(String value) {
    setState(() {
      _numberTouched = true; // ← Marca como tocado al escribir
      if (value.isEmpty) {
        _numberError = AppStrings.phoneRequired;
      } else if (value.length < 8) {
        _numberError = AppStrings.invalidPhone;
      } else {
        _numberError = null;
      }
    });
  }

  // Validar el campo de contraseña
    void _validatePassword(String value) {
    setState(() {
      _passwordTouched = true; // ← Marca como tocado al escribir
      if (value.isEmpty) {
        _passwordError = AppStrings.passwordRequired;
      } else if (value.length < 6) {
        _passwordError = AppStrings.passwordTooShort;
      } else {
        _passwordError = null;
      }
    });
  }

  // Lógica de inicio de sesión
  void _login(AuthViewModel authViewModel) async {
    // Marcar todos los campos como tocados para mostrar errores
    setState(() {
      _numberTouched = true;
      _passwordTouched = true;
    });

    // Validar campos antes de proceder
    _validateNumber(_numberController.text);
    _validatePassword(_passwordController.text);

    // Solo proceder si el formulario es válido
    if (!isFormValid || shouldShowNumberError || shouldShowPasswordError) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
    final success = await authViewModel.login(
      _numberController.text,
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? AppStrings.invalidCredentials),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // Obtener el ViewModel de autenticación
      final authViewModel = Provider.of<AuthViewModel>(context);
      // Escuchar los cambios en el estado del ViewModel
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            // Título de la pantalla usando constante y estilo predefinido
            Text(
              AppStrings.loginTitle,
              style: AppTextStyles.poppinsHeading2,
            ),
            const SizedBox(height: 24),
            
            // Campo de número de teléfono con validación suave
            Focus(
              onFocusChange: _onNumberFocusChange,
              child: CustomTextField(
                hintText: AppStrings.phoneNumber,
                controller: _numberController,
                keyboardType: TextInputType.number,
                onChanged: _validateNumber,
                errorText: shouldShowNumberError ? _numberError : null,
                isValid: !shouldShowNumberError,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Campo de contraseña con validación suave
            Focus(
              onFocusChange: _onPasswordFocusChange,
              child: CustomTextField(
                hintText: AppStrings.password,
                controller: _passwordController,
                obscureText: true,
                showVisibilityToggle: true,
                onChanged: _validatePassword,
                errorText: shouldShowPasswordError ? _passwordError : null,
                isValid: !shouldShowPasswordError,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Enlace para recuperar contraseña
            Row(
              children: [
                const Icon(
                  Icons.info_outline, 
                  color: AppColors.info, 
                  size: 18,
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _goToForgotPassword,
                  child: Text(
                    AppStrings.forgotPassword,
                    style: AppTextStyles.interLink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Botón de inicio de sesión usando CustomButton
            CustomButton(
              text: AppStrings.loginButton,
              onPressed: isFormValid ? () => _login(authViewModel) : null,
              isEnabled: isFormValid,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}