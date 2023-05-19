import 'package:APaints_QGen/app.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/external_user_login_model.dart';
import 'package:APaints_QGen/src/data/models/login_internal_user_data_model.dart';
import 'package:APaints_QGen/src/data/repositories/authentication_repo.dart';
import 'package:APaints_QGen/src/data/repositories/fr_authentication_repo.dart';
import 'package:APaints_QGen/src/data/repositories/login_repo_impl.dart';
import 'package:APaints_QGen/src/data/repositories/validate_otp_repo.dart';
import 'package:APaints_QGen/src/data/types.dart';
import 'package:APaints_QGen/translations/locale_keys.g.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/get_it.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final _apiProvider = getSingleton<APIProvider>();
  final _authenticationRepo = getSingleton<AuthenticationRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();
  final loginRepo = getSingleton<LoginRepositoryImpl>();
  final externalLoginRepo = getSingleton<FRAuthenticationRepo>();
  final validateOTPRepo = getSingleton<ValidateOTPRepo>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  LoginInternalUserDataModel? userData;
  ExternalUserLoginModel? frLoginUserDataModel;
  // List<ItemsList>? itemList;

  void appStarted() {
    add(AppStarted());
  }

  void login({
    required String userID,
    required String password,
    required String deviceToken,
  }) {
    logger('$userID, $password, $deviceToken');
    add(
      AuthenticationLoginEvent(
        username: userID,
        password: password,
        devicetoken: deviceToken,
      ),
    );
  }

  void logout() {
    add(
      AuthenticationLogoutEvent(),
    );
  }

  void openOTPDialog() {
    add(
      AuthenticationOpenOTPDialogEvent(),
    );
  }

  void sendOTP(
    OTP type, {
    String? email,
    String? phone,
    String? name,
    String? password,
  }) {
    add(
      AuthenticationSendOTPEvent(
        type: type,
        emailAddress: email,
        phoneNumber: phone,
        name: name,
        password: password,
      ),
    );
  }

  void cancel() {
    add(AuthenticationCancelEvent());
  }

  void forgotPassword({String? phone, String? email, String? password}) {
    add(
      AuthenticationForgotPasswordEvent(
        phoneNumber: phone,
        emailAddress: email,
        password: password,
      ),
    );
  }

  void validateOTP({String? otp, var phone}) {
    add(
      AuthenticationOTPValidateEvent(
        phoneNumber: phone,
        otp: otp,
      ),
    );
  }

  void externalLogin({
    required String mobileNumber,
  }) {
    add(ExternalAuthenticationLoginEvent(mobileNumber: mobileNumber));
  }

  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<AppStarted>((event, emit) => _appStartedEvent(event, emit));
    on<AuthenticationLoginEvent>((event, emit) => _loginEvent(event, emit));
    on<AuthenticationLogoutEvent>((event, emit) => _logoutEvent(event, emit));
    on<AuthenticationOpenOTPDialogEvent>(
        (event, emit) => _otpEvent(event, emit));
    on<AuthenticationSendOTPEvent>((event, emit) => _sendOTPEvent(event, emit));
    on<AuthenticationOTPValidateEvent>(
        (event, emit) => _otpValidateEvent(event, emit));
    on<AuthenticationForgotPasswordEvent>(
        (event, emit) => _forgotPasswordEvent(event, emit));
    on<AuthenticationCancelEvent>(
      (event, emit) {
        emit(AuthenticationCancel());
      },
    );
    on<ExternalAuthenticationLoginEvent>(
        (event, emit) => _frloginEvent(event, emit));
  }

  void _loginEvent(
      AuthenticationLoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoginLoading());
    try {
      LoginInternalUserDataModel response = await loginRepo.loginFuture(
        event.username,
        event.password,
        event.devicetoken,
      );
      userData = response;
      logger("Response in AuthBloc: $response");
      logger(userData!.statusMessage!);
      if (userData!.status! == '200') {
        logger("TOKEN: ${userData?.token ?? ''}");
        _setAuthenticationHeaders(userData);
        await _secureStorageProvider.add(
            key: 'username', value: userData!.userinfo!.username);

        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        Journey.token = userData?.token!;

        Journey.username = userData?.userinfo?.username;

        emit(AuthenticationAuthenticated());
        // emit(AuthenticationInitial());
      } else {
        FlutterToastProvider().show(message: userData!.statusMessage!);
        emit(AuthenticationLoginFailure(message: userData!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);
      if (state is AuthenticationCancel) {
        emit(AuthenticationSignIn());
      } else {
        emit(AuthenticationLoginFailure(message: e.toString()));
      }
    }
  }

  void _frloginEvent(ExternalAuthenticationLoginEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoginLoading());
    try {
      ExternalUserLoginModel response =
          await externalLoginRepo.loginFuture(event.mobileNumber);
      frLoginUserDataModel = response;

      await _secureStorageProvider.saveFRUserToDisk(frLoginUserDataModel!);
      await _secureStorageProvider.add(key: 'isFRLoggedIn', value: 'true');
      // emit(AuthenticationAuthenticated());

      logger("Response in AuthBloc: $response");
      logger(frLoginUserDataModel!.statusMessage!);
      if (frLoginUserDataModel!.status! == '200') {
        // // logger("TOKEN: ${userData?.token ?? ''}");
        // _setAuthenticationHeaders(frLoginUserDataModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        Journey.username = userData?.userinfo?.username;
        Journey.token = userData?.token??'';

        emit(FRAuthenticationAuthenticated());
      } else {
        logger("Error: ${frLoginUserDataModel!.statusMessage!}");
        FlutterToastProvider()
            .show(message: frLoginUserDataModel!.statusMessage!);
        emit(AuthenticationLoginFailure(
            message: frLoginUserDataModel!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);
      if (state is AuthenticationCancel) {
        emit(AuthenticationSignIn());
      } else {
        String str = e.toString();
        logger("Error: $str");
        emit(AuthenticationLoginFailure(message: e.toString()));
      }
    }
  }

  void _appStartedEvent(
      AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      String? isLoggedIn = await _secureStorageProvider.read(key: 'isLoggedIn');
      String? isFRLoggedIn =
          await _secureStorageProvider.read(key: 'isFRLoggedIn');
      if (isLoggedIn == null && isFRLoggedIn == null) {
        emit(AuthenticationSignIn());
      } else if (isLoggedIn == 'true') {
        // userData = await _secureStorageProvider.getUserFromDisk();
        logger("TOKEN: ${userData?.token ?? ''}");
        Journey.token = userData?.token!;
        _setAuthenticationHeaders(userData);
        emit(AuthenticationAuthenticated());
      } else if (isFRLoggedIn == 'true') {
        userData = await _secureStorageProvider.getFRUserFromDisk();
        emit(FRAuthenticationAuthenticated());
      }
      // itemList = await _secureStorageProvider.getProductFromDisk();
    } catch (error, stackTrace) {
      logES(error, stackTrace);
      emit(AuthenticationFailure(
          message: LocaleKeys.authenticationError.translate()));
    }
  }

  void _logoutEvent(AuthenticationLogoutEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      userData = null;
      await _secureStorageProvider.removeUser();
      emit(AuthenticationSignIn());
    } catch (error, stackTrace) {
      logES(error, stackTrace);
      emit(AuthenticationFailure(
          message: LocaleKeys.authenticationError.translate()));
    }
  }

  void _otpEvent(AuthenticationOpenOTPDialogEvent event,
      Emitter<AuthenticationState> emit) {
    emit(AuthenticationOTPDialog());
  }

  void _sendOTPEvent(AuthenticationSendOTPEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationOTPSendSuccess(type: event.type));

    try {
      var response = await _authenticationRepo.sendOTP(
        phone: event.phoneNumber,
        sendMail:
            (event.type == OTP.Both || event.type == OTP.Email) ? true : false,
        email: event.emailAddress,
      );
      logger(response);
    } catch (e, st) {
      logES(e, st);
      emit(AuthenticationOTPSendFailure(message: e.toString()));
    }
  }

  void _forgotPasswordEvent(AuthenticationForgotPasswordEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      var response = await _authenticationRepo.forgotPassword(
        phone: event.phoneNumber,
        email: event.emailAddress,
        newPassword: event.password,
      );
      if (response) {
        emit(AuthenticationForgotPasswordSuccess());
      } else {
        emit(AuthenticationForgotPasswordFailure(
            message: LocaleKeys.somethingWentWrong.translate()));
      }
    } catch (error, stackTrace) {
      logES(error, stackTrace);
      emit(AuthenticationForgotPasswordFailure(message: error.toString()));
    }
  }

  void _otpValidateEvent(AuthenticationOTPValidateEvent event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      var response = await validateOTPRepo.validateOTP(
        event.phoneNumber,
        event.otp,
      );

      userData = response;
      logger("Response in AuthBloc: $response");
      logger(userData!.statusMessage!);
      if (userData!.status! == '200') {
        logger("TOKEN: ${userData?.token ?? ''}");
        _setAuthenticationHeaders(userData);
        String? username = userData?.userinfo?.username;
        Journey.username = userData?.userinfo?.username;
        logger("Username in auth bloc: $username");
        await _secureStorageProvider.add(key: 'username', value: username);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        await _secureStorageProvider.add(key: 'token', value: userData?.token);
        Journey.token = userData?.token!;

        emit(AuthenticationOTPValidated());
      } else {
        FlutterToastProvider().show(message: userData!.statusMessage!);
        emit(AuthenticationOTPValidateFailure(
            message: userData!.statusMessage!));
      }
    } catch (error, stackTrace) {
      logES(error, stackTrace);

      emit(AuthenticationOTPValidateFailure(
          message: LocaleKeys.somethingWentWrong.translate()));
    }
  }

  void _setAuthenticationHeaders(LoginInternalUserDataModel? userData) {
    _apiProvider.setAuthenticationHeaders(
      token: userData?.token ?? '',
    );
  }
}
