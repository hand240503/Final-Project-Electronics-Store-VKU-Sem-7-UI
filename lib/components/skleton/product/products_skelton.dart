import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'product_card_skelton.dart';

class ProductsSkelton extends StatelessWidget {
  const ProductsSkelton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Không cuộn GridView riêng
        shrinkWrap: true, // Cho phép GridView nằm trong Column
        itemCount: 2, // số ô hiển thị tạm
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 sản phẩm mỗi hàng
          crossAxisSpacing: defaultPadding, // khoảng cách ngang
          mainAxisSpacing: defaultPadding, // khoảng cách dọc
          childAspectRatio: 0.75, // tỉ lệ khung
        ),
        itemBuilder: (context, index) => const ProductCardSkelton(),
      ),
    );
  }
}
