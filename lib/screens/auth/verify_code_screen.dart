import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/auth/components/verify_code_form.dart';
import 'package:shop/services/auth/auth_service.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final GlobalKey<VerifyCodeFormState> _verifyFormKey = GlobalKey<VerifyCodeFormState>();
  final AuthService _authService = AuthService(storage: FlutterSecureStorage());

  bool _loading = false;
  bool _canResend = false;
  int _secondsRemaining = 120; // 2 phút
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 120;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_verifyFormKey.currentState == null) return;

    final otp = _verifyFormKey.currentState!.getOtp();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final success = await _authService.verifyRegistrationOtp(otp);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'OTP verified successfully!' : 'Invalid OTP, please try again',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    try {
      final success = await _authService.resendRegistrationOtp();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP code resent!')),
        );
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderImage(),
                      const SizedBox(height: defaultPadding),
                      _buildWelcomeText(),
                      const SizedBox(height: defaultPadding),
                      _buildVerificationForm(),
                      const SizedBox(height: defaultPadding),
                      _buildVerifyButton(),
                      const SizedBox(height: defaultPadding),
                      _buildResendButton(),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Image.asset(
      "assets/images/verifi_l.png",
      fit: BoxFit.cover,
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verification Code",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: defaultPadding / 4),
        const Text(
          "We have sent the code verification to your email.",
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return VerifyCodeForm(key: _verifyFormKey);
  }

  Widget _buildVerifyButton() {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: _verifyOtp,
            child: const Text("Verify"),
          );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: _canResend ? _resendCode : null,
      child: _canResend
          ? const Text("Resend Code")
          : Text("Resend Code in ${_formatDuration(_secondsRemaining)}"),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}
