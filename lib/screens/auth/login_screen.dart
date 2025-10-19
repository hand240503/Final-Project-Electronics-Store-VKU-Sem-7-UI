import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(storage: FlutterSecureStorage());
  final GlobalKey<LogInFormState> _loginFormKey = GlobalKey<LogInFormState>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderImage(),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(context),
                  const SizedBox(height: defaultPadding),
                  _buildLoginForm(),
                  _buildForgotPasswordButton(),
                  _buildSpacing(size),
                  _buildLoginButton(context),
                  _buildSignUpRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ảnh đầu trang
  Widget _buildHeaderImage() {
    return Image.asset(
      "assets/images/login_l.png",
      fit: BoxFit.cover,
    );
  }

  // Tiêu đề chào mừng
  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: defaultPadding / 4),
        const Text(
          "Log in with your data that you entered during your registration.",
        ),
      ],
    );
  }

  // Form đăng nhập
  Widget _buildLoginForm() {
    return LogInForm(
      key: _loginFormKey,
      formKey: _formKey,
    );
  }

  // Nút quên mật khẩu
  Widget _buildForgotPasswordButton() {
    return Align(
      child: TextButton(
        onPressed: () {
          // Navigator.pushNamed(context, passwordRecoveryScreenRoute);
        },
        child: const Text("Forgot password"),
      ),
    );
  }

  // Khoảng cách động
  Widget _buildSpacing(Size size) {
    return SizedBox(
      height: (size.height > 700 ? size.height * 0.1 : defaultPadding) * 0.5,
    );
  }

  // 🔘 Nút đăng nhập
  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final credentials = _loginFormKey.currentState?.getCredentials();

        if (credentials == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all fields correctly')),
          );
          return;
        }

        // Hiển thị loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        // Gọi API login
        final success = await _authService.login(
          credentials['username']!,
          credentials['password']!,
        );

        // Ẩn loading
        Navigator.pop(context);

        if (success) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            entryPointScreenRoute,
            ModalRoute.withName(logInScreenRoute),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please check your credentials'),
            ),
          );
        }
      },
      child: const Text("Log in"),
    );
  }

  // 🧑‍💻 Chuyển đến đăng ký
  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, signUpScreenRoute);
          },
          child: const Text("Sign up"),
        ),
      ],
    );
  }
}
