import 'package:flutter/material.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/core/constants/app_strings.dart';
import 'package:joya_express/data/services/auth_persistence_service.dart';
import 'package:joya_express/presentation/modules/auth/Passenger/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/verification_code_input.dart';
import '../widgets/custom_button.dart';

class VerifyPhoneScreen extends StatefulWidget {
  // CAMBIO: Hacer phoneNumber opcional
  final String? phoneNumber;
  const VerifyPhoneScreen({super.key, this.phoneNumber});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  String _code = '';
  int _seconds = 60;
  String _formattedPhone = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Inicializar después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhoneNumber();
    });
  }

  Future<void> _loadPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      // Inicializar ViewModel desde persistencia
      await authViewModel.initializeFromPersistedState();
      
      String? phoneToUse;
      
      // Prioridad: parámetro de navegación > ViewModel > persistencia directa
      if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
        phoneToUse = widget.phoneNumber;
        print('VerifyPhone - Usando teléfono del parámetro: $phoneToUse');
      } else if (authViewModel.currentPhone != null) {
        phoneToUse = authViewModel.currentPhone!.replaceFirst('+51', '');
        print('VerifyPhone - Usando teléfono del ViewModel: $phoneToUse');
      } else {
        // Último recurso: buscar directamente en SharedPreferences
        final authState = await AuthPersistenceService.getAuthFlowState();
        if (authState['phoneNumber'] != null) {
          phoneToUse = authState['phoneNumber']!.replaceFirst('+51', '');
          print('VerifyPhone - Usando teléfono de persistencia: $phoneToUse');
        }
      }

      if (mounted) {
        setState(() {
          if (phoneToUse != null) {
            _formattedPhone = '+51 $phoneToUse';
          } else {
            _formattedPhone = 'Número no disponible';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('VerifyPhone - Error cargando teléfono: $e');
      if (mounted) {
        setState(() {
          _formattedPhone = 'Error cargando número';
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _seconds = 60;
    Future.doWhile(() async {
      if (_seconds > 0 && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _seconds--;
          });
        }
        return true;
      }
      return false;
    });
  }


  Future<void> _resendCode() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Asegurar que tenemos el teléfono
    await authViewModel.initializeFromPersistedState();
    
    if (authViewModel.currentPhone != null) {
      final phone = authViewModel.currentPhone!.replaceFirst('+51', '');
      final success = await authViewModel.sendVerificationCode(phone);
      
      if (success) {
        setState(() {
          _seconds = 60;
        });
        _startTimer();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código reenviado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage ?? 'Error reenviando código'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede reenviar. Reinicia el proceso.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode(AuthViewModel authViewModel) async {
    if (_code.length != 6) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await authViewModel.verifyCode(_code);
      
      if (mounted) {
        if (success) {
          // Obtener el teléfono para pasar a la siguiente pantalla
          final phoneToPass = authViewModel.currentPhone?.replaceFirst('+51', '') ?? '';
          Navigator.pushNamed(context, '/create-password', arguments: phoneToPass);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage ?? 'Código incorrecto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('VerifyPhone - Error verificando código: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error verificando código. Intenta nuevamente.'),
            backgroundColor: Colors.red,
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
    final bool isCodeValid = _code.length == 6;
    
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
              AppStrings.verifyPhoneTitle,
              style: AppTextStyles.poppinsHeading2,
            ),
            const SizedBox(height: 4),
            _buildSubtitle(),
            const SizedBox(height: 32),
            VerificationCodeInput(
              length: 6,
              onChanged: (value) {
                setState(() {
                  _code = value;
                });
              },
              onCompleted: (value) {
                setState(() {
                  _code = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildResendSection(),
            const Spacer(),
            CustomButton(
              text: AppStrings.verifyCode,
              isEnabled: isCodeValid && !_isLoading,
              isLoading: _isLoading,
              backgroundColor: isCodeValid ? AppColors.secondary : AppColors.buttonDisabled,
              textColor: isCodeValid ? AppColors.white : AppColors.buttonTextDisabled,
              onPressed: isCodeValid && !_isLoading ? () => _verifyCode(authViewModel) : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppStrings.verifyPhoneTitle,
      style: AppTextStyles.poppinsHeading2,
    );
  }

  Widget _buildSubtitle() {
    if (_isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Cargando número...',
            style: AppTextStyles.interBodySmall,
          ),
        ],
      );
    }
    
    if (_formattedPhone.isEmpty || _formattedPhone == 'Número no disponible') {
      return Text(
        'No se pudo cargar el número de teléfono',
        style: AppTextStyles.interBodySmall.copyWith(color: Colors.red),
      );
    }
    
    return RichText(
      text: TextSpan(
        style: AppTextStyles.interBodySmall,
        children: [
          const TextSpan(text: 'Ingresa el código enviado a '),
          TextSpan(
            text: _formattedPhone,
            style: AppTextStyles.interLink.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInput() {
    return VerificationCodeInput(
      length: 6,
      onChanged: (value) {
        setState(() {
          _code = value;
        });
      },
      onCompleted: (value) {
        setState(() {
          _code = value;
        });
      },
    );
  }

   Widget _buildResendSection() {
    return _seconds > 0
        ? Text(
            'Reenviar código en ${_seconds}s',
            style: AppTextStyles.interBodySmall,
          )
        : GestureDetector(
            onTap: _resendCode,
            child: Text(
              'Reenviar código',
              style: AppTextStyles.interLink,
            ),
          );
  }

  Widget _buildVerifyButton(bool isCodeValid, AuthViewModel authViewModel) {
    return CustomButton(
      text: AppStrings.verifyCode,
      isEnabled: isCodeValid,
      backgroundColor: isCodeValid ? AppColors.secondary : AppColors.buttonDisabled,
      textColor: isCodeValid ? AppColors.white : AppColors.buttonTextDisabled,
      onPressed: isCodeValid ? () => _verifyCode(authViewModel) : null,
    );
  }
}