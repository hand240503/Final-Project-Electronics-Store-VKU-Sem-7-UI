class ApiEndpoints {
  static const String baseUrl = "http://10.0.2.2:8000";

  // ================= AUTH =================
  static const String login = "/api/accounts/login/";
  static const String register = "/api/accounts/register/";
  static const String refreshToken = "/api/accounts/token/refresh/";
  static const String verifyOtp = "/api/accounts/verify-otp/";
  static const String resendOtp = "/api/auth/resend-otp/";

  // ================= USER =================
  static String userDetail(int userId) {
    return "/api/accounts/user/$userId/";
  }

  // ================= ADDRESS =================
  static const String addAddress = "/api/accounts/addresses/add/";
  static String addressesByUserId(int userId) {
    return "/api/accounts/addresses/user/$userId/";
  }

  static const String myAddresses = "/api/accounts/addresses/user/";

  // ================= CATEGORY =================
  static const String categories = "/api/categories/";
  static const String categoryTreeParents = "/api/products/categories-parents/";

  // ================= PRODUCT =================
  static const String searchProducts = "/api/products/search/";
  static String productsByCategoryParentId(int parentId, {String? type}) {
    String url = "/api/products/parent-categories/$parentId/";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
    return url;
  }

  static String productsByCategoryId(int categoryId, {String? type}) {
    String url = "/api/products/categories/$categoryId/";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
    return url;
  }

  static String productDetail(int id) {
    return "$baseUrl/api/products/app/$id/";
  }

  // ================= ORDER =================
  /// Tạo đơn hàng
  static const String addOrder = "/api/orders/create/";

  static String ordersByUser(int userId) {
    return "$baseUrl/api/orders/user/$userId/";
  }

  static String orderDetail(int orderId) {
    return "$baseUrl/api/orders/$orderId/";
  }

  static String cancelOrder(int orderId) {
    return "$baseUrl/api/orders/cancel/$orderId/";
  }

  static String returnOrder(int orderId) {
    return "$baseUrl/api/orders/return/$orderId/";
  }

  static String cancelReturnRequest(int orderId) {
    return "$baseUrl/api/orders/cancel-return/$orderId/";
  }

  // ================= CART =================
  /// Thêm sản phẩm vào giỏ hàng
  static const String addToCart = "/api/cart/add/";

  /// Lấy giỏ hàng theo user_id
  static String cartByUserId(int userId) {
    return "/api/cart/$userId/";
  }

  /// Cập nhật số lượng cart item
  static String updateCartItem(int cartItemId) {
    return "/api/cart/$cartItemId/update/";
  }

  /// Xóa cart item
  static String deleteCartItem(int cartItemId) {
    return "/api/cart/$cartItemId/delete/";
  }

  // ================= NOTIFICATION =================
  /// Lấy danh sách tất cả notifications
  static const String notifications = "/api/notifications/";

  /// Chi tiết một notification
  static String notificationDetail(int id) {
    return "/api/notifications/$id/";
  }

  /// Lấy danh sách notifications chưa đọc
  static const String notificationsUnread = "/api/notifications/unread/";

  /// Lấy số lượng notifications chưa đọc
  static const String notificationsUnreadCount = "/api/notifications/unread-count/";

  /// Đánh dấu một notification đã đọc
  static String notificationMarkRead(int id) {
    return "/api/notifications/$id/mark-read/";
  }

  /// Đánh dấu tất cả notifications đã đọc
  static const String notificationsMarkAllRead = "/api/notifications/mark-all-read/";

  /// Xóa tất cả notifications đã đọc
  static const String notificationsDeleteRead = "/api/notifications/delete-read/";

  /// Xóa một notification
  static String deleteNotification(int id) {
    return "/api/notifications/$id/";
  }

  /// Profile
  static const String profileDetail = '/api/accounts/profile/';
  static const String profileUpdate = '/api/accounts/profile/update/';

  // ================= USER BEHAVIOR TRACKING =================
  /// Track user behavior (details, moreDetails, addToCart, buy)
  static const String trackBehavior = "/api/rating/track-behavior/";

  /// Lấy lịch sử tương tác của user
  static const String userInteractions = "/api/rating/user-interactions/";

  /// Lấy thống kê tương tác của sản phẩm
  static String productInteractions(int productId, {String? event}) {
    String url = "/api/rating/product-interactions/$productId/";
    if (event != null && event.isNotEmpty) {
      url += "?event=$event";
    }
    return url;
  }

  /// Lấy danh sách sản phẩm trending
  static String trendingProducts({int days = 7, int limit = 10}) {
    return "/api/rating/trending-products/?days=$days&limit=$limit";
  }
}
