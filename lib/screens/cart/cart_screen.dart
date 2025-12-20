import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/cart/cart_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool selectAll = false;
  bool isLoading = true;
  List<Map<String, dynamic>> cartItems = [];
  final storage = const FlutterSecureStorage();
  late CartService cartService;

  // Voucher variables
  String? selectedVoucherCode;
  String? selectedVoucherTitle;
  int selectedVoucherDiscount = 0;
  TextEditingController voucherController = TextEditingController();

  // Danh sách voucher có sẵn
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
    cartService = CartService(storage: storage);
    _loadCartData();
  }

  @override
  void dispose() {
    voucherController.dispose();
    super.dispose();
  }

  Future<void> _loadCartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userIdStr = await storage.read(key: 'user_id');
      if (userIdStr == null) {
        throw Exception('User chưa đăng nhập');
      }
      final userId = int.tryParse(userIdStr);
      if (userId == null) {
        throw Exception('User ID không hợp lệ');
      }

      final response = await cartService.getCartByUserId(userId);

      if (response != null && response['success'] == true) {
        final cart = response['cart'];
        final items = cart['items'] as List;

        setState(() {
          cartItems = items.map((item) {
            final product = item['product'];
            final price = (item['unit_price'] as num).toDouble();
            final discountPrice = product['discount_price'] != null
                ? double.parse(product['discount_price'].toString())
                : price;
            final originalPrice =
                product['price'] != null ? double.parse(product['price'].toString()) : null;

            return {
              'cart_item_id': item['cart_item_id'],
              'product_id': product['id'],
              'name': product['name'],
              'variant': item['variant_name'],
              'variant_id': item['variant_id'],
              'price': discountPrice.toInt(),
              'originalPrice': originalPrice?.toInt(),
              'image': product['main_image'] ??
                  'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=200',
              'quantity': item['quantity'],
              'stock': null,
              'freeShip': true,
              'selected': false,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải giỏ hàng: $e')),
        );
      }
    }
  }

  String formatPrice(num price) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(price)}đ';
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

    if (totalPrice < voucher['minOrder']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đơn hàng tối thiểu ${formatPrice(voucher['minOrder'])}"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

  Future<void> handleQuantityChange(int cartItemId, int delta) async {
    final index = cartItems.indexWhere((item) => item['cart_item_id'] == cartItemId);
    if (index == -1) return;

    final currentQuantity = cartItems[index]['quantity'];
    final newQuantity = currentQuantity + delta;

    if (newQuantity <= 0) {
      _showDeleteConfirmDialog(cartItemId, index);
      return;
    }

    setState(() {
      cartItems[index]['quantity'] = newQuantity.clamp(1, 999);
    });

    try {
      final response = await cartService.updateCartItem(
        cartItemId: cartItemId,
        quantity: newQuantity,
      );

      if (response == null || response['success'] != true) {
        setState(() {
          cartItems[index]['quantity'] = currentQuantity;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? 'Cập nhật số lượng thất bại'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        cartItems[index]['quantity'] = currentQuantity;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật số lượng: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(int cartItemId, int index) async {
    final productName = cartItems[index]['name'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc chắn muốn xóa "$productName" khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _deleteCartItem(cartItemId, index);
    }
  }

  Future<void> _deleteCartItem(int cartItemId, int index) async {
    final deletedItem = cartItems[index];

    setState(() {
      cartItems.removeAt(index);
    });

    try {
      final response = await cartService.deleteCartItem(cartItemId: cartItemId);

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Đã xóa sản phẩm khỏi giỏ hàng'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          cartItems.insert(index, deletedItem);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? 'Xóa sản phẩm thất bại'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        cartItems.insert(index, deletedItem);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa sản phẩm: $e')),
        );
      }
    }
  }

  void handleSelectItem(int cartItemId) {
    setState(() {
      final index = cartItems.indexWhere((item) => item['cart_item_id'] == cartItemId);
      if (index != -1) {
        cartItems[index]['selected'] = !cartItems[index]['selected'];
      }
      selectAll = cartItems.every((item) => item['selected']);
    });
  }

  void handleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      for (var item in cartItems) {
        item['selected'] = selectAll;
      }
    });
  }

  void _handleCheckout() {
    final selectedItems = cartItems.where((item) => item['selected'] == true).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm để mua')),
      );
      return;
    }

    final orderItems = selectedItems.map((item) {
      return OrderItem.fromCartItem(item);
    }).toList();

    Navigator.pushNamed(
      context,
      productOrderScreenRoute,
      arguments: {
        'orderItems': orderItems,
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
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableVouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = availableVouchers[index];
                        final isSelected = selectedVoucherCode == voucher['code'];
                        final canUse = totalPrice >= voucher['minOrder'];

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
                                              'Đơn tối thiểu ${formatPrice(voucher['minOrder'])}',
                                              style: GoogleFonts.roboto(
                                                fontSize: 11,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
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

  int get selectedCount => cartItems.where((item) => item['selected']).length;

  num get totalPrice => cartItems
      .where((item) => item['selected'])
      .fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  num get totalOriginalPrice => cartItems
      .where((item) => item['selected'])
      .fold(0, (sum, item) => sum + ((item['originalPrice'] ?? item['price']) * item['quantity']));

  num get finalTotal => (totalPrice - selectedVoucherDiscount).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: primaryMaterialColor),
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Giỏ hàng trống',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy thêm sản phẩm vào giỏ hàng',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Bạn đang có ${cartItems.length} sản phẩm trong giỏ hàng',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCartData,
              color: primaryMaterialColor,
              child: ListView(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: selectAll,
                          onChanged: (_) => handleSelectAll(),
                          activeColor: primaryMaterialColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryMaterialColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Chọn tất cả sản phẩm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: cartItems.map((item) => _buildCartItem(item)).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Voucher Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.discount_outlined,
                                    color: Color(0xFFFF6D00), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Voucher của Shop',
                                  style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
                                    borderSide:
                                        const BorderSide(color: primaryMaterialColor, width: 2),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  prefixIcon: const Icon(Icons.local_offer_outlined,
                                      color: primaryMaterialColor),
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
                                          'Giảm ${formatPrice(selectedVoucherDiscount)}',
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
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạm tính',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      formatPrice(totalOriginalPrice),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (totalOriginalPrice != totalPrice) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giảm giá sản phẩm',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        '-${formatPrice(totalOriginalPrice - totalPrice)}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
                if (selectedVoucherDiscount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Voucher giảm giá',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        '-${formatPrice(selectedVoucherDiscount)}',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
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
            padding: const EdgeInsets.all(12),
            child: SafeArea(
              child: Row(
                children: [
                  Checkbox(
                    value: selectAll,
                    onChanged: (_) => handleSelectAll(),
                    activeColor: primaryMaterialColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(
                    'Tất cả',
                    style: TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatPrice(finalTotal),
                        style: GoogleFonts.roboto(
                          color: const Color(0xFFFF424E),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: selectedCount > 0 ? _handleCheckout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryMaterialColor,
                      disabledBackgroundColor: Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      'Mua hàng ($selectedCount)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item['selected'],
            onChanged: (_) => handleSelectItem(item['cart_item_id']),
            activeColor: primaryMaterialColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.image, size: 30, color: Colors.grey),
                      );
                    },
                  ),
                ),
                if (item['stock'] != null && item['stock'] <= 5)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF424E),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Còn ${item['stock']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        final index =
                            cartItems.indexWhere((i) => i['cart_item_id'] == item['cart_item_id']);
                        _showDeleteConfirmDialog(item['cart_item_id'], index);
                      },
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      formatPrice(item['price']),
                      style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item['originalPrice'] != null)
                      Text(
                        formatPrice(item['originalPrice']),
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['variant'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => handleQuantityChange(item['cart_item_id'], -1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.remove, size: 16, color: Colors.grey),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item['quantity']}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          InkWell(
                            onTap: () => handleQuantityChange(item['cart_item_id'], 1),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.add, size: 16, color: primaryMaterialColor),
                            ),
                          ),
                        ],
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
}
