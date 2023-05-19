part of 'authentication_bloc.dart';


abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({required this.message});
}

class AuthenticationSignIn extends AuthenticationState {}

class AuthenticationLoginLoading extends AuthenticationState {}

class AuthenticationLoginFailure extends AuthenticationFailure {
  AuthenticationLoginFailure({required String message})
      : super(message: message);
}

class AuthenticationForgotPassword extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class FRAuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationOTPDialog extends AuthenticationState {}

class AuthenticationOTPSendSuccess extends AuthenticationState {
  final OTP type;

  AuthenticationOTPSendSuccess({required this.type});
}

class AuthenticationOTPSendFailure extends AuthenticationFailure {
  AuthenticationOTPSendFailure({required String message})
      : super(message: message);
}

class AuthenticationForgotPasswordSuccess extends AuthenticationState {}

class AuthenticationForgotPasswordFailure extends AuthenticationFailure {
  AuthenticationForgotPasswordFailure({required String message})
      : super(message: message);
}

class AuthenticationOTPValidateFailure extends AuthenticationFailure {
  AuthenticationOTPValidateFailure({required String message})
      : super(message: message);
}

class AuthenticationOTPValidated extends AuthenticationState {}

class AuthenticationCancel extends AuthenticationState {}
