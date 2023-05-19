import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/delete_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class DeleteSkuRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();
  Future<DeleteQuoteResponse> deleteSkuFuture(
      {projectID, quoteID, skuID}) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    print('TOken: ${Journey.token}');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=delete-sku-form-quote&QUOTOKEN=${Journey.token}',
      body: {
        "QUOTESKUID": skuID,
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
