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
  String paymentMethod = 'Tiền mặt khi nhận hàng';

  // Voucher variables
  String? selectedVoucherCode;
  String? selectedVoucherTitle;
  int selectedVoucherDiscount = 0;
  TextEditingController voucherController = TextEditingController();

  // Danh sách voucher có sẵn (có thể load từ API)
  final List<Map<String, dynamic>> availableVouchers = [
    {
      'code': 'FREESHIP50K',
      'title': 'Miễn phí vận chuyển',
      'description': 'Giảm 50.000đ phí vận chuyển',
      'discount': 50000,
      'minOrder': 0,
    },
    {
      'code': 'GIAM100K',
      'title': 'Giảm 100K',
      'description': 'Giảm 100.000đ cho đơn từ 500K',
      'discount': 100000,
      'minOrder': 500000,
    },
    {
      'code': 'GIAM50K',
      'title': 'Giảm 50K',
      'description': 'Giảm 50.000đ cho đơn từ 200K',
      'discount': 50000,
      'minOrder': 200000,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    voucherController.dispose();
    super.dispose();
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

  // Áp dụng voucher từ ô nhập
  void _applyVoucherCode() {
    final code = voucherController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập mã voucher")),
      );
      return;
    }

    // Tìm voucher trong danh sách
    final voucher = availableVouchers.firstWhere(
      (v) => v['code'] == code,
      orElse: () => {},
    );

    if (voucher.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mã voucher không hợp lệ"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra điều kiện tối thiểu
    if (subtotal < voucher['minOrder']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Đơn hàng tối thiểu ${NumberFormat('#,###', 'vi_VN').format(voucher['minOrder'])}đ"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Áp dụng voucher
    setState(() {
      selectedVoucherCode = voucher['code'];
      selectedVoucherTitle = voucher['title'];
      selectedVoucherDiscount = voucher['discount'];
      voucherController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Áp dụng voucher thành công"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Xóa voucher đã chọn
  void _removeVoucher() {
    setState(() {
      selectedVoucherCode = null;
      selectedVoucherTitle = null;
      selectedVoucherDiscount = 0;
      voucherController.clear();
    });
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

    // Trừ voucher discount
    final finalTotal = calculatedTotal - selectedVoucherDiscount;

    final oderCode = "#${DateTime.now().millisecondsSinceEpoch}";
    final Map<String, dynamic> orderPayload = {
      "totalPrice": finalTotal,
      "hasInsurance": hasInsurance,
      "note": "",
      "discountCode": selectedVoucherCode ?? "",
      "orderCode": oderCode,
      "paymentMethod": paymentMethod,
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
            totalAmount: finalTotal,
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
    final total = subtotal + (hasInsurance ? insurancePrice : 0) - selectedVoucherDiscount;

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
                        _buildPaymentMethodSection(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
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
              InkWell(
                onTap: _showVoucherBottomSheet,
                child: Row(
                  children: [
                    Text(
                      'Chọn voucher',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ô nhập mã voucher
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: voucherController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã voucher',
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryMaterialColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    prefixIcon: const Icon(Icons.local_offer_outlined, color: primaryMaterialColor),
                  ),
                  style: GoogleFonts.roboto(fontSize: 14),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyVoucherCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryMaterialColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  minimumSize: const Size(80, 48),
                  maximumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  'Áp dụng',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Hiển thị voucher đã chọn (nếu có)
          if (selectedVoucherCode != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
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
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedVoucherTitle ?? '',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mã: $selectedVoucherCode',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (selectedVoucherDiscount > 0)
                          Text(
                            'Giảm ${NumberFormat('#,###', 'vi_VN').format(selectedVoucherDiscount)}đ',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: _removeVoucher,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Có thể click để thay đổi
          InkWell(
            onTap: _showPaymentMethodBottomSheet,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phương thức thanh toán',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Thay đổi',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Hiển thị phương thức đã chọn bên dưới
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryMaterialColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryMaterialColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  paymentMethod == 'Tiền mặt khi nhận hàng' ? Icons.money : Icons.credit_card,
                  color: primaryMaterialColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentMethod,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        paymentMethod == 'Tiền mặt khi nhận hàng'
                            ? 'Thanh toán khi nhận hàng (COD)'
                            : 'Ví điện tử, thẻ ATM, thẻ tín dụng',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: primaryMaterialColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingSection(int discount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: _showShippingMethodBottomSheet,
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
                      'Xem chi tiết',
                      style: GoogleFonts.roboto(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Phương thức vận chuyển đã chọn
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

  void _showShippingMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phương thức vận chuyển',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vận chuyển nhanh - Miễn phí (Mặc định)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryMaterialColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: primaryMaterialColor.withOpacity(0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                  Text(
                                    'Vận chuyển nhanh',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: primaryMaterialColor,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Dự kiến giao: 22 Th12 - 25 Th12',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Nhận Voucher 15.000đ nếu giao trễ sau 25/12/2025',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Đây là phương thức vận chuyển mặc định và duy nhất',
                              style: GoogleFonts.roboto(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Nút xác nhận
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryMaterialColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Xác nhận',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn phương thức thanh toán',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Tiền mặt khi nhận hàng
              InkWell(
                onTap: () {
                  setState(() {
                    paymentMethod = 'Tiền mặt khi nhận hàng';
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: paymentMethod == 'Tiền mặt khi nhận hàng'
                          ? primaryMaterialColor
                          : Colors.grey.shade300,
                      width: paymentMethod == 'Tiền mặt khi nhận hàng' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: paymentMethod == 'Tiền mặt khi nhận hàng'
                        ? primaryMaterialColor.withOpacity(0.05)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.money,
                        color: paymentMethod == 'Tiền mặt khi nhận hàng'
                            ? primaryMaterialColor
                            : Colors.grey.shade600,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tiền mặt khi nhận hàng',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Thanh toán khi nhận hàng (COD)',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (paymentMethod == 'Tiền mặt khi nhận hàng')
                        const Icon(
                          Icons.check_circle,
                          color: primaryMaterialColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVoucherBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chọn Voucher',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Danh sách voucher
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableVouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = availableVouchers[index];
                        final isSelected = selectedVoucherCode == voucher['code'];
                        final canUse = subtotal >= voucher['minOrder'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: canUse
                                ? () {
                                    setState(() {
                                      selectedVoucherCode = voucher['code'];
                                      selectedVoucherTitle = voucher['title'];
                                      selectedVoucherDiscount = voucher['discount'];
                                      voucherController.clear();
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Áp dụng voucher thành công"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? primaryMaterialColor
                                      : canUse
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? primaryMaterialColor.withOpacity(0.05)
                                    : canUse
                                        ? Colors.white
                                        : Colors.grey.shade100,
                              ),
                              child: Row(
                                children: [
                                  // Icon voucher
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: canUse
                                          ? primaryMaterialColor.withOpacity(0.1)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.local_offer,
                                      color: canUse ? primaryMaterialColor : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Thông tin voucher
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          voucher['title'],
                                          style: GoogleFonts.roboto(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: canUse ? Colors.black : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          voucher['description'],
                                          style: GoogleFonts.roboto(
                                            fontSize: 13,
                                            color: canUse ? Colors.grey.shade600 : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mã: ${voucher['code']}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: canUse ? primaryMaterialColor : Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (!canUse)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              'Đơn tối thiểu ${NumberFormat('#,###', 'vi_VN').format(voucher['minOrder'])}đ',
                                              style: GoogleFonts.roboto(
                                                fontSize: 11,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Radio button
                                  Radio<String>(
                                    value: voucher['code'],
                                    groupValue: selectedVoucherCode,
                                    onChanged: canUse
                                        ? (value) {
                                            setState(() {
                                              selectedVoucherCode = voucher['code'];
                                              selectedVoucherTitle = voucher['title'];
                                              selectedVoucherDiscount = voucher['discount'];
                                              voucherController.clear();
                                            });
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Áp dụng voucher thành công"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        : null,
                                    activeColor: primaryMaterialColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                  // Hiển thị voucher giảm giá
                  if (selectedVoucherDiscount > 0)
                    Text(
                      'Voucher: -${NumberFormat('#,###', 'vi_VN').format(selectedVoucherDiscount)}đ',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: Colors.green,
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
