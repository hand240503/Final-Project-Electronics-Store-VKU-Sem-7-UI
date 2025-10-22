import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/routes/route_constants.dart';

import '../../../../constants.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: defaultPadding / 2),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(
              "Popular products",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          // While loading use 👇
          // const ProductsSkelton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // không cuộn riêng, cuộn theo toàn trang
              shrinkWrap: true, // cho phép GridView nằm trong Column
              itemCount: demoPopularProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 sản phẩm mỗi hàng
                crossAxisSpacing: defaultPadding, // khoảng cách ngang
                mainAxisSpacing: defaultPadding, // khoảng cách dọc
                childAspectRatio: 0.75, // tỉ lệ khung (tùy theo ProductCard)
              ),
              itemBuilder: (context, index) => ProductCard(
                image: demoPopularProducts[index].image,
                brandName: demoPopularProducts[index].brandName,
                title: demoPopularProducts[index].title,
                price: demoPopularProducts[index].price,
                priceAfetDiscount: demoPopularProducts[index].priceAfetDiscount,
                dicountpercent: demoPopularProducts[index].dicountpercent,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
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
