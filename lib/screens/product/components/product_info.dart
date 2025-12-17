import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import 'product_availability_tag.dart';

class ProductInfo extends StatefulWidget {
  const ProductInfo({
    super.key,
    required this.title,
    required this.brand,
    required this.description,
    required this.rating,
    required this.numOfReviews,
    required this.isAvailable,
  });

  final String title, brand, description;
  final double rating;
  final int numOfReviews;
  final bool isAvailable;

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  bool _isExpanded = false;

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

            // 👇 Nút "Xem thêm / Thu gọn"
            if (shouldShowButton)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
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
