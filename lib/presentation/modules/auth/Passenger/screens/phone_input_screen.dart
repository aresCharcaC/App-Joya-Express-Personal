import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/viewmodels/auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/widgets/phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Pantalla para que el usuario ingrese su número de teléfono

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _controller = TextEditingController();
  int _digitCount = 0;

  bool get isValid => _digitCount == 9;

   @override
  void initState() {
    super.initState();
    // Recuperar estado al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPersistedState();
    });
  }

  Future<void> _checkForPersistedState() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.initializeFromPersistedState();
    
    // Si hay un teléfono persistido, prellenar el campo
    if (authViewModel.currentPhone != null) {
      final phone = authViewModel.currentPhone!.replaceFirst('+51', '');
      _controller.text = phone;
      _onPhoneChanged(phone);
    }
  }

  void _onPhoneChanged(String value) {
    // Actualiza el contador de dígitos
    final newCount = value.replaceAll(RegExp(r'[^0-9]'), '').length;
    setState(() {
      _digitCount = newCount;
    });
  }

  Future<void> _onSendCode(AuthViewModel authViewModel) async {
  final success = await authViewModel.sendVerificationCode(_controller.text);
  if (success) {
    // Si hay URL de WhatsApp, redirige
    final whatsappUrl = authViewModel.sendCodeResponse?.whatsapp.url;
    if (whatsappUrl != null) {
      await savePhoneNumber(_controller.text);
      await launchUrl(Uri.parse(whatsappUrl));
    }
    // Luego navega a la pantalla de verificación
    Navigator.pushNamed(
    context,
    '/verify-phone',
    // arguments: {'phoneNumber': _controller.text},
  );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authViewModel.errorMessage ?? 'Error al enviar código')),
    );
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> savePhoneNumber(String phone) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pending_phone', phone);
}

  @override
  Widget build(BuildContext context) {
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
            Text(
              AppStrings.enterPhoneTitle,
              style: AppTextStyles.poppinsHeading2,
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.phoneSubtitle,
              style: AppTextStyles.interBodySmall,
            ),
            const SizedBox(height: 32),
            // Usamos PhoneNumberInput aquí
            PhoneNumberInput(
              controller: _controller,
              onChanged: _onPhoneChanged,
              enabled: true,
            ),
            const SizedBox(height: 32),
            // Contador grande centrado
            Center(
              child: Text(
                '$_digitCount',
                style: AppTextStyles.poppinsHeading2.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Spacer(),
            // Botón de envío
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid ? AppColors.secondary : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: isValid
                    ? () => _onSendCode(authViewModel)
                    : null,
                child: Text(
                  AppStrings.sendCode,
                  style: AppTextStyles.poppinsButton.copyWith(
                    color: isValid
                        ? AppColors.textPrimary
                        : AppColors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}