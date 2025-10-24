import 'package:flutter/material.dart';
import 'package:shop/components/skleton/product/product_card_skelton.dart';
import 'package:shop/components/skleton/product/products_skelton.dart';

import 'package:shop/screens/product/components/inches_size_table.dart';

void main() {
  runApp(const DevApp());
}

class DevApp extends StatelessWidget {
  const DevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Development Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const DevHomePage(),
    );
  }
}

class DevHomePage extends StatelessWidget {
  const DevHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inches Size Table Demo')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ProductsSkelton(),
      ),
    );
  }
}
