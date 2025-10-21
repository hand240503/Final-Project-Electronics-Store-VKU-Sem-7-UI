class ApiEndpoints {
  static const String baseUrl = "http://192.168.239.1:8000";
  static const String login = "/api/accounts/login/";
  static const String register = "/api/accounts/register/";
  static const String refreshToken = "/api/accounts/token/refresh/";

  static const String verifyOtp = "/api/accounts/verify-otp/";
  static const String resendOtp = "/api/auth/resend-otp/";
}
