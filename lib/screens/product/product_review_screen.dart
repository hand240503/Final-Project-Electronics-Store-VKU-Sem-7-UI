import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/services/products/product_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductReviewScreen extends StatefulWidget {
  final int orderId;

  const ProductReviewScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  int _rating = 5;
  final List<String> _selectedQualities = [];
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _qualityOptions = [
    'Chất lượng tốt',
    'Đúng mô tả',
    'Giao hàng nhanh',
    'Giá cả hợp lý',
    'Đóng gói cẩn thận',
    'Sản phẩm chính hãng',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _updateCommentFromSelections() {
    if (_selectedQualities.isEmpty) {
      _commentController.clear();
    } else {
      _commentController.text = _selectedQualities.join(', ');
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ProductService.createOrUpdateRating(
        orderId: widget.orderId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đánh giá của bạn đã được gửi thành công!',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Close screen and return success
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cần Hỗ trợ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Hoàn hảo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 48,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Quality Options
              const Text(
                'Bạn có hài lòng về sản phẩm? Hãy cho chúng tôi biết ý kiến của bạn',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Quality Chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _qualityOptions.map((quality) {
                  final isSelected = _selectedQualities.contains(quality);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedQualities.remove(quality);
                        } else {
                          _selectedQualities.add(quality);
                        }
                        _updateCommentFromSelections();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.shade50 : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        quality,
                        style: TextStyle(
                          color: isSelected ? Colors.green : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Comment TextField
              TextField(
                controller: _commentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Chia sẻ thêm về trải nghiệm của bạn (Không bắt buộc)',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Gửi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
