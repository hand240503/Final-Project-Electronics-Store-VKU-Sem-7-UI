import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/routes/route_constants.dart';

import '../../../../constants.dart';

class ProductListSection extends StatelessWidget {
  final List<ProductModel> products; // thêm đây
  final String title;
  const ProductListSection({
    super.key,
    required this.products,
    required this.title,
  });

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
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding * 2),
                child: Text("Không có sản phẩm nào."),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 sản phẩm mỗi hàng
                  crossAxisSpacing: defaultPadding,
                  mainAxisSpacing: defaultPadding,
                  childAspectRatio: 0.75, // tùy theo ProductCard
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    image: product.image,
                    brandName: product.brandName,
                    title: product.title,
                    price: product.price,
                    priceAfterDiscount: product.priceAfterDiscount,
                    discountPercent: product.discountPercent,
                    press: () {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                        arguments: product.id,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
