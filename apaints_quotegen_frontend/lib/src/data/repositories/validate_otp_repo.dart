import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/models/login_internal_user_data_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class ValidateOTPRepo extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<LoginInternalUserDataModel> validateOTP(mobilenumber, otp) async {
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=validate-login-otp',
      body: {
        "mobilenumber": mobilenumber,
        "otp": otp,
      },
    );
    if ((response != null)) {
      return LoginInternalUserDataModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
