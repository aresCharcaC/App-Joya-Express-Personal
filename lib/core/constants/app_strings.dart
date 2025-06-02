class AppStrings {
  AppStrings._();

  // App
  static const String appName_1 = 'Joya';
  static const String appName_2 = 'Express';

  // Welcome Screen (Cadenas para la pantalla de bienvenida)
  static const String register = 'Registrarse';
  static const String login = 'Iniciar Sesión';

  // Login Screen (Cadenas para la pantalla de inicio de sesión)
  static const String loginTitle = 'Iniciar Sesión';
  static const String phoneNumber = 'Numero';
  static const String password = 'Contraseña';
  static const String forgotPassword = '¿Haz olvido tu contraseña?';
  static const String loginButton = 'Ingresar';

  // Phone Input Screen (Cadenas para la pantalla de ingreso de teléfono)
  static const String enterPhoneTitle = 'Ingresa tu numero';
  static const String phoneSubtitle = 'Te enviaremos un código para verificar tu número.';
  static const String sendCode = 'Enviar Código';
  static const String phoneNumberHint = 'Numero';

  // Phone Verification Screen (Cadenas para la pantalla de verificación de teléfono)
  static const String verifyPhoneTitle = 'Verifica tu numero de celular';
  static String verifyPhoneSubtitle(String phone) => 'Enviamos un código de 6 dígitos a $phone';
  static const String verifyCode = 'Verificar Código';
  static const String resendCode = 'Reenviar el código en ';
  static const String resendCodeLink = 'Reenviar código';

  // Create Password Screen (Cadenas para la pantalla de creación de contraseña)
  static const String createPasswordTitle = 'Crea una contraseña';
  static const String createPasswordSubtitle = 'Para mantener tu cuenta segura';
  static const String createPasswordButton = 'Crear Contraseña';
  static const String passwordRequirements = 'Mínimo 8 caracteres';
  static const String atLeastOneNumber = 'Al menos 1 número';
  static const String atLeastOneUppercase = 'Al menos 1 letra mayúscula';
  static const String atLeastOneLowercase = 'Al menos 1 letra minúscula';

  // Account Setup Screen (Cadenas para la pantalla de configuración de cuenta)
  static const String setupAccountTitle = 'Configura tu Cuenta';
  static const String setupAccountSubtitle = 'Registra tus datos para iniciar con la búsqueda';
  static const String fullName = 'Nombre Completo';
  static const String email = 'Email *';
  static const String startButton = 'Empezar';

  // Home Screen (Cadenas para la pantalla principal)
  static const String homeTitle = 'Buscar Mototaxi';
  static const String destination = 'Destino';
  static const String offer = 'Brinda una oferta';
  static const String searchMototaxi = 'Buscar Mototaxi';

  // Validation Messages (Cadenas de validación)
  static const String phoneRequired = 'El número de teléfono es requerido';
  static const String passwordRequired = 'La contraseña es requerida';
  static const String nameRequired = 'El nombre completo es requerido';
  static const String invalidPhone = 'Número de teléfono inválido';
  static const String invalidEmail = 'Email inválido';
  static const String passwordTooShort = 'La contraseña debe tener al menos 8 caracteres';

  // Error Messages (Errores comunes)
  static const String networkError = 'Error de conexión';
  static const String unknownError = 'Ha ocurrido un error inesperado';
  static const String invalidCredentials = 'Credenciales inválidas';

  // Drawer Menu(Cadenas para el menú lateral)
  static const String drawerProfile = 'Perfil';
  static const String drawerPaymentMethods = 'Métodos de Pago';
  static const String drawerHistory = 'Historial';
  static const String drawerConfiguration = 'Configuración';
  static const String drawerLogout = 'Cerrar sesión';

  // Profile Screen(Cadenas para la pantalla de perfil)
  static const String profileTitle = 'Perfil';
  static const String profileName = 'Nombre';
  static const String profileEmail = 'Email';
  static const String profilePhone = 'Teléfono';
  static const String profileSave = 'Guardar';
  static const String profileBack = 'Atrás';
  static const String profileUpdatePhoto = 'Cambiar foto';

  // Logout Dialog(Cadenas para el diálogo de cierre de sesión)
  static const String logoutTitle = 'Cerrar sesión';
  static const String logoutMessage = '¿Estás seguro de que deseas cerrar sesión?';
  static const String logoutConfirm = 'Cerrar sesión';
  static const String logoutCancel = 'Cancelar';

  // General(Cadenas generales)
  static const String welcome = '¡Bienvenido a Joya Express!';
  static const String home = 'Inicio';
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  
}