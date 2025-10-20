import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/auth/login_screen.dart';
import 'package:shop/screens/auth/signup_screen.dart';
import 'package:shop/screens/auth/verify_code_screen.dart';
import 'package:shop/screens/onbording/onbording_screnn.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case verifyCodeFormRoute:
      return MaterialPageRoute(
        builder: (context) => const VerifyCodeScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
  }
}
