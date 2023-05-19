import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';
import 'package:logger/logger.dart';

class ProjectDescriptionRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<GetProjectDescriptionModel> getProjectDescriptionFuture(
      projectID, quoteID) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    var logger = Logger();

    logger.d('${Journey.token}');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=user-project-list&QUOTOKEN=${Journey.token}&page=1',
      body: {
        "PROJECTID": projectID,
        "QUOTEID": quoteID ?? '',
      },
    );
    if ((response != null)) {
      return GetProjectDescriptionModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
