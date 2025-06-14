import 'package:flutter/material.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/constants/app_colors.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en los campos para validar el formulario
    _dniController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final dni = _dniController.text.trim();
    final password = _passwordController.text.trim();
    
    final isValid = dni.isNotEmpty && 
                   dni.length == 8 && 
                   RegExp(r'^\d+$').hasMatch(dni) &&
                   password.isNotEmpty && 
                   password.length >= 6;
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) return;
    
    // Ocultar teclado
    FocusScope.of(context).unfocus();
    
    try {
      final viewModel = context.read<DriverAuthViewModel>();
      
      // Limpiar errores previos
      viewModel.clearError();
      
      final success = await viewModel.login(
        _dniController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        if (success) {
          // Navegación exitosa
          Navigator.pushReplacementNamed(context, '/driver-home');
        } else {
          // Mostrar error si existe
          final error = viewModel.error;
          if (error != null) {
            _showErrorSnackBar(error);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error inesperado: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<DriverAuthViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Imagen de fondo
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/driver.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Overlay con gradiente
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary.withOpacity(0.6),
                      AppColors.primary.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              
              // Header con logo y texto - Ocupa el 30% superior
              if (!isKeyboardOpen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * 0.3,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo o texto principal
                          Text(
                            'EN',
                            style: AppTextStyles.poppinsHeading1.copyWith(
                              color: AppColors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            'JOYA',
                            style: AppTextStyles.poppinsHeading1.copyWith(
                              color: AppColors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          Text(
                            'EXPRESS',
                            style: AppTextStyles.poppinsHeading1.copyWith(
                              color: AppColors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Texto descriptivo
                          Text(
                            'Somos la fuerza que impulsa la región',
                            style: AppTextStyles.interBody.copyWith(
                              color: AppColors.white,
                              fontSize: 14,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Modal de login - Ocupa el 70% inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: isKeyboardOpen ? screenHeight * 0.85 : screenHeight * 0.7,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 32,
                        right: 32,
                        top: 32,
                        bottom: 32 + (isKeyboardOpen ? keyboardHeight * 0.1 : 0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header del modal con botón de retroceso
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  'Bienvenido Conductor',
                                  style: AppTextStyles.poppinsHeading2.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isKeyboardOpen ? 24 : 40),
                        
                          // Campo DNI
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _dniController,
                              decoration: InputDecoration(
                                hintText: 'Dni',
                                hintStyle: AppTextStyles.interInputHint.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.error,
                                    width: 1,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.greyLight,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                              ),
                              style: AppTextStyles.interInput,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingrese su DNI';
                                }
                                if (value.trim().length != 8) {
                                  return 'El DNI debe tener 8 dígitos';
                                }
                                if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                                  return 'El DNI solo debe contener números';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Campo Contraseña
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Contraseña',
                                hintStyle: AppTextStyles.interInputHint.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: AppColors.error,
                                    width: 1,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.greyLight,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                              ),
                              style: AppTextStyles.interInput,
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                if (value.trim().length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Botón de Login
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: (_isFormValid && !viewModel.isLoading) ? _login : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: const Color.fromARGB(255, 246, 134, 134),
                                disabledForegroundColor: const Color.fromARGB(255, 249, 224, 224),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Iniciar Sesion',
                                      style: AppTextStyles.poppinsButton.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                            
                          SizedBox(height: isKeyboardOpen ? 16 : 32),
                          
                          // Enlace de registro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aun no estas registrado? ',
                                style: AppTextStyles.interBodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/driver-register');
                                },
                                child: Text(
                                  'Únete Ahora',
                                  style: AppTextStyles.interLink.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isKeyboardOpen ? 20 : 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
//Hace falta desacoplar esta pantalla 