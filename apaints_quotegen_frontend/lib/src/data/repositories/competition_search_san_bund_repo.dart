import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search_san_bund_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class CompetitionSearchSanBundRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();
  Future<CompetitionSearchSanBundResponse> competitionSearchSanBundFuture(
      String? range, String? bundle, String? sanware) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    // '/authenticate?username=$userCode&userType=$userType',
    String? token = await secureStorageProvider.read(key: 'token');

    var response = await apiProvider.get(
      configBaseUrl: ConfigBaseUrl.baseUrl,
      '/${_configProvider.apiBasePath}?api=get-competition-bundle-sanware-skus&QUOTOKEN=${Journey.token}&aprange1=$range&bundlename=$bundle&sanwareType=$sanware',
    );
    if ((response != null) || response!['data'] != null) {
      return CompetitionSearchSanBundResponse.fromJson(response);
    }
    throw BadRequestException(message: 'Authenticate Token Not Found');
  }
}
