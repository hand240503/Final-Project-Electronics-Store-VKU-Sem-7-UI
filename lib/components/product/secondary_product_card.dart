import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/services/behavior/behavior_tracking_service.dart';
import '../../constants.dart';
import '../network_image_with_loader.dart';

class SecondaryProductCard extends StatelessWidget {
  const SecondaryProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    this.discountPercent,
    this.press,
    this.style,
    this.productId, // ✅ ADDED
  });

  final String image, brandName, title;
  final double price;
  final double? priceAfterDiscount;
  final int? discountPercent;
  final VoidCallback? press;
  final ButtonStyle? style;
  final int? productId; // ✅ ADDED

  /// Format giá tiền VND
  String formatVND(double value) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// ✅ NEW: Handle tap with behavior tracking
  void _handlePress() async {
    // Track behavior nếu có productId
    if (productId != null) {
      try {
        await BehaviorTrackingService.trackViewDetails(productId!);
      } catch (e) {
        // Nếu tracking fail, vẫn navigate bình thường
        print('⚠️  Tracking failed: $e');
      }
    }

    // Execute original press callback
    press?.call();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: press != null ? _handlePress : null, // ✅ CHANGED
      style: style ??
          OutlinedButton.styleFrom(
            minimumSize: const Size(256, 114),
            maximumSize: const Size(256, 114),
            padding: const EdgeInsets.all(8),
          ),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                NetworkImageWithLoader(image, radius: defaultBorderRadious),
                if (discountPercent != null && discountPercent! > 0)
                  Positioned(
                    right: defaultPadding / 2,
                    top: defaultPadding / 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2,
                      ),
                      height: 16,
                      decoration: const BoxDecoration(
                        color: errorColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(defaultBorderRadious),
                        ),
                      ),
                      child: Text(
                        "$discountPercent% off",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: defaultPadding / 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  priceAfterDiscount != null
                      ? Row(
                          children: [
                            Text(
                              formatVND(priceAfterDiscount!), // ✅ CHANGED
                              style: const TextStyle(
                                color: Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: defaultPadding / 4),
                            Text(
                              formatVND(price), // ✅ CHANGED
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          formatVND(price), // ✅ CHANGED
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
