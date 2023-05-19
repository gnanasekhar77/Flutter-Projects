import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/create_quote_to_existing_project_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class CreateQuoteToProjectRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<CreateQuoteToExistingProjectResponseModel> createQuoteFuture(
      {quoteInfo,
      category,
      brand,
      range,
      discountAmount,
      totalPriceWithGST,
      quoteName,
      projectid,
      quoteType,
      isExist,
      quoteID,
      projectName,
      contactPerson,
      mobileNumber,
      siteAddress,
      noOfBathrooms}) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    print('TOken: ${Journey.token}');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=create-quote&QUOTOKEN=${Journey.token}',
      body: {
        "quoteinfo": quoteInfo,
        "category": category,
        "brand": brand,
        "range": range,
        "discountamount": discountAmount,
        "totalpricewithgst": totalPriceWithGST,
        "quotename": quoteName,
        "projectid": projectid,
        "quotetype": quoteType,
        "isExist": isExist,
        "quoteid": quoteID,
        "project_name": projectName,
        "contact_person": contactPerson,
        "mobile_number": mobileNumber,
        "site_address": siteAddress,
        "no_of_bath_rooms": noOfBathrooms,
      },
    );
    if ((response != null)) {
      return CreateQuoteToExistingProjectResponseModel.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
