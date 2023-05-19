import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/tokens_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class TokenRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();
  Future<TokensModel> getTokenFuture(String? token) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    // '/authenticate?username=$userCode&userType=$userType',
    String? token = await secureStorageProvider.read(key: 'token');

    var response = await apiProvider.get(
      configBaseUrl: ConfigBaseUrl.baseUrl,
      '/${_configProvider.apiBasePath}?api=autoload&QUOTOKEN=$token',
    );
    if ((response != null) || response!['data'] != null) {
      return TokensModel.fromJson(response);
    }
    throw BadRequestException(message: 'Authenticate Token Not Fount');
  }
}
