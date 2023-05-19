import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/export_project_response_model.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class ExportProjectRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<ExportProjectResponseModel> getExportProjectFuture(
      projectID, quoteID) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=project-to-pdf&QUOTOKEN=${Journey.token}',
      body: {"PROJECTID": projectID, "QUOTEID": quoteID},
    );
    if ((response != null)) {
      return ExportProjectResponseModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
