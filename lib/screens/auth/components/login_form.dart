import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants/validators.dart';
import '../../../../constants.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<LogInForm> createState() => LogInFormState();
}

class LogInFormState extends State<LogInForm> {
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _buildEmailField(context),
          const SizedBox(height: defaultPadding),
          _buildPasswordField(context),
        ],
      ),
    );
  }

  // Trường nhập email
  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      onSaved: (email) => _email = email!.trim(),
      validator: emailValidator.call,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "Email address",
        prefixIcon: _buildPrefixIcon(
          context,
          "assets/icons/Message.svg",
        ),
      ),
    );
  }

  // Trường nhập mật khẩu
  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      onSaved: (pass) => _password = pass!.trim(),
      validator: passwordValidator.call,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: _buildPrefixIcon(
          context,
          "assets/icons/Lock.svg",
        ),
      ),
    );
  }

  Widget _buildPrefixIcon(BuildContext context, String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
      child: SvgPicture.asset(
        assetPath,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(77),
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Map<String, String>? getCredentials() {
    final form = widget.formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return {'username': _email, 'password': _password};
    }
    return null;
  }
}
