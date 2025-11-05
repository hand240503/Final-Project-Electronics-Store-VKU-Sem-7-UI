import 'package:flutter/material.dart';

import '../../constants.dart';

class ProductReturnsScreen extends StatelessWidget {
  final String? des;
  const ProductReturnsScreen({super.key, this.des});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "Return",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Text(
                des ?? '',
                style: TextStyle(
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: .8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
