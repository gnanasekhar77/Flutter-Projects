import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/models/external_user_login_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class FRAuthenticationRepo extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<ExternalUserLoginModel> loginFuture(mobilenumber) async {
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=external-login',
      body: {
        "mobilenumber": mobilenumber,
      },
    );
    if ((response != null)) {
      return ExternalUserLoginModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
