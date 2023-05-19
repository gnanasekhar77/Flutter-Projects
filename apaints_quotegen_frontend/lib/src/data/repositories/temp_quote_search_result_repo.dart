import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_results_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class TempQuoteSearchResultRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();
  Future<TemplateQuoteResultsListResponse> tempQuoteSearchResultFuture(
      String? brandName,
      String? rangeName,
      String? bundleType,
      String? sanwareType) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    // '/authenticate?username=$userCode&userType=$userType',
    String? token = await secureStorageProvider.read(key: 'token');

    var response = await apiProvider.get(
      configBaseUrl: ConfigBaseUrl.baseUrl,
      '/${_configProvider.apiBasePath}?api=get-template-skus-list&QUOTOKEN=${Journey.token}&brandName=$brandName&rangeName=$rangeName&brandtype=$bundleType&sanwaretype=$sanwareType',
    );
    if ((response != null) || response!['data'] != null) {
      return TemplateQuoteResultsListResponse.fromJson(response);
    }
    throw BadRequestException(message: 'Authenticate Token Not Fount');
  }
}
