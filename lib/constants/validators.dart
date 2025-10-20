import 'package:form_field_validator/form_field_validator.dart';

class EmailOrPhoneValidator extends FieldValidator<String> {
  EmailOrPhoneValidator({String errorText = 'Enter a valid email or phone number'})
      : super(errorText);

  @override
  bool isValid(String? value) {
    if (value == null || value.isEmpty) return true; // RequiredValidator sẽ check
    final phoneRegExp = RegExp(r'^\+?\d{7,15}$');
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return phoneRegExp.hasMatch(value) || emailRegExp.hasMatch(value);
  }
}

// Password validator
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(2, errorText: 'Password must be at least 8 characters long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'Password must have at least one special character')
]);

final emailOrPhoneValidator = MultiValidator([
  RequiredValidator(errorText: 'Email or Phone is required'),
  EmailOrPhoneValidator(errorText: "Enter a valid email or phone number"),
]);


final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Enter a valid email address'),
]);
// Password match error text
const pasNotMatchErrorText = "Passwords do not match";
