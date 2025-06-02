import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';

// Widget que permite ingresar el código de verificación  (OTP)

class VerificationCodeInput extends StatefulWidget {
  final Function(String)? onChanged;// Callback cuando el código cambia
  final Function(String)? onCompleted;// Callback cuando se completa el código
  final int length;

  const VerificationCodeInput({
    super.key,
    this.onChanged,
    this.onCompleted,
    this.length = 6,
  });

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late List<TextEditingController> _controllers;// Controladores para cada campo de texto
  late List<FocusNode> _focusNodes;// Control del foco para cada campo
  String _code = '';// Código actual ingresado
  @override
  void initState() {
    super.initState();
    // Inicializa listas con controladores y focos por cada dígito
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores y focos
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
  // Se llama cuando el usuario escribe en una caja
  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _controllers[index].text = value; // Actualiza el campo
      _updateCode();// Reconstruye el código completo
      
      // Mueve el foco al siguiente campo si existe
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();// Último campo, quita el foco
      }
    }
  }
  // Detecta teclas presionadas (para detectar backspace) 
  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
         // Si el campo está vacío y no es el primero, salta atrás
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          _updateCode();
        }
      }
    }
  }
  // Actualiza el valor del código actual
  void _updateCode() {
    setState(() {
      // Une el texto de todos los controladores en una sola cadena y la asigna a _code
      _code = _controllers.map((controller) => controller.text).join();
    });
    // Llama al callback onChanged, pasando el código actualizado
    widget.onChanged?.call(_code);

    // Si la longitud del código es igual a la longitud esperada,
    // llama al callback onCompleted 
    if (_code.length == widget.length) {
      widget.onCompleted?.call(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 45,
          height: 56,
          child: RawKeyboardListener(
            focusNode: FocusNode(),// Necesario para detectar teclas
            onKey: (event) => _onKeyPressed(event, index),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,// Solo números
              textAlign: TextAlign.center,
              maxLength: 1,//Permite solo 1 carácter.
              style: AppTextStyles.poppinsHeading3,// Estilo del número
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,// Filtra solo números
              ],
              onChanged: (value) => _onChanged(value, index),
              decoration: InputDecoration(
                counterText: '',// Oculta contador de caracteres
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderActive, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}