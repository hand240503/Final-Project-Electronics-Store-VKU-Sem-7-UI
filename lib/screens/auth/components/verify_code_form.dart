import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class VerifyCodeForm extends StatefulWidget {
  const VerifyCodeForm({super.key});

  @override
  State<VerifyCodeForm> createState() => VerifyCodeFormState();
}

class VerifyCodeFormState extends State<VerifyCodeForm> {
  final int length = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(length, (_) => TextEditingController());
    _focusNodes = List.generate(length, (_) => FocusNode());

    // Focus ô đầu tiên khi màn hình mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Lấy giá trị OTP hiện tại
  String getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (index) => _buildField(index)),
      ),
    );
  }

  Widget _buildField(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 4),
      child: SizedBox(
        width: 60,
        height: 60,
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 24),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: '',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (!mounted) return;

            if (value.isNotEmpty) {
              // Nhập ký tự → focus sang ô tiếp theo
              if (index < length - 1) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
              }
            } else if (index > 0) {
              _focusNodes[index].unfocus();
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
