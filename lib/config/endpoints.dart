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
}
