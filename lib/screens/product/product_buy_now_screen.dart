import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/product/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/custom_modal_bottom_sheet.dart';
import 'package:shop/screens/product/product_order_screen.dart';

import '../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/unit_price.dart';
import 'package:intl/intl.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final ProductDetailModel? productDetailModel;

  const ProductBuyNowScreen({
    super.key,
    this.productDetailModel,
  });

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int quantity = 1;
  int selectedColorIndex = 0;

  List<Color> _getVariantColors() {
    final variants = widget.productDetailModel?.variants ?? [];
    return variants.map((v) => v.color).whereType<String>().map((hex) {
      final cleanHex = hex.replaceAll('#', '').toUpperCase();
      return Color(int.parse('0xFF$cleanHex'));
    }).toList();
  }

  String formatVND(double value) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getVariantColors();
    return Scaffold(
      bottomNavigationBar: CartButton(
        price: (widget.productDetailModel?.discountPrice ?? 0) * quantity,
        title: "Buy Now",
        subTitle: "Total price",
        press: () {
          final product = widget.productDetailModel;
          final variants = product?.variants ?? [];

          final selectedVariantId = variants.isNotEmpty ? variants[selectedColorIndex].id : null;

          // Chuyển sang ProductOrderScreen
          Navigator.pushNamed(
            context,
            productOrderScreenRoute,
            arguments: {
              'productDetailModel': product, // instance ProductDetailModel
              'quantity': quantity,
              'selectedVariantId': selectedVariantId,
            },
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  widget.productDetailModel?.name ?? '',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    "assets/icons/Bookmark.svg",
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(widget.productDetailModel?.mainImage ?? ''),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: widget.productDetailModel?.price ?? 0,
                            priceAfterDiscount: widget.productDetailModel?.discountPrice ?? 0,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: quantity,
                          onIncrement: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          onDecrement: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                if (colors.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SelectedColors(
                      colors: colors,
                      selectedColorIndex: selectedColorIndex,
                      press: (value) {
                        setState(() {
                          selectedColorIndex = value;
                        });
                      },
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: defaultPadding),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
