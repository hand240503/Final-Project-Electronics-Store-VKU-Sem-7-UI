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

  @override
  void initState() {
    super.initState();
    cartService = CartService(storage: storage);
    _loadCartData();
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

  // Method mới để xử lý checkout
  void _handleCheckout() {
    final selectedItems = cartItems.where((item) => item['selected'] == true).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm để mua')),
      );
      return;
    }

    // Chuyển đổi cart items thành OrderItem
    final orderItems = selectedItems.map((item) {
      return OrderItem.fromCartItem(item);
    }).toList();

    // Navigate đến ProductOrderScreen
    Navigator.pushNamed(
      context,
      productOrderScreenRoute,
      arguments: {
        'orderItems': orderItems,
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
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.discount_outlined, color: Color(0xFFFF6D00), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Khuyến mãi',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined, color: primaryMaterialColor),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Chọn hoặc nhập Khuyến mãi',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
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
                        'Giảm giá',
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
                        formatPrice(totalPrice),
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
