import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/create_quote_to_existing_project_response_model.dart';
import 'package:APaints_QGen/src/data/models/delete_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class DeleteQuoteRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<DeleteQuoteResponse> deleteQuoteFuture(
      {
      projectID,
      quoteID,
      }) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    print('TOken: ${Journey.token}');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=delete-quote-form-project&QUOTOKEN=${Journey.token}',
      body: {
        
        "PROJECTID": projectID,
        "QUOTEID": quoteID,
        
      },
    );
    if ((response != null)) {
      return DeleteQuoteResponse.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
