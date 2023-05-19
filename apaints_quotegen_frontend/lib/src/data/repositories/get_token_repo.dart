import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/models/token_model/get_token_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class GetTokenRepository extends Repository {
  Future<GetTokenModel> getTokenFuture(userType, userCode) async {
    // '/authenticate?username=$userCode&userType=$userType',
    var response = await apiProvider.get("authenticate",
        configBaseUrl: ConfigBaseUrl.baseUrl,
        params: {"userName": userCode, "userType": userType});
    if ((response != null) || response!['data'] != null) {
      return GetTokenModel.fromJson(response);
    }
    throw BadRequestException(message: 'Authenticate Token Not Fount');
  }
}
