import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color.fromRGBO(0, 113, 240, 1.0),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromRGBO(0, 113, 240, 1.0),
      ),
      themeMode: ThemeMode.system, // Mặc định theo hệ thống
      home: const LoginPage(),
    );
  }
}
