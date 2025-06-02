import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';


/*
Permite al usuario ingresar un número de celular peruano (de 9 dígitos) con formato validado, mostrando el código de país "+51",
un contador de dígitos y retroalimentación visual según el estado del campo (foco, error o completado).
*/ 
class PhoneNumberInput extends StatefulWidget {
  // Controlador para acceder o modificar el texto desde fuera.
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? errorText;// Texto de error para mostrar debajo del campo.
  final bool enabled;

  const PhoneNumberInput({
    super.key,
    this.controller,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  bool _hasFocus = false;// Indica si el campo tiene foco.
  int _digitCount = 0;// Cuenta los dígitos ingresados por el usuario.

  @override
  void initState() {
    super.initState();
    // Escucha los cambios del controlador para contar dígitos.
    if (widget.controller != null) {
      widget.controller!.addListener(_updateDigitCount);
      _updateDigitCount();
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_updateDigitCount);
    }
    super.dispose();
  }
  // Actualiza el número de dígitos reales (solo números).
  void _updateDigitCount() {
    final text = widget.controller?.text ?? '';
    final newCount = text.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (newCount != _digitCount) {
      setState(() {
        _digitCount = newCount;
      });
    }
  }
 // Define el color del borde según el estado.
  Color get _borderColor {
    if (!widget.enabled) return AppColors.border; // Si no está habilitado
    if (widget.errorText != null) return AppColors.borderError; // Si hay un error
    if (_digitCount == 9 && _hasFocus) return AppColors.borderActive; // Si está completo y tiene foco
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detecta si el campo tiene o no el foco.
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;// Actualiza el estado del foco
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderColor,
                width: _hasFocus ? 2 : 1, // Ancho del borde cambia si tiene foco true =2 y false =1
              ),
            ),
            child: Row(
              children: [
                // Sección del código de país + bandera
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bandera de Perú como emoji
                      const Text('🇵🇪', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),// Espacio entre bandera y código
                      Text(
                        '+51',
                        style: AppTextStyles.interInput,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.border,
                      ),
                    ],
                  ),
                ),
                // Campo de entrada de número
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,// Solo números
                      LengthLimitingTextInputFormatter(9), // Máximo 9 dígitos
                      PhoneNumberFormatter(),// Validador personalizado
                    ],
                    onChanged: widget.onChanged,
                    enabled: widget.enabled,
                    style: AppTextStyles.interInput,
                    decoration: InputDecoration(
                      hintText: 'Numero',
                      hintStyle: AppTextStyles.interInputHint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                // Contador de dígitos ingresados
                if (_digitCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '$_digitCount',
                      style: AppTextStyles.interCaption.copyWith(
                        color: _digitCount == 9 
                            ? AppColors.success 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Texto de error si existe
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
//Restringe la entrada a números y limita la longitud a 9 dígitos.
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;
    if (newText.length <= 9) {
      return newValue;
    }
    return oldValue;
  }
}