part of 'authentication_bloc.dart';


abstract class AuthenticationEvent {}

class AppStarted extends AuthenticationEvent {}

class AuthenticationLoginEvent extends AuthenticationEvent {
  final String username;
  final String password;
  final String devicetoken;

  AuthenticationLoginEvent({
    required this.username,
    required this.password,
    required this.devicetoken,
  });
}

class AuthenticationLogoutEvent extends AuthenticationEvent {}

class AuthenticationOpenOTPDialogEvent extends AuthenticationEvent {}

class AuthenticationCancelEvent extends AuthenticationEvent {}

class AuthenticationSendOTPEvent extends AuthenticationEvent {
  final OTP type;
  final String? phoneNumber;
  final String? emailAddress;
  final String? name;
  final String? password;
  AuthenticationSendOTPEvent({
    required this.type,
    this.phoneNumber,
    this.emailAddress,
    this.name,
    this.password,
  });
}

class AuthenticationForgotPasswordEvent extends AuthenticationEvent {
  final String? phoneNumber;
  final String? emailAddress;
  final String? password;
  AuthenticationForgotPasswordEvent({
    this.phoneNumber,
    this.emailAddress,
    this.password,
  });
}

class AuthenticationOTPValidateEvent extends AuthenticationEvent {
  final String? phoneNumber;
  final String? otp;
  AuthenticationOTPValidateEvent({
    this.phoneNumber,
    this.otp,
  });
}

class ExternalAuthenticationLoginEvent extends AuthenticationEvent {
  final String mobileNumber;

  ExternalAuthenticationLoginEvent({required this.mobileNumber});
}
