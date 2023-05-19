import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

class GetSkuRepository extends Repository {
  final _configProvider = getSingleton<AppConfigProvider>();

  // var response = await apiProvider.get(
  //   configBaseUrl: ConfigBaseUrl.baseUrl,
  //   '/${_configProvider.apiBasePath}?api=cat-all-list&QUOTOKEN=$token',
  // );
  Future<SKUResponse> skuFuture({category, brand, range, area, limit}) async {
    final secureStorageProvider = getSingleton<SecureStorageProvider>();
    String? token = await secureStorageProvider.read(key: 'token');
    var response = await apiProvider.post(
      '/${_configProvider.apiBasePath}/?api=skds-list&QUOTOKEN=${Journey.token}',
      body: {
        "category": category,
        "brand": brand,
        "range": range,
        "area": area,
        "limit": 1,
      },
    );
    if ((response != null)) {
      return SKUResponse.fromJson(response);
    }
    throw BadRequestException(
        message: response?['statusMessage'] ?? 'Login Error');
  }
}
