import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/presentation/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/password_strength_indicator.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});
  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String _password = '';

  // Validaciones usando las mismas reglas que el widget PasswordTextField
  bool get hasMinLength => _password.length >= 8;
  bool get hasNumber => _password.contains(RegExp(r'[0-9]'));
  bool get hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => _password.contains(RegExp(r'[a-z]'));
  
  bool get isPasswordValid => hasMinLength && hasNumber && hasUppercase && hasLowercase;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _goToAccountSetup(AuthViewModel authViewModel) {
    authViewModel.saveTempPassword(_passwordController.text);
    Navigator.pushNamed(context, '/account-setup');
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el ViewModel de autenticación usando Provider
    final authViewModel = Provider.of<AuthViewModel>(context);
    // Escucha los cambios en el estado del ViewModel
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
            // Título usando constantes de strings y estilos
            Text(
              AppStrings.createPasswordTitle,
              style: AppTextStyles.poppinsHeading2,
            ),
            const SizedBox(height: 4),
            // Subtítulo usando constantes
            Text(
              AppStrings.createPasswordSubtitle,
              style: AppTextStyles.interBodySmall,
            ),
            const SizedBox(height: 32),
            // Campo de contraseña personalizado que incluye validación y indicadores
            PasswordTextField(
              controller: _passwordController,
              hintText: 'Password01',
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
            ),
            const SizedBox(height: 32),
            // Botón usando las constantes de colores y estilos
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPasswordValid 
                      ? AppColors.secondary 
                      : AppColors.buttonDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: isPasswordValid
                    ? () => _goToAccountSetup(authViewModel)
                    : null,
                child: Text(
                  AppStrings.createPasswordButton,
                  style: isPasswordValid 
                      ? AppTextStyles.poppinsButton.copyWith(color: AppColors.textPrimary)
                      : AppTextStyles.poppinsButtonDisabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}