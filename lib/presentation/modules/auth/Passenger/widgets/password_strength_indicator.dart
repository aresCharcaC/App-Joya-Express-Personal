import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/core/constants/app_strings.dart';

// Widget que muestra visualmente qué requisitos de contraseña están cumplidos
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  // Constructor
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  // Validaciones de seguridad
  bool get hasMinLength => password.length >= 8; //mínimo 8 caracteres.
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));//al menos un número.
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));//al menos una letra mayúscula.
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));//al menos una letra minúscula.
  // Evalúa si la contraseña cumple todos los criterios.
  bool get isPasswordValid => hasMinLength && hasNumber && hasUppercase && hasLowercase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // Muestra cada requisito con un ícono (cumplido o no)
      children: [
        _buildRequirement(
          AppStrings.passwordRequirements,
          hasMinLength,
        ),
        const SizedBox(height: 4),
        _buildRequirement(
          AppStrings.atLeastOneNumber,
          hasNumber,
        ),
        const SizedBox(height: 4),
        _buildRequirement(
          AppStrings.atLeastOneUppercase,
          hasUppercase,
        ),
        const SizedBox(height: 4),
        _buildRequirement(
          AppStrings.atLeastOneLowercase,
          hasLowercase,
        ),
      ],
    );
  }
 // Widget auxiliar que crea una fila con ícono y texto para un requisito.
  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? AppColors.success : AppColors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.interBodySmall.copyWith(
            color: isMet ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Campo de texto para escribir la contraseña, con validación visual y opción de mostrar/ocultar texto.
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String hintText;
  final String? errorText;

  const PasswordTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Contraseña',
    this.errorText,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;// Para ocultar o mostrar la contraseña
  bool _hasFocus = false;// Para saber si el input tiene foco
  String _password = '';// Guarda el texto actual
  // Validaciones de seguridad similares al widget anterior   
  bool get hasMinLength => _password.length >= 8;
  bool get hasNumber => _password.contains(RegExp(r'[0-9]'));
  bool get hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => _password.contains(RegExp(r'[a-z]'));
  
  bool get isPasswordValid => hasMinLength && hasNumber && hasUppercase && hasLowercase;
  // Define el color del borde dependiendo de errores y validez
  Color get _borderColor {
    if (widget.errorText != null) return AppColors.borderError;
    if (isPasswordValid && _hasFocus) return AppColors.borderActive;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         // Input con ícono para mostrar/ocultar contraseña
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: _isObscured,
            style: AppTextStyles.interInput.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              setState(() {
                _password = value;
              });
              widget.onChanged?.call(value);
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.interInputHint.copyWith(
                color: AppColors.textDisabled.withOpacity(0.6),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderError, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderError, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        // Si hay error, mostrar mensaje de error
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: AppTextStyles.interError,
          ),
        ],
        // Si se está escribiendo una contraseña, mostrar indicadores de seguridad
        if (_password.isNotEmpty) ...[
          const SizedBox(height: 16),
          PasswordStrengthIndicator(password: _password),
        ],
      ],
    );
  }
}