import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/view_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class CloneProjectRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<ViewQuoteResponse> cloneProjectFuture(
      {projectid,
      projectName,
      contactPerson,
      mobileNumber,
      siteAddress,
      noOfBathrooms}) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=clone-the-project&QUOTOKEN=${Journey.token}',
      body: {
        "projectid": projectid,
        "projectname": projectName,
        "contactperson": contactPerson,
        "mobilenumber": mobileNumber,
        "siteaddress": siteAddress,
        "noofbathrooms": noOfBathrooms,
      },
    );
    if ((response != null)) {
      return ViewQuoteResponse.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
