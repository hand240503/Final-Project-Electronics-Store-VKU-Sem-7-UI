import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants/validators.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;

  @override
  State<SignUpForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final TextEditingController _rePasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showRePassword = false;

  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: defaultPadding),
          _buildPasswordField(),
          const SizedBox(height: defaultPadding),
          _buildRePasswordField(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      onSaved: (email) {
        _email = email!.trim();
      },
      validator: emailOrPhoneValidator.call,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "Email address",
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
          child: SvgPicture.asset(
            "assets/icons/Message.svg",
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    final iconColor = Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3);

    return TextFormField(
      controller: widget.passwordController,
      obscureText: !_showPassword,
      validator: passwordValidator.call,
      onChanged: (password) {
        _password = password.trim();
      },
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
          child: SvgPicture.asset(
            "assets/icons/Lock.svg",
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        suffixIcon: widget.passwordController.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
      ),
    );
  }

  Widget _buildRePasswordField() {
    final iconColor = Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.3);

    return TextFormField(
      controller: _rePasswordController,
      obscureText: !_showRePassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "Please re-enter your password";
        if (value != widget.passwordController.text) return "Passwords do not match";
        return null;
      },
      decoration: InputDecoration(
        hintText: "Re-enter password",
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
          child: SvgPicture.asset(
            "assets/icons/Lock.svg",
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        suffixIcon: _rePasswordController.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  _showRePassword ? Icons.visibility : Icons.visibility_off,
                  color: iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _showRePassword = !_showRePassword;
                  });
                },
              ),
      ),
    );
  }

  Map<String, String>? getCredentials() {
    final form = widget.formKey.currentState;
    if (form != null) {
      if (!form.validate()) {
        return null;
      }
      form.save();
      return {
        'email': _email,
        'password': _password,
      };
    }
    return null;
  }
}
