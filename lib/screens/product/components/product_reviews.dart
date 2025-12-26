import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import '../../../models/product_model.dart';

class ProductReviews extends StatefulWidget {
  const ProductReviews({
    super.key,
    required this.reviews,
  });

  final List<ReviewModel> reviews;

  @override
  State<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  int _visibleReviews = 2;

  @override
  Widget build(BuildContext context) {
    final List<ReviewModel> visibleReviews = widget.reviews.take(_visibleReviews).toList();
    final bool hasMore = _visibleReviews < widget.reviews.length;

    return SliverPadding(
      padding: const EdgeInsets.all(defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Customer Reviews (${widget.reviews.length})",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: defaultPadding / 2),

            // Hiển thị khi chưa có review
            if (widget.reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 2),
                child: Center(
                  child: Text(
                    "Chưa có đánh giá nào.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // Danh sách review
            ...List.generate(visibleReviews.length, (index) {
              final review = visibleReviews[index];
              final double rating = review.rating.toDouble().clamp(0, 5);
              final String createdAt = _formatDate(review.createdAt);

              return Container(
                margin: const EdgeInsets.only(bottom: defaultPadding / 1.5),
                padding: const EdgeInsets.all(defaultPadding / 1.2),
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .035),
                  borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hàng chứa tên + sao
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            review.user.isNotEmpty ? review.user[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            review.user,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                        // Rating stars
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: SvgPicture.asset(
                                starIndex < rating
                                    ? "assets/icons/Star_filled.svg"
                                    : "assets/icons/Star.svg",
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  Colors.amber.shade600,
                                  BlendMode.srcIn,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Bình luận
                    if (review.comment != null && review.comment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          review.comment!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),

                    // Ngày tạo
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Nút "Xem thêm / Thu gọn"
            if (widget.reviews.isNotEmpty)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (hasMore) {
                        _visibleReviews = (_visibleReviews + 2).clamp(0, widget.reviews.length);
                      } else {
                        _visibleReviews = 2;
                      }
                    });
                  },
                  child: Text(
                    hasMore ? "Xem thêm" : "Thu gọn",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "";
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} năm trước';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} tháng trước';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (_) {
      return "";
    }
  }
}
