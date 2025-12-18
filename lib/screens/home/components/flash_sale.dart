import 'package:flutter/material.dart';
import 'package:shop/routes/route_constants.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';

class FlashSale extends StatelessWidget {
  const FlashSale({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 👈 để tránh lỗi overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // While loading show 👇
          // const BannerMWithCounterSkelton(),
          BannerMWithCounter(
            duration: const Duration(hours: 8),
            text: "Super Flash Sale \n50% Off",
            press: () {},
          ),
          const SizedBox(height: defaultPadding / 2),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Text(
              "Flash sale",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          // While loading show 👇
          // const ProductsSkelton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // không cuộn riêng
              shrinkWrap: true, // cho phép nằm trong Column
              itemCount: demoFlashSaleProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 sản phẩm mỗi hàng
                crossAxisSpacing: defaultPadding, // khoảng cách ngang
                mainAxisSpacing: defaultPadding, // khoảng cách dọc
                childAspectRatio: 0.75, // tỉ lệ hiển thị
              ),
              itemBuilder: (context, index) => ProductCard(
                image: demoFlashSaleProducts[index].image,
                brandName: demoFlashSaleProducts[index].brandName,
                title: demoFlashSaleProducts[index].title,
                price: demoFlashSaleProducts[index].price,
                priceAfterDiscount: demoFlashSaleProducts[index].priceAfterDiscount,
                discountPercent: demoFlashSaleProducts[index].discountPercent,
                press: () {
                  Navigator.pushNamed(
                    context,
                    loginScreenRoute,
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
