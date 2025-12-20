import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/orders/order_service.dart';
import 'package:shop/services/orders/order_success_screen.dart';

final storage = FlutterSecureStorage();

class ProductOrderScreen extends StatefulWidget {
  final List<OrderItem> orderItems;

  const ProductOrderScreen({
    super.key,
    required this.orderItems,
  });

  @override
  State<ProductOrderScreen> createState() => _ProductOrderScreenState();
}

class _ProductOrderScreenState extends State<ProductOrderScreen> {
  Map<String, dynamic>? user;
  List<dynamic> addresses = [];
  dynamic selectedAddress;
  bool isLoading = true;
  bool hasInsurance = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userId = await storage.read(key: 'user_id');
    final username = await storage.read(key: 'username');
    final email = await storage.read(key: 'email');
    final firstName = await storage.read(key: 'first_name');
    final isActiveStr = await storage.read(key: 'is_active');
    final addressesStr = await storage.read(key: 'addresses');

    final addressList = addressesStr != null ? jsonDecode(addressesStr) : [];

    setState(() {
      user = {
        'id': userId,
        'username': username,
        'email': email,
        'first_name': firstName,
        'is_active': isActiveStr == 'true',
      };
      addresses = addressList;

      selectedAddress = addresses.firstWhere(
        (addr) => addr['is_default'] == true,
        orElse: () => addresses.isNotEmpty ? addresses[0] : null,
      );
      isLoading = false;
    });
  }

  void navigateToAddressSelection() async {
    final result = await Navigator.pushNamed(context, userAddressScreenRoute);
    if (result != null) {
      await loadUserData();
    }
  }

  int get totalQuantity {
    return widget.orderItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get subtotal {
    return widget.orderItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void placeOrder() async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn địa chỉ")),
      );
      return;
    }

    // Tạo list items
    final items = widget.orderItems.map((item) {
      return {
        "product_id": item.productId,
        "variant_id": item.selectedVariantId,
        "quantity": item.quantity,
        "price": item.price,
      };
    }).toList();

    final int calculatedTotal = items.fold<int>(0, (sum, item) {
      final price = (item['price'] as num).toDouble();
      final quantity = item['quantity'] as int;
      return sum + (price * quantity).toInt();
    });
    final oderCode = "#${DateTime.now().millisecondsSinceEpoch}";
    final Map<String, dynamic> orderPayload = {
      "totalPrice": calculatedTotal,
      "hasInsurance": hasInsurance,
      "note": "",
      "discountCode": "",
      "orderCode": oderCode,
      "address": {
        "full_name": selectedAddress['full_name'],
        "phone": selectedAddress['phone'],
        "address_line": selectedAddress['address_line'],
        "ward": selectedAddress['ward'],
        "district": selectedAddress['district'],
        "city": selectedAddress['city'],
      },
      "items": items,
    };

    debugPrint("✅ ORDER DATA SENT: $orderPayload");

    final result = await OrderService.createOrder(orderPayload);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderId: oderCode,
            totalAmount: calculatedTotal,
            orderDate: DateTime.now(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${result['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final insurancePrice = 31499;
    final shippingDiscount = 37700;
    final total = subtotal + (hasInsurance ? insurancePrice : 0);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thanh toán',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAddressSection(),
                        const SizedBox(height: 8),
                        _buildProductsSection(),
                        const SizedBox(height: 8),
                        _buildVoucherSection(),
                        const SizedBox(height: 8),
                        _buildNoteSection(),
                        const SizedBox(height: 8),
                        _buildShippingSection(shippingDiscount),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(subtotal, total, shippingDiscount),
              ],
            ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: navigateToAddressSelection,
        child: Row(
          children: [
            const Icon(Icons.location_on, color: primaryMaterialColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        selectedAddress?['full_name'] ?? 'Chưa có địa chỉ',
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedAddress?['phone'] ?? '',
                        style: GoogleFonts.roboto(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedAddress != null
                        ? '${selectedAddress['address_line']}\n${selectedAddress['ward']}, ${selectedAddress['district']}, ${selectedAddress['city']}'
                        : 'Vui lòng chọn địa chỉ giao hàng',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inbox_outlined, size: 22),
              const SizedBox(width: 8),
              Text(
                'SHOPLON',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.orderItems.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
    final formattedPrice = NumberFormat('#,###', 'vi_VN').format(item.price);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 40, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.image, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.brandName != null)
                  Text(
                    item.brandName!,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (item.variantName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.variantName!,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$formattedPriceđ',
                      style: GoogleFonts.roboto(
                          color: primaryMaterialColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey.shade600,
                        fontSize: 14,
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
  }

  Widget _buildVoucherSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Voucher của Shop',
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  'Chọn hoặc nhập mã',
                  style: GoogleFonts.roboto(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lời nhắn cho Shop',
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  'Để lại lời nhắn',
                  style: GoogleFonts.roboto(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingSection(int discount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phương thức vận chuyển',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Xem tất cả',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Nhanh',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '37.700đ',
                            style: GoogleFonts.roboto(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Miễn Phí',
                            style: GoogleFonts.roboto(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhận từ 22 Th12 - 25 Th12',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nhận Voucher trị giá 15.000đ nếu đơn hàng được giao đến bạn sau ngày 25 Tháng 12 2025.',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int subtotal, int total, int discount) {
    final formattedTotal = NumberFormat('#,###', 'vi_VN').format(total);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng số tiền ($totalQuantity sản phẩm)',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Tổng cộng ',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$formattedTotalđ',
                        style: GoogleFonts.roboto(
                          color: primaryMaterialColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryMaterialColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                minimumSize: const Size(120, 50),
              ),
              child: Text(
                'Đặt hàng',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
