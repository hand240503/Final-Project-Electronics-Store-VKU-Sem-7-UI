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

  /// Thêm địa chỉ mới
  static const String addAddress = "/api/accounts/addresses/add/";

  /// Lấy danh sách địa chỉ theo user_id (admin hoặc chính user)
  static String addressesByUserId(int userId) {
    return "/api/accounts/addresses/user/$userId/";
  }

  /// (Khuyến nghị) Lấy địa chỉ của user đang đăng nhập
  static const String myAddresses = "/api/accounts/addresses/user/";

  // ================= CATEGORY =================
  static const String categories = "/api/categories/";
  static const String categoryTreeParents = "/api/products/categories-parents/";

  // ================= PRODUCT =================

  /// Tìm kiếm sản phẩm
  static const String searchProducts = "/api/products/search/";

  /// Lấy sản phẩm theo parent category
  static String productsByCategoryParentId(int parentId, {String? type}) {
    String url = "/api/products/parent-categories/$parentId/";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
    return url;
  }

  /// Lấy sản phẩm theo category cụ thể
  static String productsByCategoryId(int categoryId, {String? type}) {
    String url = "/api/products/categories/$categoryId/";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
    return url;
  }

  /// Chi tiết sản phẩm (full URL)
  static String productDetail(int id) {
    return "$baseUrl/api/products/app/$id/";
  }
}
