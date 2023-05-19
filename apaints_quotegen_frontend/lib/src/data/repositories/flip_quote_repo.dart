import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/flip_quote_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class FlipQuoteRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<FlipQuoteResponseModel> flipQuoteFuture(
      {projectid,
      quoteID,
      currentRange,
      selectedRange,
      createdType,
      areYouSure,
      quoteName
      }) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=flip-the-quote&QUOTOKEN=${Journey.token}',
      body: {
        "projectid": projectid,
        "quoteid": quoteID,
        "currentrange": currentRange,
        "selectedrange": selectedRange,
        "createdtype": createdType,
        "areyousure": areYouSure,
        "quotename": quoteName
      },
    );
    logger('In repo: $response');
    if ((response != null)) {
      return FlipQuoteResponseModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
