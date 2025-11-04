class ApiEndpoints {
  static const String baseUrl = "http://192.168.239.1:8000";
  static const String login = "/api/accounts/login/";
  static const String register = "/api/accounts/register/";
  static const String refreshToken = "/api/accounts/token/refresh/";

  static const String verifyOtp = "/api/accounts/verify-otp/";
  static const String resendOtp = "/api/auth/resend-otp/";

  static const String categories = "/api/categories/";
  static const String categoryTreeParents = "/api/products/categories-parents/";

  /// Lấy sản phẩm theo parent category
  /// Nếu parentId = 0, có thể truyền type (popular, sale, best_seller) qua query
  static String productsByCategoryParentId(int parentId, {String? type}) {
    String url = "/api/products/parent-categories/$parentId/";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
    return url;
  }

  /// Lấy sản phẩm theo category cụ thể
  /// Nếu categoryId = 0, có thể truyền type (popular, sale, best_seller) qua query
  static String productsByCategoryId(int categoryId, {String? type}) {
    String url = "/api/products/categories/$categoryId/";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
    return url;
  }

  static String productDetail(int id) {
    return "$baseUrl/api/products/$id/";
  }
}
