import 'package:flutter/material.dart';
import '../../View/Screen/Auth/login_screen/login_screen.dart';
import '../../View/Screen/Auth/otp_verification_screen/otp_verification_screen.dart';
import '../../View/Screen/Auth/register_screen/register_screen.dart';
import '../../View/Screen/Auth/role_selection_screen/role_selection_screen.dart';
import '../../View/Screen/MainScreen/main_screen/main_screen.dart';
import '../../View/Screen/SplashScreen/splash_screen/splash_screen.dart';
import '../../global/Model/krishi_models.dart';

class AppRoute {
  static const String splashScreen = '/';
  static const String loginScreen = '/login';
  static const String roleSelectScreen = '/role_select';
  static const String registerScreen = '/register';
  static const String otpScreen = '/otp';
  static const String mainScreen = '/main';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    roleSelectScreen: (context) => const RoleSelectionScreen(),
    registerScreen: (context) {
      final role = ModalRoute.of(context)?.settings.arguments as UserRole? ?? UserRole.farmer;
      return RegisterScreen(role: role);
    },
    otpScreen: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final role = args['role'] as UserRole? ?? UserRole.farmer;
      final email = args['email'] as String? ?? '';
      final phone = args['phone'] as String? ?? '';
      return OtpVerificationScreen(role: role, email: email, phone: phone);
    },
    mainScreen: (context) => const MainScreen(),
  };
}
