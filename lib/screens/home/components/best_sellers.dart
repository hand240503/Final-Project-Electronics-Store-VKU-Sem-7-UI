import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';

import '../../../../constants.dart';
import '../../../../routes/route_constants.dart';

class BestSellers extends StatelessWidget {
  const BestSellers({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 👈 giúp tránh lỗi overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: defaultPadding / 2),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(
              "Best sellers",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          // While loading use 👇
          // const ProductsSkelton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // 👈 không cuộn riêng
              shrinkWrap: true, // 👈 cho phép GridView nằm trong Column
              itemCount: demoBestSellersProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 👈 2 sản phẩm mỗi hàng
                crossAxisSpacing: defaultPadding, // khoảng cách ngang
                mainAxisSpacing: defaultPadding, // khoảng cách dọc
                childAspectRatio: 0.75, // tỉ lệ khung (tùy thuộc vào kích thước ProductCard)
              ),
              itemBuilder: (context, index) => ProductCard(
                image: demoBestSellersProducts[index].image,
                brandName: demoBestSellersProducts[index].brandName,
                title: demoBestSellersProducts[index].title,
                price: demoBestSellersProducts[index].price,
                priceAfterDiscount: demoBestSellersProducts[index].priceAfterDiscount,
                discountPercent: demoBestSellersProducts[index].discountPercent,
                press: () {
                  Navigator.pushNamed(
                    context,
                    logInScreenRoute,
                    arguments: index.isEven,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
