import 'package:flutter/material.dart';
import '../presentation/analysis_screen/analysis_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String analysis = '/analysis-screen';
  static const String dashboard = '/dashboard-screen';
  static const String settings = '/settings-screen';
  static const String login = '/login-screen';
  static const String profile = '/profile-screen';
  static const String registration = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    analysis: (context) => const AnalysisScreen(),
    dashboard: (context) => const DashboardScreen(),
    settings: (context) => const SettingsScreen(),
    login: (context) => const LoginScreen(),
    profile: (context) => const ProfileScreen(),
    registration: (context) => const RegistrationScreen(),
  };
}
