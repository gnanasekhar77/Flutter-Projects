import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/copy_quote_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class CopyQuoteRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<CopyQuoteResponse> copyQuoteFuture({projectID, quoteID, quoteName}) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=copy-the-quote&QUOTOKEN=${Journey.token}',
      body: {
        "projectid": projectID,
        "quoteid": quoteID,
        "quotename": quoteName,
       
      },
    );
    if ((response != null)) {
      return CopyQuoteResponse.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
