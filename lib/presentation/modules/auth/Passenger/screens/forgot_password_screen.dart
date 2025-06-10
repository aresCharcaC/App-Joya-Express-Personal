import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset() {
    setState(() {
      _sent = true;
    });
    // Aquí puedes agregar la lógica real para enviar el correo de recuperación
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 16),
            Text(
              '¿Olvidaste tu contraseña?',
              style: AppTextStyles.poppinsHeading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Porfavor ingresa tu numero para restablecer tu contraseña',
              style: AppTextStyles.interBodySmall,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Ingresa tu numero',
                filled: true,
                fillColor: AppColors.greyLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                hintStyle: AppTextStyles.interBodySmall,
              ),
              style: AppTextStyles.interBodySmall,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _sent ? null : _sendReset,
                child: Text(
                  _sent ? 'Mensaje enviado' : 'Enviar Codigo',
                  style: AppTextStyles.poppinsButton,
                ),
              ),
            ),
            if (_sent)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'Revisa tu Whastapp para restablecer tu contraseña',
                  style: AppTextStyles.interBodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}