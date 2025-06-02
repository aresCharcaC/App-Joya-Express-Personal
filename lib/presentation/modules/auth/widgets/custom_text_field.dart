import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

// Widget personalizado de campo de texto con múltiples opciones y validación
class CustomTextField extends StatefulWidget {
  final String hintText;// Texto de sugerencia dentro del campo
  final TextEditingController? controller;// Controlador para manejar el texto
  final bool obscureText;// Oculta el texto (para contraseñas)
  final bool showVisibilityToggle;// Muestra botón para alternar visibilidad del texto
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? errorText;
  final bool isValid;
  final Widget? prefixIcon;// Icono al inicio del campo
  final Widget? suffixIcon;// Icono al final del campo (si no hay toggle de visibilidad)
  final int? maxLength;
  final bool enabled;
  final String? labelText;// Etiqueta mostrada arriba del campo
  final double borderRadius;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.errorText,
    this.isValid = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.enabled = true,
    this.labelText,
    this.borderRadius = 12,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;// Estado interno para ocultar texto
  bool _hasFocus = false;// Estado interno para saber si el campo tiene foco

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;// Inicializa ocultación según propiedad
  }
// Determina el color del borde según estado (habilitado, error, foco, válido)
  Color get _borderColor {
    if (!widget.enabled) return AppColors.border;
    if (widget.errorText != null) return AppColors.borderError;
    if (widget.isValid && _hasFocus) return AppColors.borderActive;
    if (!widget.isValid) return AppColors.borderError;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muestra etiqueta si se proporciona
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.interBodySmall,
          ),
          const SizedBox(height: 8),
        ],
         // Widget Focus para detectar cambios de foco y actualizar estado
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
             // Oculta texto si se requiere y se muestra toggle
            obscureText: widget.showVisibilityToggle ? _isObscured : widget.obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            style: AppTextStyles.interInput,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.interInputHint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.showVisibilityToggle
                  ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor: widget.enabled ? AppColors.surface : AppColors.greyLight,
              // Bordes con color dinámico según estado
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: _borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: _borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(color: AppColors.borderError, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(color: AppColors.borderError, width: 2),
              ),
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        // Muestra texto de error 
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: AppTextStyles.interError,
          ),
        ],
      ],
    );
  }
}