import 'dart:convert';

import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/models/categories_model.dart';
import 'package:APaints_QGen/src/data/models/search_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/data/repositories/repository.dart';

// class GetSearchListRepository extends Repository {
//   final _configProvider = getSingleton<AppConfigProvider>();
//   Future<SearchResponseModel> getSearchListFuture(String searchItem) async {
//     final secureStorageProvider = getSingleton<SecureStorageProvider>();
//     String? token = await secureStorageProvider.read(key: 'token');

//     var response = await apiProvider.get(
//       configBaseUrl: ConfigBaseUrl.baseUrl,
//       '/${_configProvider.apiBasePath}?api=search-universal&QUOTOKEN=${Journey.token}&search=$searchItem',
//     );
//     if ((response != null) || response!['data'] != null) {
//       return SearchResponseModel.fromJson(response);
//     }
//     throw BadRequestException(message: 'Authenticate Token Not Fount');
//   }
// }

abstract class SearchRepository extends Repository {
  Future<List<SKUData>> searchLists(String query);
}

class SearchRepositoryImpl extends SearchRepository {
  @override
  Future<List<SKUData>> searchLists(String query) async {
    final _configProvider = getSingleton<AppConfigProvider>();

    var response = await apiProvider.get(
      configBaseUrl: ConfigBaseUrl.baseUrl,
      '/${_configProvider.apiBasePath}?api=search-universal&QUOTOKEN=${Journey.token}&search=$query',
    );

    if ((response != null) || response!['data'] != null) {
      if (response.isNotEmpty) {
        List<SKUData> recipes =
            SKUResponse.fromJson(response).data ?? [];
        return recipes;
      } else {
        throw Exception('Failed');
      }
    }
    return [];
  }
}
