import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_result_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class CompetitionSearchResultRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();
  Future<CompetitionSearchResultResponse> competitionSearchResultFuture(
      String? brandName, String? rangeName, String? skuName) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    // '/authenticate?username=$userCode&userType=$userType',
    String? token = await secureStorageProvider.read(key: 'token');

    var response = await apiProvider.get(
      configBaseUrl: ConfigBaseUrl.baseUrl,
      '/${_configProvider.apiBasePath}?api=get-competition-range-skus&QUOTOKEN=${Journey.token}&brandName=$brandName&rangeName=$rangeName&skuName=$skuName',
    );
    if ((response != null) || response!['data'] != null) {
      return CompetitionSearchResultResponse.fromJson(response);
    }
    throw BadRequestException(message: 'Authenticate Token Not Fount');
  }
}
