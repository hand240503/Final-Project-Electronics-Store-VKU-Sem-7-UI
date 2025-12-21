import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/models/notification_model.dart';
import 'package:shop/constants.dart';
import 'package:intl/intl.dart';
import 'package:shop/services/notifications/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await NotificationService.fetchNotifications();
      setState(() {
        notifications = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải thông báo: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    try {
      // Đánh dấu đã đọc và lấy URL redirect
      final redirectUrl = await NotificationService.handleNotificationClick(notification);

      // Cập nhật UI
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = notification.copyWith(isRead: true);
        }
      });

      // TODO: Navigate đến màn hình tương ứng dựa vào redirectUrl
      if (redirectUrl != null) {
        print('Navigate to: $redirectUrl');
        // Navigator.pushNamed(context, redirectUrl);
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      setState(() {
        notifications.removeWhere((n) => n.id == notificationId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã xóa thông báo',
              style: GoogleFonts.roboto(),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: $e',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      setState(() {
        notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã đánh dấu tất cả đã đọc',
              style: GoogleFonts.roboto(),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Đánh dấu tất cả đã đọc',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildNotificationList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryMaterialColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Thử lại',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông báo nào',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông báo sẽ xuất hiện ở đây',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification),
            radius: 24,
            child: Icon(
              _getNotificationIcon(notification),
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: GoogleFonts.poppins(
              fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.content,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                notification.timeAgo,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: primaryMaterialColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationModel notification) {
    if (notification.typeColor != null && notification.typeColor!.isNotEmpty) {
      try {
        return Color(int.parse(notification.typeColor!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return primaryMaterialColor;
      }
    }
    return primaryMaterialColor;
  }

  IconData _getNotificationIcon(NotificationModel notification) {
    switch (notification.typeIcon) {
      case 'shopping-cart':
        return Icons.shopping_cart;
      case 'truck':
        return Icons.local_shipping;
      case 'check-circle':
        return Icons.check_circle;
      case 'package':
        return Icons.inventory;
      case 'gift':
        return Icons.card_giftcard;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }
}
