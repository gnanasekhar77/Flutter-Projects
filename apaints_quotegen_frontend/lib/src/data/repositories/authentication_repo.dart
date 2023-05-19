import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/models/authentication_model/user_data_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';
import 'package:APaints_QGen/translations/locale_keys.g.dart';

class AuthenticationRepository extends Repository {
  Future<UserDataModel> userLogin({
    required String username,
    required String password,
    required String deviceToken,
  }) async {
    var response = await apiProvider.post(
      'login',
      body: {
        'username': username,
        'password': password,
        'devicetoken': deviceToken,
      },
    );
    logger("Response: $response!");
    if (response != null && response.containsKey('userinfo')) {
      return UserDataModel.fromMap(response['userinfo']);
    } else {
      throw AuthenticationException(
          message: LocaleKeys.authenticationError.translate());
    }
  }

  Future<bool> sendOTP({
    String? phone,
    bool? sendMail,
    String? email,
  }) async {
    var response = await apiProvider.get(
      'sendOtp',
      params: {
        'phone': phone,
        'sendInMail': sendMail?.toString(),
        'email': email,
      },
    );
    return response!['status'] == 'OK';
  }

  Future<bool> validateOTP({
    String? phone,
    String? otp,
  }) async {
    var response = await apiProvider.post(
      'validateOtp',
      body: {
        'phone': phone,
        'otp': otp,
      },
    );
    return response!['data'] == true;
  }

  Future<bool> forgotPassword(
      {String? phone, String? email, String? newPassword}) async {
    var response = await apiProvider.post(
      'forgotPassword',
      body: {
        'phone': phone,
        'email': email,
        'newPassword': newPassword,
      },
    );
    return response!['data']['success'] == true;
  }
}
