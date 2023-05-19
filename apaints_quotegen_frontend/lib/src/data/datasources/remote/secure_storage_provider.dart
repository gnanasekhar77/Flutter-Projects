import 'dart:convert';

import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/journey.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/models/external_user_login_model.dart';
import 'package:APaints_QGen/src/data/models/login_internal_user_data_model.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageProvider {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  IOSOptions _getIOSOptions() => const IOSOptions(
      // accessibility: IOSAccessibility.first_unlock,
      );

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: false,
      );

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false,
    ),
  );

  Future<void> add({required String key, String? value}) async {
    await _storage.write(
      key: key,
      value: value,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
  }

  Future<String?> read({required String key}) async {
    return await _storage.read(
      key: key,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
  }

  // Future<void> saveUserToDisk(UserDataModel userData) async {
  //   await add(key: 'isLoggedIn', value: 'true');
  //   await add(key: 'userDetails', value: userData.toJson());
  // }

  // Future<UserDataModel> getUserFromDisk() async {
  //   String? response = await read(key: 'userDetails');
  //   if (response != null) return UserDataModel.fromJson(response);
  //   throw AuthenticationException(
  //     message: LocaleKeys.userDetailsNotFound.translate(),
  //   );
  // }

  Future<void> saveSkuDetailsToDisk(List<SKUData> frLoginUserDataModel) async {
    await add(key: 'isFRLoggedIn', value: 'true');
    await add(key: 'userFRDetails', value: json.encode(frLoginUserDataModel));
  }

  Future<void> remove({required String key}) async {
    await _storage.delete(
      key: key,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
  }

  Future<void> removeUser() async {
    await remove(key: 'isLoggedIn');
    await remove(key: 'userDetails');
  }

  Future<void> saveFRUserToDisk(
      ExternalUserLoginModel frLoginUserDataModel) async {
    await add(key: 'isFRLoggedIn', value: 'true');
    await add(key: 'userFRDetails', value: json.encode(frLoginUserDataModel));
  }

  Future<void> saveMobileNumber(String? mobileNumber) async {
    await add(key: 'mobileNumber', value: mobileNumber);
  }

  Future<String> getMobileNumber() async {
    String? mobileNum = await read(key: 'mobileNumber');
    return mobileNum!;
  }

  Future<void> saveToken(String? token) async {
    await add(key: 'token', value: token);
  }

  Future<String> getToken() async {
    String? token = await read(key: 'token') ?? '0';
    return token;
  }

  Future<void> saveUsername(String? username) async {
    await add(key: 'username', value: username);
  }

  Future<String> getUsername() async {
    String? username = await read(key: 'username') ?? '';
    return username;
  }

  Future<void> saveEmail(String? email) async {
    await add(key: 'email', value: email);
  }

  Future<String> getEmail() async {
    String? email = await read(key: 'email') ?? '';
    return email;
  }

  Future<void> saveLoginType(String? logintype) async {
    await add(key: 'logintype', value: logintype);
  }

  Future<String> getLoginType() async {
    String? logintype = await read(key: 'logintype') ?? '';
    return logintype;
  }

  Future<void> saveIsExist(bool? isExist) async {
    await add(key: 'isExist', value: isExist.toString());
  }

  Future<String> getIsExist() async {
    String? isExist = await read(key: 'isExist') ?? '';
    return isExist;
  }

  Future<void> saveCartCount(int? cartCount) async {
    await add(key: 'cartCount', value: cartCount.toString());
  }

  Future<int> getCartCount() async {
    int? cartCount = int.parse(await read(key: 'cartCount') ?? '0');
    return cartCount;
  }

  Future<void> saveCartDetails(List<SKUData>? skuData) async {
    final String encodedData = json.encode(skuData ?? []);
    await add(key: 'skuData', value: encodedData);
  }

  List<SKUData> sku = [];

  Future<List<SKUData>> getCartDetails() async {
    String skuData = await read(key: 'skuData') ?? '';
    sku = json.decode(skuData);
    logger('List: $sku');
    return sku;
  }

  // Category
  Future<void> saveCategory(String? category) async {
    await add(key: 'category', value: category);
  }

  Future<String> getCategory() async {
    String? category = await read(key: 'category') ?? '';
    return category;
  }

// Brand
  Future<void> saveBrand(String? brand) async {
    await add(key: 'brand', value: brand);
  }

  Future<String> getBrand() async {
    String? brand = await read(key: 'brand') ?? '';
    return brand;
  }

//range
  Future<void> saveRange(String? range) async {
    await add(key: 'range', value: range);
  }

  Future<String> getRange() async {
    String? range = await read(key: 'range') ?? '';
    return range;
  }

  Future<void> saveTotalPrice(String? totalPrice) async {
    logger('Quantity: $totalPrice');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('totalPrice', totalPrice ?? '');
  }

  Future<String> getTotalPrice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? total = prefs.getString('totalPrice');

    logger('Quantity in Get: $total');

    return total ?? '';
  }

  Future<void> saveProjectID(String? projectID) async {
    logger('Quantity: $projectID');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('projectID', projectID ?? '');
  }

  Future<String> getProjectID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? projectID = prefs.getString('projectID');

    logger('Quantity in Get: $projectID');

    return projectID ?? '';
  }

  Future<LoginInternalUserDataModel> getFRUserFromDisk() async {
    String? response = await read(key: 'userFRDetails');

    if (response != null) {
      return LoginInternalUserDataModel.fromJson(json.decode(response));
    }
    throw AuthenticationException(
      message: 'User not found',
    );
  }

  Future<void> removeFRUser() async {
    await remove(key: 'isFRLoggedIn');
    await remove(key: 'userFRDetails');
  }

  Future<void> saveQuoteToDisk(List<SKUData> skuDataModel) async {
    var logger = Logger();
    logger.d('SKU Model: ${json.encode(skuDataModel)}');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String encodedData = SKUData.encode(skuDataModel);

    await prefs.setString('quote', encodedData);
    await add(key: 'quote', value: encodedData);
    // logger('Response in save quote: $encodedData');
  }

  List<SKUData>? itemList;
  Future<List<SKUData>?> getQuoteFromDisk() async {
    final prefs = await SharedPreferences.getInstance();

    // logger('Quote Str: ${prefs.getString('quote')}');

    final List<SKUData> itemList =
        SKUData.decode(prefs.getString('quote') ?? '');
    var logger = Logger();
    logger.d('SKU Model: ${json.encode(itemList)}');
    return itemList;
  }
}
