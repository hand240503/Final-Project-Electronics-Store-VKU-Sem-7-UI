import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/screens/order/order_detail_screen.dart';
import 'package:shop/services/orders/order_service.dart';
import 'package:shop/constants.dart';

class ProcessedReturnOrdersScreen extends StatefulWidget {
  const ProcessedReturnOrdersScreen({
    super.key,
  });

  @override
  State<ProcessedReturnOrdersScreen> createState() => _ProcessedReturnOrdersScreenState();
}

class _ProcessedReturnOrdersScreenState extends State<ProcessedReturnOrdersScreen> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProcessedReturnOrders();
  }

  Future<void> _loadProcessedReturnOrders() async {
    final userIdStr = await storage.read(key: 'user_id');
    if (userIdStr == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User chưa đăng nhập';
      });
      return;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User ID không hợp lệ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await OrderService.getProcessedReturnOrders(userId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _orders = result['data']['orders'] ?? [];
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }

  String _formatCurrency(dynamic price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(double.parse(price.toString()));
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(int isReturn) {
    return isReturn == 1 ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
  }

  Color _getStatusBgColor(int isReturn) {
    return isReturn == 1 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
  }

  IconData _getStatusIcon(int isReturn) {
    return isReturn == 1 ? Icons.check_circle_rounded : Icons.cancel_rounded;
  }

  String _getStatusTitle(int isReturn) {
    return isReturn == 1 ? 'Đơn hàng đã được đồng ý trả hàng' : 'Yêu cầu trả hàng bị từ chối';
  }

  String _getStatusMessage(int isReturn) {
    return isReturn == 1
        ? 'Vui lòng gửi hàng về địa chỉ của chúng tôi trong vòng 7 ngày. Chúng tôi sẽ xử lý hoàn tiền sau khi nhận được hàng.'
        : 'Chúng tôi xin lỗi vì không thể chấp nhận yêu cầu trả hàng của bạn theo chính sách của cửa hàng.';
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isReturn = order['is_return'] ?? 0;
    final orderCode = order['order_code'] ?? '';
    final totalPrice = order['total_price'] ?? 0;
    final createdAt = order['created_at'];
    final updatedAt = order['updated_at'];
    final items = order['items'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusBgColor(isReturn),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(isReturn).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(isReturn),
                    color: _getStatusColor(isReturn),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(isReturn),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(isReturn),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã đơn: $orderCode',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _getStatusColor(isReturn).withOpacity(0.03),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: _getStatusColor(isReturn),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getStatusMessage(isReturn),
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total price
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng tiền:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        _formatCurrency(totalPrice),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Ngày đặt',
                  value: _formatDate(createdAt),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.update_rounded,
                  label: 'Cập nhật',
                  value: _formatDate(updatedAt),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Số sản phẩm',
                  value: '${items.length} sản phẩm',
                ),
              ],
            ),
          ),

          // View detail button
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(orderId: order['id']),
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Xem chi tiết đơn hàng',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_return_rounded,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không có đơn hàng trả hàng',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Các yêu cầu trả hàng đã xử lý\nsẽ hiển thị ở đây',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Có lỗi xảy ra',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage ?? 'Đã xảy ra lỗi không xác định',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadProcessedReturnOrders,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Thử lại',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Yêu cầu trả hàng',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _orders.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadProcessedReturnOrders,
                      color: primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(_orders[index]);
                        },
                      ),
                    ),
    );
  }
}
