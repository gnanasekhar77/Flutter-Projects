import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/login_internal_user_data_model.dart';
import 'package:APaints_QGen/src/data/models/login_model.dart';
import 'package:APaints_QGen/src/data/repositories/login_repo_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Status { Initial, Loading, Loaded, Failed }

enum IsLoggedIn { Initial, Loaded, Failed }

class LoginProvider extends ChangeNotifier {
  var loginRepositoryImpl = LoginRepositoryImpl();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();

  Status _getStatus = Status.Initial;
  IsLoggedIn _isLoggedIn = IsLoggedIn.Initial;
  String? _failedMessage;
  String? _isCountrySelected;
  String? _languageSelected;

  TextEditingController registerEmail = TextEditingController();
  TextEditingController enterOTP = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  LoginInternalUserDataModel? loginModel;

  String? deviceToken;
  String? get failedMessage => _failedMessage;
  Status get getStatus => _getStatus;
  IsLoggedIn get loginStatus => _isLoggedIn;
  String? get isCountrySelected => _isCountrySelected;
  String? get languageSelected => _languageSelected;

  Future<LoginInternalUserDataModel?> signIn() async {
    try {
      _getStatus = Status.Loading;
      notifyListeners();
      deviceToken = "";
      if (!kIsWeb) {
        deviceToken =
            await _secureStorageProvider.read(key: 'firebaseToken') ?? "";
      }
      var response = await loginRepositoryImpl.loginFuture(
          nameController.text, passwordController.text, deviceToken);
      if (response.status == "200") {
        // await _secureStorageProvider.saveUserToDisk(response);
        // await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        loginModel = response;
        // if (response.userinfo?. == 1) {
        //   saveCountrySelectedStatus("true");
        //   saveCountrytoDisk(
        //       response.countries?[0].countryCode,
        //       response.countries?[0].currencyCode,
        //       response.countries?[0].numberFormat,
        //       response.countries?[0].apiUserName,
        //       response.countries?[0].apiUserPassword,
        //       response.countries?[0].ocrModelId,
        //       response.countries?[0].ocrStatus,
        //       response.countries?[0].daysBack.toString(),
        //       response.countries?[0].decimal,
        //       response.countries?[0].id,
        //       response.countries?[0].countryPriceLimit);
        // }
        _getStatus = Status.Loaded;
        notifyListeners();
        return loginModel;
      } else {
        _failedMessage = response.statusMessage;
        _getStatus = Status.Failed;
        notifyListeners();
      }
    } catch (e) {
      _failedMessage = e.toString();
      _getStatus = Status.Failed;
      notifyListeners();
    }
    return null;
  }

  // ignore: always_declare_return_types
  // appStartProvider() async {
  //   String? isLoggedIn = await _secureStorageProvider.read(key: 'isLoggedIn');
  //   String? countrySelected =
  //       await _secureStorageProvider.read(key: 'isCountrySelectedStatus');
  //   String? languageSelected =
  //       await _secureStorageProvider.read(key: 'languageSelected');
  //   String? currencyCode =
  //       await _secureStorageProvider.read(key: 'currencyCode');
  //   String? numberFormat =
  //       await _secureStorageProvider.read(key: 'numberFormat');
  //   String? daysBack = await _secureStorageProvider.read(key: 'daysBack');
  //   String? decimal = await _secureStorageProvider.read(key: 'decimal');
  //   String? apiUserName = await _secureStorageProvider.read(key: 'apiUserName');
  //   String? apiPassword = await _secureStorageProvider.read(key: 'apiPassword');
  //   String? ocrModelId = await _secureStorageProvider.read(key: 'ocrModelId');
  //   if (isLoggedIn == null) {
  //     _isLoggedIn = IsLoggedIn.Failed;
  //     _languageSelected = languageSelected;
  //     Journey.appLanguage = languageSelected;
  //     notifyListeners();
  //   } else if (isLoggedIn == 'true') {
  //     loginModel = await _secureStorageProvider.getUserFromDisk();
  //     _isCountrySelected = countrySelected;
  //     _isLoggedIn = IsLoggedIn.Loaded;
  //     Journey.appLanguage = languageSelected;
  //     Journey.currencyCode = currencyCode;
  //     Journey.numberFormat = numberFormat;
  //     Journey.apiUserName = apiUserName;
  //     Journey.apiPassword = apiPassword;
  //     Journey.ocrModelId = ocrModelId;
  //     Journey.daysBack = daysBack;
  //     Journey.decimalLimit = decimal;
  //     _languageSelected = languageSelected;
  //     notifyListeners();
  //   } else {
  //     Journey.appLanguage = languageSelected;
  //     Journey.currencyCode = currencyCode;
  //     Journey.daysBack = daysBack;
  //     _languageSelected = languageSelected;
  //     _isLoggedIn = IsLoggedIn.Failed;
  //     notifyListeners();
  //   }
  // }

  // ignore: always_declare_return_types
  saveCountrySelectedStatus(countrySelected) async {
    await _secureStorageProvider.add(
        key: 'isCountrySelectedStatus', value: countrySelected);
  }

  // ignore: always_declare_return_types
  saveCountrytoDisk(
      countrySelected,
      currencyCode,
      numberFormat,
      apiUserName,
      apiUserPassword,
      ocrModelId,
      ocrStatus,
      daysBack,
      decimal,
      countryId,
      countryPriceLimit) async {
    await _secureStorageProvider.add(
        key: 'isCountrySelected', value: countrySelected);
    await _secureStorageProvider.add(key: 'currencyCode', value: currencyCode);
    await _secureStorageProvider.add(key: 'numberFormat', value: numberFormat);
    await _secureStorageProvider.add(key: 'apiUserName', value: apiUserName);
    await _secureStorageProvider.add(
        key: 'apiPassword', value: apiUserPassword);
    await _secureStorageProvider.add(key: 'ocrModelId', value: ocrModelId);
    await _secureStorageProvider.add(
        key: 'ocrStatus', value: ocrStatus.toString());
    await _secureStorageProvider.add(key: 'daysBack', value: daysBack);
    await _secureStorageProvider.add(key: 'decimal', value: decimal);
    await _secureStorageProvider.add(key: 'countryId', value: countryId);
    await _secureStorageProvider.add(
        key: 'countryPriceLimit', value: countryPriceLimit);
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    nameController.clear();
    passwordController.clear();
    super.dispose();
  }
}
