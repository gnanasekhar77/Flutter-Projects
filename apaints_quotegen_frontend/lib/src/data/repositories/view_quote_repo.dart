import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/view_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class ViewQuoteRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  // var response = await apiProvider.get(
  //   configBaseUrl: ConfigBaseUrl.baseUrl,
  //   '/${_configProvider.apiBasePath}?api=cat-all-list&QUOTOKEN=$token',
  // );
  Future<ViewQuoteResponse> viewQuoteFuture(
      {quoteInfo,
      discountAmount,
      totalpricewithgst,
      quotename,
      projectid,
      quotetype,
      isExist,
      projectName,
      contactPerson,
      mobileNumber,
      siteAddress,
      noOfBathrooms}) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=skds-list&QUOTOKEN=${Journey.token}',
      body: {
        "quoteinfo": quoteInfo,
        "discountamount": discountAmount,
        "totalpricewithgst": totalpricewithgst,
        "quotename": quotename,
        "projectid": projectid,
        "quotetype": quotetype,
        "isExist": isExist,
        "project_name": projectName,
        "contact_person": contactPerson,
        "mobile_number": mobileNumber,
        "site_address": siteAddress,
        "no_of_bath_rooms": noOfBathrooms,
      },
    );
    if ((response != null)) {
      return ViewQuoteResponse.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
