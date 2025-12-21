import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/order/order_detail_screen.dart';
import 'package:shop/services/orders/order_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Map để lưu trữ đơn hàng theo status
  final Map<int, List<dynamic>> _ordersByStatus = {
    0: [], // Chờ xác nhận
    1: [], // Chờ lấy hàng
    2: [], // Chờ giao hàng
    3: [], // Đã giao
    4: [], // Trả hàng
    5: [], // Hủy
  };

  final Map<int, bool> _isLoadingByStatus = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  // Map để lưu số lượng đơn hàng theo status
  final Map<int, int> _orderCountByStatus = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
  };

  bool _isLoadingCounts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Lắng nghe sự thay đổi tab để load data
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchOrdersByStatus(_tabController.index);
      }
    });

    // Load số lượng đơn hàng cho tất cả các status
    _fetchAllOrderCounts();

    // Load data tab đầu tiên
    _fetchOrdersByStatus(0);
    _fetchOrdersByStatus(1);
    _fetchOrdersByStatus(2);
    _fetchOrdersByStatus(3);
    _fetchOrdersByStatus(4);
    _fetchOrdersByStatus(5);
  }

  final storage = const FlutterSecureStorage();

  Future<void> _fetchAllOrderCounts() async {
    setState(() {
      _isLoadingCounts = true;
    });

    try {
      // Lấy user_id từ storage
      final userIdStr = await storage.read(key: 'user_id');
      if (userIdStr == null) {
        throw Exception('User chưa đăng nhập');
      }
      final userId = int.tryParse(userIdStr);
      if (userId == null) {
        throw Exception('User ID không hợp lệ');
      }

      // Gọi API getOrdersByUser với userId từ storage
      final response = await OrderService.getOrdersByUser(userId);

      if (response['success'] == true) {
        final orders = response['data'] as List;

        // Đếm số lượng đơn hàng theo từng status
        final Map<int, int> counts = {
          0: 0,
          1: 0,
          2: 0,
          3: 0,
          4: 0,
          5: 0,
        };

        for (var order in orders) {
          final status = order['status'] as int;
          if (counts.containsKey(status)) {
            counts[status] = counts[status]! + 1;
          }
        }

        if (mounted) {
          setState(() {
            _orderCountByStatus.addAll(counts);
            _isLoadingCounts = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingCounts = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCounts = false;
        });
      }
    }
  }

  Future<void> _fetchOrdersByStatus(int status) async {
    final userIdStr = await storage.read(key: 'user_id');
    if (userIdStr == null) {
      throw Exception('User chưa đăng nhập');
    }
    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      throw Exception('User ID không hợp lệ');
    }
    if (_ordersByStatus[status]!.isNotEmpty) return;

    setState(() {
      _isLoadingByStatus[status] = true;
    });

    try {
      final response = await OrderService.getOrdersByUser(userId);

      if (response['success']) {
        final orders = response['data'] as List;

        // Lọc đơn theo status
        final filteredOrders = orders.where((o) => o['status'] == status).toList();

        // Chuyển đổi items API về format hiện tại
        final mappedOrders = filteredOrders.map((order) {
          final items = (order['items'] as List).map((item) {
            return {
              'product_name': item['product']['name'],
              'product_image': item['product']['main_image'],
              // Lấy variant_name từ variant.name
              'variant_name': item['variant'] != null ? item['variant']['name'] : '',
              'quantity': item['quantity'],
              'price': item['price'],
              'original_price': item['product']['price'],
              // Lấy brand_name từ product.brand.name
              'brand_name':
                  item['product']['brand'] != null ? item['product']['brand']['name'] : '',
            };
          }).toList();

          return {
            'id': order['id'],
            'status': order['status'],
            'total_price': order['total_price'],
            'items': items,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _ordersByStatus[status] = mappedOrders;
            _isLoadingByStatus[status] = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingByStatus[status] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Lỗi khi lấy đơn hàng')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingByStatus[status] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lấy đơn hàng: $e')),
        );
      }
    }
  }

  String formatPrice(String price) {
    if (price.isEmpty) return '';
    final number = double.tryParse(price) ?? 0;
    final formatter = NumberFormat('#,##0', 'vi_VN'); // định dạng Việt Nam
    return '${formatter.format(number)} ₫';
  }

  // Lấy tên trạng thái
  String _getStatusName(int status) {
    switch (status) {
      case 0:
        return 'Chờ thanh toán';
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
        return 'Không xác định';
    }
  }

  // Lấy màu trạng thái
  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.red; // Chờ thanh toán
      case 1:
        return Colors.orange; // Chờ lấy hàng
      case 2:
        return Colors.blue; // Đang giao hàng
      case 3:
        return Colors.green; // Đã giao
      case 4:
        return Colors.purple; // Trả hàng
      case 5:
        return Colors.grey; // Đã hủy
      default:
        return Colors.black; // Không xác định
    }
  }

  // Widget tạo tab với số lượng
  Widget _buildTabWithCount(String label, int status) {
    final count = _orderCountByStatus[status] ?? 0;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE85D4D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE85D4D)),
          onPressed: () => Navigator.pushNamed(context, entryPointScreenRoute),
        ),
        title: const Text(
          'Đơn đã mua',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFFE85D4D),
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFFE85D4D),
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              _buildTabWithCount('Chờ xác nhận', 0),
              _buildTabWithCount('Chờ lấy hàng', 1),
              _buildTabWithCount('Chờ giao hàng', 2),
              _buildTabWithCount('Đã giao', 3),
              _buildTabWithCount('Trả hàng', 4),
              _buildTabWithCount('Đã hủy', 5),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderListView(0), // Chờ xác nhận
          _buildOrderListView(1), // Chờ lấy hàng
          _buildOrderListView(2), // Chờ giao hàng
          _buildOrderListView(3), // Đã giao
          _buildOrderListView(4), // Trả hàng
          _buildOrderListView(5), // Đã hủy
        ],
      ),
    );
  }

  // Widget duy nhất để hiển thị danh sách đơn hàng theo status
  Widget _buildOrderListView(int status) {
    final isLoading = _isLoadingByStatus[status] ?? false;
    final orders = _ordersByStatus[status] ?? [];

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE85D4D),
        ),
      );
    }

    if (orders.isEmpty) {
      return _buildEmptyOrderView();
    }

    return RefreshIndicator(
      color: const Color(0xFFE85D4D),
      onRefresh: () async {
        // Reset và load lại data
        setState(() {
          _ordersByStatus[status] = [];
        });
        await _fetchOrdersByStatus(status);
        await _fetchAllOrderCounts(); // Cập nhật lại số lượng
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index], status);
        },
      ),
    );
  }

  Widget _buildEmptyOrderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFD699),
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 20,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD699),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 45,
                        height: 3,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 45,
                        height: 3,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 45,
                        height: 3,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 15,
                  bottom: 20,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Container(
                      width: 35,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF81C9CC), Color(0xFF5FB8BC)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 20,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9966),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 25,
                  top: 15,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4DFE5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFCC99),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bạn chưa có đơn hàng nào cả',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, int status) {
    final items = (order['items'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    final firstItem = items[0];
    final orderId = order['id'] is int ? order['id'] : int.tryParse(order['id'].toString()) ?? 0;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: orderId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.store_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'SHOPLON',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getStatusName(status),
                    style: GoogleFonts.roboto(
                      color: _getStatusColor(status),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        firstItem['product_image'] ??
                            'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=200',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 40),
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
                          firstItem['product_name'] ?? 'Sản phẩm',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstItem['variant_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (firstItem['original_price'] != null) ...[
                              Text(
                                formatPrice(firstItem['original_price'].toString()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              formatPrice(firstItem['price'].toString()),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'x${firstItem['quantity']}',
                              style: TextStyle(
                                fontSize: 13,
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
            ),
            if (items.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '+ ${items.length - 1} sản phẩm khác',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tổng số tiền (${items.length} sản phẩm): ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    formatPrice(order['total_price'].toString()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE85D4D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildActionButtons(status, orderId, context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(int status, int orderId, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Nút hành động theo status
          if (status == 0)
            // Status 0 - Chờ xác nhận: Nút Hủy đơn
            SizedBox(
              width: 100,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Xác nhận hủy đơn',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Bạn có chắc chắn muốn hủy đơn hàng này?',
                        style: GoogleFonts.roboto(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Không', style: GoogleFonts.roboto()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Hủy đơn',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFE85D4D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final result = await OrderService.cancelOrder(orderId);
                    if (result['success'] == true) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã hủy đơn hàng', style: GoogleFonts.roboto()),
                          ),
                        );
                        setState(() {
                          _ordersByStatus[0] = [];
                          _ordersByStatus[5] = [];
                        });
                        await _fetchAllOrderCounts();
                        await _fetchOrdersByStatus(status);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Hủy đơn thất bại',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE85D4D),
                  side: const BorderSide(color: Color(0xFFE85D4D)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text('Hủy đơn', style: GoogleFonts.roboto(fontSize: 14)),
              ),
            )
          else if (status == 2)
            // Status 2 - Chờ giao hàng: Nút Đã nhận hàng
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Xác nhận đã nhận hàng',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Bạn đã nhận được hàng và hài lòng với sản phẩm?',
                        style: GoogleFonts.roboto(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Chưa', style: GoogleFonts.roboto()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Đã nhận',
                            style: GoogleFonts.roboto(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    // TODO: Call API to confirm received
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xác nhận nhận hàng', style: GoogleFonts.roboto()),
                        ),
                      );
                      setState(() {
                        _ordersByStatus[2] = [];
                        _ordersByStatus[3] = [];
                      });
                      await _fetchAllOrderCounts();
                      await _fetchOrdersByStatus(status);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                child: Text('Đã nhận hàng', style: GoogleFonts.roboto(fontSize: 14)),
              ),
            )
          else if (status == 3) ...[
            // Status 3 - Đã giao: Nút Trả hàng + Đánh giá
            SizedBox(
              width: 100,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Xác nhận trả hàng',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Bạn có chắc chắn muốn trả hàng đơn hàng này?\n\nLưu ý: Chỉ được trả hàng trong vòng 7 ngày kể từ khi nhận hàng.',
                        style: GoogleFonts.roboto(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Hủy', style: GoogleFonts.roboto()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Trả hàng',
                            style: GoogleFonts.roboto(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    final result = await OrderService.returnOrder(orderId);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (context.mounted) {
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Đã gửi yêu cầu trả hàng thành công',
                              style: GoogleFonts.roboto(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _ordersByStatus[3] = [];
                          _ordersByStatus[4] = [];
                        });
                        await _fetchAllOrderCounts();
                        await _fetchOrdersByStatus(3);
                        await _fetchOrdersByStatus(4);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Không thể trả hàng',
                              style: GoogleFonts.roboto(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text('Trả hàng', style: GoogleFonts.roboto(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to review screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D4D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                ),
                child: Text('Đánh giá', style: GoogleFonts.roboto(fontSize: 14)),
              ),
            ),
          ] else if (status == 4) ...[
            // Status 4 - Đang trong quá trình trả hàng: Nút Hủy yêu cầu
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Đang xem xét trả hàng',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Hủy yêu cầu trả hàng',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Bạn có chắc chắn muốn hủy yêu cầu trả hàng này?\n\nĐơn hàng sẽ quay về trạng thái "Đã giao".',
                        style: GoogleFonts.roboto(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Không', style: GoogleFonts.roboto()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Hủy yêu cầu',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFE85D4D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    // TODO: Gọi API hủy yêu cầu trả hàng
                    final result = await OrderService.cancelReturnRequest(orderId);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (context.mounted) {
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã hủy yêu cầu trả hàng',
                              style: GoogleFonts.roboto(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _ordersByStatus[3] = [];
                          _ordersByStatus[4] = [];
                        });
                        await _fetchAllOrderCounts();
                        await _fetchOrdersByStatus(3);
                        await _fetchOrdersByStatus(4);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Không thể hủy yêu cầu',
                              style: GoogleFonts.roboto(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE85D4D),
                  side: const BorderSide(color: Color(0xFFE85D4D)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text('Hủy yêu cầu', style: GoogleFonts.roboto(fontSize: 14)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
