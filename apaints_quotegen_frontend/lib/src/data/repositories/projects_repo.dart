import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/get_projects_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class GetProjectsRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  // var response = await apiProvider.get(
  //   configBaseUrl: ConfigBaseUrl.baseUrl,
  //   '/${_configProvider.apiBasePath}?api=cat-all-list&QUOTOKEN=$token',
  // );
  Future<GetProjectsResponseModel> getProjectsFuture(int pageNum) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.getToken();
    logger('Token: ${Journey.token}');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=user-project-list&QUOTOKEN=${Journey.token}&page=$pageNum',
      body: {},
    );
    if ((response != null)) {
      return GetProjectsResponseModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
