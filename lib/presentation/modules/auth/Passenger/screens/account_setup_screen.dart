import 'dart:io';
import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/profile_image_picker.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  
  // Estados de validación
  String? _nameError;
  String? _emailError;
  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isLoading = false;
  
  // Imagen de perfil seleccionada
  File? _profileImage;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Validación del nombre completo
  void _validateName(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _nameError = AppStrings.nameRequired;
        _isNameValid = false;
      } else if (value.trim().length < 2) {
        _nameError = 'El nombre debe tener al menos 2 caracteres';
        _isNameValid = false;
      } else {
        _nameError = null;
        _isNameValid = true;
      }
    });
  }

  // Validación del email
  void _validateEmail(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _emailError = 'El email es requerido';
        _isEmailValid = false;
      } else if (!_isValidEmail(value)) {
        _emailError = AppStrings.invalidEmail;
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  // Verifica si el formato del email es válido
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Verifica si el formulario es válido para habilitar el botón
  bool get _isFormValid {
    return _isNameValid && 
           _isEmailValid && 
           _nameController.text.trim().isNotEmpty && 
           _emailController.text.trim().isNotEmpty;
  }

  // Maneja la selección de imagen de perfil
  void _onImageSelected(File? image) {
    setState(() {
      _profileImage = image;
    });
  }

  // Procesa el formulario cuando se presiona "Empezar"
  Future<void> _handleSubmit(AuthViewModel authViewModel) async {
  _validateName(_nameController.text);
  _validateEmail(_emailController.text);

  if (!_isFormValid) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // Llama al método de registro del ViewModel usando los datos temporales
     final success = await authViewModel.register(
        password: authViewModel.tempPassword ?? '',
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profilePhoto: authViewModel.profilePhotoPath, // Puede ser local o URL
      );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta configurada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        // Redirige a la pantalla de Home
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false, // Elimina todas las rutas anteriores
          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Error al configurar la cuenta'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al configurar la cuenta'),
          backgroundColor: AppColors.error,
        ),
      );
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
     final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      // Permite que el body se redimensione cuando aparece el teclado
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Permite scroll cuando el contenido no cabe
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Título y subtítulo usando constantes de AppStrings
              Text(
                AppStrings.setupAccountTitle,
                style: AppTextStyles.poppinsHeading2,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.setupAccountSubtitle,
                style: AppTextStyles.interBodySmall,
              ),
              
              // Espaciado responsivo que se reduce cuando aparece el teclado
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 32),
              
              // Widget personalizado para selección de imagen de perfil
              Center(
                child: ProfileImagePicker(
                  // Tamaño más pequeño cuando el teclado está activo
                  size: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 140,
                  onImageSelected: (image) {
                    _onImageSelected(image); // Mantienes tu lógica local
                    if (image != null) {
                      authViewModel.saveProfilePhoto(image.path); // Guardas en el ViewModel
                    }
                  },
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 32),
            
            // Campo de texto personalizado para nombre completo
            CustomTextField(
              controller: _nameController,
              hintText: AppStrings.fullName,
              labelText: AppStrings.fullName,
              keyboardType: TextInputType.name,
              errorText: _nameError,
              isValid: _isNameValid,
              onChanged: _validateName,
              prefixIcon: const Icon(
                Icons.person_outline,
                color: AppColors.grey,
              ),
            ),
              
              const SizedBox(height: 16),
              
              // Campo de texto personalizado para email
              CustomTextField(
                controller: _emailController,
                hintText: AppStrings.email,
                labelText: AppStrings.email,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                isValid: _isEmailValid,
                onChanged: _validateEmail,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botón personalizado que se habilita solo cuando el formulario es válido
              CustomButton(
                text: AppStrings.startButton,
                onPressed: _isFormValid ? () => _handleSubmit(authViewModel) : null,
                isEnabled: _isFormValid,
                isLoading: _isLoading,
              ),
              
              // Espaciado extra para evitar que el botón quede pegado al borde
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 32),
            ],
          ),
        ),
      ),
    );
  }
}