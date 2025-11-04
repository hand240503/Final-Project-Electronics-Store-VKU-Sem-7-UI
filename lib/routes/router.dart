import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/auth/login_screen.dart';
import 'package:shop/screens/auth/signup_screen.dart';
import 'package:shop/screens/auth/verify_code_screen.dart';
import 'package:shop/screens/onbording/onbording_screnn.dart';
import 'package:shop/screens/product/product_details_screen.dart';
import 'package:shop/screens/wallet/wallet_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OnBordingScreen(),
      );

    case logInScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const LoginScreen(),
      );

    case signUpScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SignUpScreen(),
      );

    case entryPointScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const EntryPoint(),
      );

    case verifyCodeFormRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const VerifyCodeScreen(),
      );

    case productDetailsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) {
          return ProductDetailsScreen();
        },
      );

    case walletScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const WalletScreen(),
      );

    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OnBordingScreen(),
      );
  }
}
