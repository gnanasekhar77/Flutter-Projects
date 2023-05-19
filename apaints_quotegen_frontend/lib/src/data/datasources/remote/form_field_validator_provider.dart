import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/translations/locale_keys.g.dart';
import 'package:form_field_validator/form_field_validator.dart';

class FormFieldValidatorProvider {
  FormFieldValidator<String> getNameValidator({String? errorMessage}) {
    return MultiValidator(
      [
        RequiredValidator(errorText: LocaleKeys.fullNameIsRequired.translate()),
      ],
    );
  }

  FormFieldValidator<String> getOTPValidator({String? errorMessage}) {
    return MultiValidator(
      [
        RequiredValidator(
          errorText: LocaleKeys.pleaseEnterOtpToVerify.translate(),
        ),
        MaxLengthValidator(6,
            errorText: LocaleKeys.otpShouldHave6Digits.translate()),
        MinLengthValidator(6,
            errorText: LocaleKeys.otpShouldHave6Digits.translate()),
      ],
    );
  }

  FormFieldValidator<String> getEmailValidator({String? errorMessage}) {
    return MultiValidator(
      [
        RequiredValidator(
            errorText: LocaleKeys.emailAddressIsRequired.translate()),
        EmailValidator(
            errorText: errorMessage?.translate() ??
                LocaleKeys.pleaseEnterAValidEmailAddress.translate())
      ],
    );
  }

  FormFieldValidator<String> getPhoneNumberValidator({String? errorMessage}) {
    return MultiValidator(
      [
        RequiredValidator(
            errorText: LocaleKeys.phoneNumberIsRequired.translate()),
        MaxLengthValidator(10,
            errorText: LocaleKeys.phoneNumberShouldHave10Digits.translate()),
        MinLengthValidator(10,
            errorText: LocaleKeys.phoneNumberShouldHave10Digits.translate()),
        PatternValidator(r'^(?:[+0]9)?[0-9]{10}$',
            errorText: LocaleKeys.phoneNumberFormatIsNotCorrect.translate())
      ],
    );
  }

  FormFieldValidator<String> getPasswordValidator(
      {String? errorMessage, bool? isRegister = true}) {
    return MultiValidator(
      [
        RequiredValidator(errorText: LocaleKeys.passwordIsRequired.translate()),
        if (isRegister!) ...[
          MinLengthValidator(8,
              errorText:
                  LocaleKeys.passwordsMustBeAtleast8CharactersLong.translate()),
          PatternValidator(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
            errorText: LocaleKeys.passwordFormatText.translate(),
          )
        ],
      ],
    );
  }

  String? getConfirmPasswordValidator(String password, String? confirmPassword,
      {String? errorMessage}) {
    if (confirmPassword != null && confirmPassword.isNotEmpty) {
      return MatchValidator(
              errorText: LocaleKeys.passwordDoNotMatch.translate())
          .validateMatch(password, confirmPassword);
    } else {
      return LocaleKeys.confirmPasswordIsRequired.translate();
    }
  }

  MultiValidator getIndianPincodeValidator({String? errorMessage}) {
    return MultiValidator(
      [
        RequiredValidator(
          errorText: errorMessage ?? 'Pincode is required!',
        ),
        MaxLengthValidator(
          6,
          errorText: 'Pincode should be 6 digits in length',
        ),
        MinLengthValidator(
          6,
          errorText: 'Pincode should be 6 digits in length',
        ),
      ],
    );
  }

  MultiValidator getPincodeValidator({required String pattern}) {
    return MultiValidator([
      PatternValidator(pattern, errorText: "Pincode format is not correct!"),
      RequiredValidator(errorText: 'Pincode is required!'),
    ]);
  }

  FormFieldValidator<String> getRequiredValidator({required String field}) {
    return RequiredValidator(errorText: '$field is required!');
  }
}
