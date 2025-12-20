import 'package:flutter/material.dart';

// Entry Point
import 'package:shop/entry_point.dart';
import 'package:shop/models/order_model.dart';

// Routes
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/cart/cart_screen.dart';

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
import 'package:shop/screens/order/order_screen.dart';

// Product
import 'package:shop/screens/product/product_details_screen.dart';

// Checkout / Cart - Import OrderItem từ product_order_screen
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

    // Product Order / Checkout
    case productOrderScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;

      // Kiểm tra nếu có orderItems (list)
      if (args?['orderItems'] != null) {
        final orderItems = args!['orderItems'];

        // Đảm bảo orderItems là List<OrderItem>
        if (orderItems is List<OrderItem>) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => ProductOrderScreen(
              orderItems: orderItems,
            ),
          );
        }
      }

      // Fallback: nếu truyền theo cách cũ (single product với ProductDetailModel)
      if (args?['productDetailModel'] != null) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ProductOrderScreen(
            orderItems: [
              OrderItem.fromProductDetail(
                productDetailModel: args!['productDetailModel'],
                quantity: args['quantity'] ?? 1,
                selectedVariantId: args['selectedVariantId'],
              ),
            ],
          ),
        );
      }

      // Nếu không có dữ liệu hợp lệ, trả về màn hình lỗi
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Lỗi'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu đơn hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vui lòng thử lại',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
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

    //Order List
    case listOrderScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OrderHistoryScreen(),
      );

    // Entry Point
    case entryPointScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const EntryPoint(),
      );

    case cart_screenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CartScreen(),
      );

    // Default
    default:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const OnBordingScreen(),
      );
  }
}
