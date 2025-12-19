import 'package:flutter/material.dart';

// Entry Point
import 'package:shop/entry_point.dart';

// Routes
import 'package:shop/routes/route_constants.dart';

// Onboarding
import 'package:shop/screens/onbording/onbording_screnn.dart';

// Auth
import 'package:shop/screens/auth/login_screen.dart';
import 'package:shop/screens/auth/signup_screen.dart';
import 'package:shop/screens/auth/verify_code_screen.dart';

// Address
import 'package:shop/screens/address/address_screen.dart';
import 'package:shop/screens/address/add_address_screen.dart';
import 'package:shop/screens/address/update_address_screen.dart';

// Product
import 'package:shop/screens/product/product_details_screen.dart';

// Checkout / Cart
import 'package:shop/screens/checkout/cart_screen.dart';
import 'package:shop/screens/product/product_order_screen.dart';

// Wallet
import 'package:shop/screens/wallet/wallet_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Onboarding
    case onbordingScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OnBordingScreen(),
      );

    // Auth
    case loginScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const SignUpScreen(),
      );
    case verifyCodeFormRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const VerifyCodeScreen(),
      );

    // Address
    case userAddressScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AddressScreen(),
      );
    case addAddressScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const AddAddressScreen(),
      );
    case editAddressScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const EditAddressScreen(),
      );
    case productOrderScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;

      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ProductOrderScreen(
          productDetailModel: args?['productDetailModel'],
          quantity: args?['quantity'] ?? 1,
          selectedVariantId: args?['selectedVariantId'],
        ),
      );
    // Product
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ProductDetailsScreen(),
      );

    // Wallet
    case walletScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const WalletScreen(),
      );

    // Entry Point
    case entryPointScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const EntryPoint(),
      );

    // Default
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OnBordingScreen(),
      );
  }
}
