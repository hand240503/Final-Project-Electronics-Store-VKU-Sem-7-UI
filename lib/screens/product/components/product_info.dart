import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/services/behavior/behavior_tracking_service.dart';
import '../../../constants.dart';
import 'product_availability_tag.dart';
import 'package:intl/intl.dart';

class ProductInfo extends StatefulWidget {
  const ProductInfo({
    super.key,
    required this.title,
    required this.brand,
    required this.description,
    required this.rating,
    required this.numOfReviews,
    required this.isAvailable,
    required this.price,
    required this.discountPrice,
    required this.productId, // ✅ NEW: Add productId for tracking
  });

  final String title, brand, description;
  final double rating;
  final int numOfReviews;
  final bool isAvailable;
  final double price;
  final double discountPrice;
  final int? productId; // ✅ NEW: Product ID

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  bool _isExpanded = false;
  bool _hasTrackedMoreDetails = false; // ✅ NEW: Track only once

  String formatVND(double value) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// ✅ NEW: Handle expand với tracking
  void _handleExpand() async {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // Track moreDetails khi user bấm "Xem thêm" (chỉ track 1 lần)
    if (!_isExpanded && !_hasTrackedMoreDetails && widget.productId != null) {
      try {
        await BehaviorTrackingService.trackViewMoreDetails(widget.productId!);
        _hasTrackedMoreDetails = true;
        print('✅ Tracked moreDetails for product ${widget.productId}');
      } catch (e) {
        print('⚠️  Tracking moreDetails failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String description = widget.description;
    final bool shouldShowButton = description.length > 120;

    return SliverPadding(
      padding: const EdgeInsets.all(defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.brand.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              widget.title,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatVND(widget.discountPrice),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatVND(widget.price),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                ProductAvailabilityTag(isAvailable: widget.isAvailable),
                const Spacer(),
                SvgPicture.asset("assets/icons/Star_filled.svg"),
                const SizedBox(width: defaultPadding / 4),
                Text(
                  "${widget.rating} ",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text("(${widget.numOfReviews} Reviews)")
              ],
            ),
            const SizedBox(height: defaultPadding),
            Text(
              "Product info",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding / 2),

            // 👇 Phần mô tả co giãn
            AnimatedCrossFade(
              firstChild: Text(
                description.length > 120 ? "${description.substring(0, 120)}..." : description,
                style: TextStyle(
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: .8),
                ),
              ),
              secondChild: Text(
                description,
                style: TextStyle(
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withValues(alpha: .8),
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),

            // 👇 Nút "Xem thêm / Thu gọn" với tracking
            if (shouldShowButton)
              TextButton(
                onPressed: _handleExpand, // ✅ CHANGED: Use _handleExpand
                child: Text(
                  _isExpanded ? "Thu gọn" : "Xem thêm",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
