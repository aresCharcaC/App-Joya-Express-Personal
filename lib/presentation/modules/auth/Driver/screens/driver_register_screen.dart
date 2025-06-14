import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joya_express/core/constants/app_colors.dart';
import 'package:joya_express/core/constants/app_text_styles.dart';
import 'package:joya_express/presentation/modules/auth/Driver/viewmodels/driver_auth_viewmodel.dart';
import 'package:joya_express/presentation/modules/routes/app_routes.dart';

import 'package:provider/provider.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  _DriverRegisterScreenState createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  // Controladores para los campos del formulario
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _placaController = TextEditingController();
  final _picker = ImagePicker();

  // Variables para controlar qué campos están expandidos
  String? _expandedField;

  // Variable para controlar la visibilidad de la contraseña
  bool _obscurePassword = true;

  // Variables para almacenar las URLs de las imágenes subidas
  String? _fotoBreveteUrl =
      "https://via.placeholder.com/400x300/007bff/ffffff?text=BREVETE+TEST";
  String? _fotoPerfilUrl;
  String? _fotoLateralUrl;

  // Variables para almacenar el estado de validación en tiempo real
  Map<String, List<ValidationRule>> _validationStates = {
    'dni': [],
    'nombre': [],
    'telefono': [],
    'password': [],
    'placa': [],
  };

  @override
  void initState() {
    super.initState();
    _initializeValidationRules();
    _setupRealTimeValidation();
  }

  void _initializeValidationRules() {
    _validationStates = {
      'dni': [
        ValidationRule('Debe tener 8 dígitos', false),
        ValidationRule('Solo números', false),
      ],
      'nombre': [
        ValidationRule('Mínimo 2 palabras', false),
        ValidationRule('Solo letras y espacios', false),
      ],
      'telefono': [
        ValidationRule('Mínimo 9 dígitos', false),
        ValidationRule('Formato válido', false),
      ],
      'password': [
        ValidationRule('Mínimo 6 caracteres', false),
        ValidationRule('Al menos una mayúscula', false),
        ValidationRule('Al menos un número', false),
      ],
      'placa': [
        ValidationRule('Formato ABC-123', false),
        ValidationRule('3 letras + 3 números', false),
      ],
    };
  }

  void _setupRealTimeValidation() {
    _dniController.addListener(
      () => _validateField('dni', _dniController.text),
    );
    _nombreController.addListener(
      () => _validateField('nombre', _nombreController.text),
    );
    _telefonoController.addListener(
      () => _validateField('telefono', _telefonoController.text),
    );
    _passwordController.addListener(
      () => _validateField('password', _passwordController.text),
    );
    _placaController.addListener(
      () => _validateField('placa', _placaController.text),
    );
  }

  void _validateField(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case 'dni':
          _validationStates['dni']![0].isValid = value.length == 8;
          _validationStates['dni']![1].isValid = RegExp(
            r'^\d+$',
          ).hasMatch(value);
          break;
        case 'nombre':
          _validationStates['nombre']![0].isValid =
              value.trim().split(' ').length >= 2;
          _validationStates['nombre']![1].isValid = RegExp(
            r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$',
          ).hasMatch(value);
          break;
        case 'telefono':
          _validationStates['telefono']![0].isValid = value.length >= 9;
          _validationStates['telefono']![1].isValid = RegExp(
            r'^[+]?[0-9\s-()]+$',
          ).hasMatch(value);
          break;
        case 'password':
          _validationStates['password']![0].isValid = value.length >= 6;
          _validationStates['password']![1].isValid = RegExp(
            r'[A-Z]',
          ).hasMatch(value);
          _validationStates['password']![2].isValid = RegExp(
            r'[0-9]',
          ).hasMatch(value);
          break;
        case 'placa':
          _validationStates['placa']![0].isValid = RegExp(
            r'^[A-Z]{3}-[0-9]{3}$',
          ).hasMatch(value.toUpperCase());
          _validationStates['placa']![1].isValid = RegExp(
            r'^[A-Z]{3}-[0-9]{3}$',
          ).hasMatch(value.toUpperCase());
          break;
      }
    });
  }

  bool _isFieldValid(String fieldName) {
    return _validationStates[fieldName]?.every((rule) => rule.isValid) ?? false;
  }

  /// Permite al usuario seleccionar una imagen desde galería o cámara,
  /// la sube usando el ViewModel y guarda la URL resultante.
  Future<void> _pickImage(String type) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Seleccionar imagen',
            style: AppTextStyles.poppinsHeading3,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogOption(
                icon: Icons.photo_library,
                text: 'Galería',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              SizedBox(height: 12),
              _buildDialogOption(
                icon: Icons.camera_alt,
                text: 'Cámara',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        try {
          final viewModel = context.read<DriverAuthViewModel>();

          // Mostrar loading mientras se sube
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Subiendo imagen...',
                style: AppTextStyles.interBody,
              ),
              backgroundColor: AppColors.info,
            ),
          );

          final url = await viewModel.uploadFile(image.path, type);

          if (url != null) {
            setState(() {
              switch (type) {
                case 'brevete':
                  _fotoBreveteUrl = url;
                  break;
                case 'perfil':
                  _fotoPerfilUrl = url;
                  break;
                case 'lateral':
                  _fotoLateralUrl = url;
                  break;
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Imagen subida exitosamente',
                  style: AppTextStyles.interBody,
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al subir imagen',
                  style: AppTextStyles.interBody,
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } catch (e) {
          print('Error al subir imagen: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al subir imagen: $e',
                style: AppTextStyles.interBody,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Envía el formulario de registro.
  /// Valida los campos y llama al método register del ViewModel.
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fotoBreveteUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Foto de brevete requerida',
            style: AppTextStyles.interBody,
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final viewModel = context.read<DriverAuthViewModel>();
    final success = await viewModel.register(
      dni: _dniController.text,
      nombreCompleto: _nombreController.text,
      telefono: _telefonoController.text,
      password: _passwordController.text,
      placa: _placaController.text,
      fotoBrevete: _fotoBreveteUrl!,
      fotoPerfil: _fotoPerfilUrl,
      fotoLateral: _fotoLateralUrl,
    );

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.driverPendingApproval);
    } else if (viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.error!, style: AppTextStyles.interBody),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DriverAuthViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Imagen de fondo con gradiente
              _buildBackgroundImage(),

              // Modal al 80% con contenido
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 1,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header del modal
                      _buildModalHeader(),

                      // Contenido scrolleable
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 24),

                                // Campos del formulario expandibles
                                _buildExpandableField(
                                  fieldKey: 'dni',
                                  label: 'DNI',
                                  icon: Icons.credit_card,
                                  controller: _dniController,
                                  hint: 'Ingresa tu DNI',
                                  keyboardType: TextInputType.number,
                                  maxLength: 8,
                                ),

                                SizedBox(height: 16),

                                _buildExpandableField(
                                  fieldKey: 'nombre',
                                  label: 'Nombre Completo',
                                  icon: Icons.person,
                                  controller: _nombreController,
                                  hint: 'Ingresa tu nombre completo',
                                ),

                                SizedBox(height: 16),

                                _buildExpandableField(
                                  fieldKey: 'telefono',
                                  label: 'Teléfono',
                                  icon: Icons.phone,
                                  controller: _telefonoController,
                                  hint: 'Ingresa tu teléfono',
                                  keyboardType: TextInputType.phone,
                                ),

                                SizedBox(height: 16),

                                _buildExpandableField(
                                  fieldKey: 'password',
                                  label: 'Contraseña',
                                  icon: Icons.lock,
                                  controller: _passwordController,
                                  hint: 'Crea una contraseña segura',
                                  obscureText: _obscurePassword,
                                  showPasswordToggle: true,
                                ),

                                SizedBox(height: 16),

                                _buildExpandableField(
                                  fieldKey: 'placa',
                                  label: 'Placa del vehículo',
                                  icon: Icons.directions_car,
                                  controller: _placaController,
                                  hint: 'Ej: ABC-123',
                                ),

                                SizedBox(height: 24),

                                // Sección de imágenes
                                _buildImageSection(),

                                SizedBox(height: 32),

                                // Botón de registro
                                _buildRegisterButton(viewModel),

                                SizedBox(height: 16),

                                // Link para iniciar sesión
                                _buildLoginLink(),

                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loader mientras se realiza una operación
              if (viewModel.isLoading)
                Container(
                  color: AppColors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
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

  Widget _buildExpandableField({
    required String fieldKey,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    bool showPasswordToggle = false,
  }) {
    final isExpanded = _expandedField == fieldKey;
    final isValid = _isFieldValid(fieldKey);
    final hasContent = controller.text.isNotEmpty;

    return Column(
      children: [
        // Botón expandible
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedField = isExpanded ? null : fieldKey;
            });
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isExpanded
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.greyLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isExpanded
                        ? AppColors.primary
                        : hasContent
                        ? (isValid ? AppColors.success : AppColors.error)
                        : AppColors.border,
                width: isExpanded ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color:
                      isExpanded
                          ? AppColors.primary
                          : hasContent
                          ? (isValid ? AppColors.success : AppColors.error)
                          : AppColors.textSecondary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.interBody.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              isExpanded
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                      if (hasContent && !isExpanded)
                        Text(
                          _getFieldPreview(fieldKey, controller.text),
                          style: AppTextStyles.interCaption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasContent && !isExpanded)
                  Icon(
                    isValid ? Icons.check_circle : Icons.error,
                    color: isValid ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Campo expandido con validación
        if (isExpanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo de texto
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                  obscureText: obscureText,
                  style: AppTextStyles.interInput,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.interInputHint,
                    filled: true,
                    fillColor: AppColors.greyLight.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    counterText: '',
                    suffixIcon:
                        showPasswordToggle
                            ? IconButton(
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            )
                            : null,
                  ),
                  validator:
                      (value) => _validateFieldForSubmit(fieldKey, value),
                ),

                SizedBox(height: 12),

                // Checklist de validación
                _buildValidationChecklist(fieldKey),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildValidationChecklist(String fieldKey) {
    final rules = _validationStates[fieldKey] ?? [];

    if (rules.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Requisitos:',
                style: AppTextStyles.interCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...rules
              .map(
                (rule) => Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        child: Icon(
                          rule.isValid
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color:
                              rule.isValid
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rule.message,
                          style: AppTextStyles.interCaption.copyWith(
                            color:
                                rule.isValid
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                            decoration:
                                rule.isValid
                                    ? TextDecoration.lineThrough
                                    : null,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          ...rules.map((rule) => Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2),
                  child: Icon(
                    rule.isValid ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: rule.isValid ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.message,
                    style: AppTextStyles.interCaption.copyWith(
                      color: rule.isValid ? AppColors.success : AppColors.textSecondary,
                      decoration: rule.isValid ? TextDecoration.lineThrough : null,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getFieldPreview(String fieldKey, String value) {
    switch (fieldKey) {
      case 'dni':
        return value.length == 8 ? '••••${value.substring(4)}' : value;
      case 'password':
        return '••••••••';
      default:
        return value.length > 20 ? '${value.substring(0, 20)}...' : value;
    }
  }

  String? _validateFieldForSubmit(String fieldKey, String? value) {
    if (value?.isEmpty ?? true) {
      return '${_getFieldLabel(fieldKey)} requerido';
    }

    if (!_isFieldValid(fieldKey)) {
      return 'Completa todos los requisitos';
    }

    return null;
  }

  String _getFieldLabel(String fieldKey) {
    switch (fieldKey) {
      case 'dni':
        return 'DNI';
      case 'nombre':
        return 'Nombre';
      case 'telefono':
        return 'Teléfono';
      case 'password':
        return 'Contraseña';
      case 'placa':
        return 'Placa';
      default:
        return 'Campo';
    }
  }

  Widget _buildBackgroundImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          // Imagen de fondo (puedes reemplazar con tu imagen)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/driver.png',
                  ), // Reemplaza con tu imagen
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // Texto superpuesto
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sé parte de la fuerza',
                  style: AppTextStyles.poppinsSubtitle.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: 10),
          Text('Registrarse', style: AppTextStyles.poppinsHeading2),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documentos requeridos',
          style: AppTextStyles.poppinsHeading3.copyWith(fontSize: 18),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImagePickerCard(
              'Brevete',
              Icons.credit_card,
              _fotoBreveteUrl != null,
              () => _pickImage('brevete'),
              isRequired: true,
            ),
            _buildImagePickerCard(
              'Perfil',
              Icons.person,
              _fotoPerfilUrl != null,
              () => _pickImage('perfil'),
            ),
            _buildImagePickerCard(
              'Vehículo',
              Icons.directions_car,
              _fotoLateralUrl != null,
              () => _pickImage('lateral'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePickerCard(
    String label,
    IconData icon,
    bool hasImage,
    VoidCallback onTap, {
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    hasImage
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.greyLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasImage ? AppColors.success : AppColors.border,
                  width: 2,
                ),
              ),
              child:
                  hasImage
                      ? Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 28,
                      )
                      : Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(icon, color: AppColors.textSecondary, size: 24),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: AppColors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.interCaption.copyWith(
                fontWeight: FontWeight.w500,
                color: hasImage ? AppColors.success : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (isRequired)
              Text(
                '*Requerido',
                style: AppTextStyles.interCaption.copyWith(
                  color: AppColors.error,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(DriverAuthViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.buttonDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Crear cuenta',
          style:
              viewModel.isLoading
                  ? AppTextStyles.poppinsButtonDisabled
                  : AppTextStyles.poppinsButton,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿Ya tienes una cuenta? ', style: AppTextStyles.interBodySmall),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, AppRoutes.driverLogin);
          },
          child: Text(
            'Inicia sesión',
            style: AppTextStyles.interLink.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.greyLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary),
            SizedBox(width: 12),
            Text(text, style: AppTextStyles.interBody),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _placaController.dispose();
    super.dispose();
  }
}

class ValidationRule {
  final String message;
  bool isValid;

  ValidationRule(this.message, this.isValid);
}
//Hace falta desacoplar esta pantalla 