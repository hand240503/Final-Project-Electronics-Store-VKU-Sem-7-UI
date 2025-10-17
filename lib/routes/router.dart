import 'package:flutter/material.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/onbording/onbording_screnn.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/home': // tên route bạn muốn dùng
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
  }
}
