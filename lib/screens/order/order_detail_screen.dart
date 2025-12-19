import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/orders/order_service.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  String formatPrice(dynamic price) {
    if (price == null) return '0₫';
    final number = double.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(number)}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE85D4D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thông tin đơn hàng',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: OrderService.getOrderDetail(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!['success'] == false) {
            return Center(child: Text(snapshot.data?['message'] ?? 'Không tìm thấy đơn hàng'));
          }

          final order = snapshot.data!['data'];
          final address = order['address'];
          final items = order['items'] ?? [];
          final totalPrice = order['total_price'];
          final status = order['status'] is int
              ? order['status']
              : int.tryParse(order['status'].toString()) ?? 0;
          final orderCode = order['id']?.toString() ?? "N/A";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trạng thái đơn hàng
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Phương thức thanh toán
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on_outlined, color: Colors.black87),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Thanh toán bằng ${order['payment_method']?.toString() ?? 'Thanh toán khi nhận hàng'}',
                          style: GoogleFonts.roboto(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Địa chỉ nhận hàng
                if (address != null)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Địa chỉ nhận hàng',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.black87, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        address['full_name']?.toString() ?? '',
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        address['phone']?.toString() ?? '',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    address['address_line']?.toString() ?? '',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Cập nhật',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Thông tin sản phẩm
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "SHOPLON",
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...items.map<Widget>((item) {
                        final product = item['product'];
                        final productName = product?['name']?.toString() ?? 'Sản phẩm';
                        final productImage = product?['main_image']?.toString();
                        final variantName = item['variant']?['name']?.toString();
                        final quantity = item['quantity']?.toString() ?? '1';
                        final price = item['price'];
                        final originalPrice = product?['price'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (productImage != null)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      productImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (variantName != null && variantName.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          variantName,
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (originalPrice != null && originalPrice != price)
                                          Text(
                                            formatPrice(originalPrice),
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                              color: Colors.grey[400],
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        if (originalPrice != null && originalPrice != price)
                                          const SizedBox(width: 8),
                                        Text(
                                          formatPrice(price),
                                          style: GoogleFonts.roboto(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'x$quantity',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Divider(color: Colors.grey[300], height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thành tiền:',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            formatPrice(totalPrice),
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Mã đơn hàng
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn hàng',
                        style: GoogleFonts.roboto(fontSize: 15),
                      ),
                      Row(
                        children: [
                          Text(
                            orderCode,
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom bar: Tổng thanh toán + Nút hủy đơn
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng thanh toán:',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            formatPrice(totalPrice),
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: const Color(0xFFE85D4D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (status == 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: OutlinedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xác nhận hủy đơn'),
                                  content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Không'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Hủy đơn',
                                        style: TextStyle(color: Color(0xFFE85D4D)),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final result = await OrderService.cancelOrder(orderId);

                                if (result['success']) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã hủy đơn hàng')),
                                    );
                                    Navigator.pushNamed(context, listOrderScreenRoute);
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(result['message'] ?? 'Hủy đơn thất bại')),
                                    );
                                  }
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Hủy đơn hàng',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Chờ lấy hàng';
      case 2:
        return 'Đang giao hàng';
      case 3:
        return 'Đã giao';
      case 4:
        return 'Trả hàng';
      case 5:
        return 'Đã hủy';
      default:
        return 'Chờ Người bán gửi hàng';
    }
  }
}
