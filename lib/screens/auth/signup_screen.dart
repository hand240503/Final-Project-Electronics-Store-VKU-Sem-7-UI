import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shop/routes/route_constants.dart';
import 'package:shop/screens/auth/components/sign_up_form.dart';

import '../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
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
                  _buildTitle(),
                  const SizedBox(height: defaultPadding / 2),
                  _buildDescription(),
                  const SizedBox(height: defaultPadding),
                  _buildSignUpForm(),
                  const SizedBox(height: defaultPadding),
                  // _buildTermsCheckbox(),
                  // const SizedBox(height: defaultPadding),
                  _buildContinueButton(),
                  _buildLoginRow(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Image.asset(
      "assets/images/signUp_l.png",
      fit: BoxFit.cover,
    );
  }

  Widget _buildTitle() {
    return Text(
      "Let’s get started!",
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildDescription() {
    return const Text(
      "Please enter your valid data in order to create an account.",
    );
  }

  Widget _buildSignUpForm() {
    return SignUpForm(
      formKey: _formKey,
      passwordController: _passwordController,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeTerms,
          onChanged: (value) {
            setState(() {
              _agreeTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: "I agree with the",
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigator.pushNamed(context, termsOfServicesScreenRoute);
                    },
                  text: " Terms of service ",
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: "& privacy policy."),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, entryPointScreenRoute);
      },
      child: const Text("Continue"),
    );
  }

  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Do you have an account?"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, logInScreenRoute);
          },
          child: const Text("Log in"),
        ),
      ],
    );
  }
}
