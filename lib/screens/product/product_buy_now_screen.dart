import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:intl/intl.dart';
import 'package:shop/services/cart/cart_service.dart';
import 'package:shop/services/behavior/behavior_tracking_service.dart';

import '../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/unit_price.dart';

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

  late final CartService cartService;

  @override
  void initState() {
    super.initState();
    cartService = CartService(storage: const FlutterSecureStorage());
  }

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

  Future<void> _addToCart() async {
    final product = widget.productDetailModel;
    if (product == null) return;

    final variants = product.variants ?? [];
    final selectedVariantId = variants.isNotEmpty ? variants[selectedColorIndex].id : null;

    // Gọi service thêm vào giỏ hàng
    final result = await cartService.addToCart(
      productId: product.id,
      variantId: selectedVariantId,
      quantity: quantity,
    );

    // ✅ TRACKING: Track behavior "Add to Cart"
    if (result?['success'] == true) {
      try {
        await BehaviorTrackingService.trackAddToCart(
          productId: product.id,
          variantId: selectedVariantId,
          quantity: quantity,
          price: product.discountPrice,
        );
        print('✅ Tracked: Add to cart - Product ${product.id}');
      } catch (e) {
        print('⚠️  Tracking failed: $e');
        // Không ảnh hưởng đến flow chính nếu tracking fail
      }
    }

    // Kiểm tra mounted trước khi cập nhật UI
    if (!mounted) return;

    // Lấy thông tin thành công từ result
    final success = result?['success'] == true;
    final message =
        result?['message'] ?? (success ? "Đã thêm vào giỏ hàng" : "Thêm giỏ hàng thất bại");

    // Hiển thị Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _buyNow() {
    final product = widget.productDetailModel;
    final variants = product?.variants ?? [];
    final selectedVariantId = variants.isNotEmpty ? variants[selectedColorIndex].id : null;

    Navigator.pushNamed(
      context,
      productOrderScreenRoute,
      arguments: {
        'orderItems': [
          OrderItem(
            productDetailModel: product!,
            quantity: quantity,
            selectedVariantId: selectedVariantId,
          ),
        ],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getVariantColors();
    final totalPrice = (widget.productDetailModel?.discountPrice ?? 0) * quantity;

    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    formatVND(totalPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _addToCart,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/Bag.svg",
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              primaryColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Thêm vào giỏ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _buyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mua ngay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
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
