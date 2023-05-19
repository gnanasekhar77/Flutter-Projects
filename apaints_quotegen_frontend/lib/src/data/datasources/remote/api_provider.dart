// ignore_for_file: prefer_for_elements_to_map_fromiterable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/alice_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/connectivity_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/models/fr_journey.dart';
import 'package:APaints_QGen/src/data/repositories/get_token_repo.dart';
import 'package:alice/core/alice_http_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:retry/retry.dart';

final _getTokenRepo = getSingleton<GetTokenRepository>();

class APIProvider {
  final _configProvider = getSingleton<AppConfigProvider>();
  final _connectivityProvider = getSingleton<ConnectivityProvider>();
  final r = const RetryOptions(maxAttempts: 2);
  Map<String, dynamic> _authenticationHeaders = {};
  Map<String, dynamic> _frAuthenticationHeaders = {};

  void setAuthenticationHeaders({
    required String token,
    // required String phoneNumber,
  }) {
    _authenticationHeaders = {
      HttpHeaders.authorizationHeader: '$token',
    };
  }

  Future<void> setFRAuthenticationHeaders({
    required String userType,
    required String userCode,
  }) async {
    String? token = await _generateApiToken(userType, userCode);
    _frAuthenticationHeaders = {
      "X-Access-Token": token,
    };
    FRJourney.setOtpToken = token;
  }

  Map<String, String> _getHeaders({Map<String, String>? header}) {
    return {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      // 'platform': _configProvider.platform,
      'app-version': _configProvider.appVersionNormalizedString,
      'application-type': _configProvider.applicationType,
      if (header != null) ...(header),
      ..._authenticationHeaders,
    };
  }

  Map<String, String> _getFRHeaders({Map<String, String>? header}) {
    return {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      // 'platform': _configProvider.platform,
      'app-version': _configProvider.appVersionNormalizedString,
      'application-type': _configProvider.applicationType,
      if (header != null) ...(header),
      ..._frAuthenticationHeaders,
    };
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decodedMap;
    String? formattedErrorString;
    try {
      decodedMap = json.decode(response.body);
      if (decodedMap.containsKey('error') &&
          decodedMap['error'].containsKey('message')) {
        formattedErrorString = decodedMap['error']['message'];
      }
    } catch (e, _) {
      throw BadRequestException(
        message: 'Something went wrong',
      );
    }
    switch (response.statusCode) {
      case 200:
        var logger = Logger();

        logger.d(
            'RESPONSE: ${decodedMap?.toString().handleOverflow(1000) ?? ''}');
        // logger('RESPONSE: ${decodedMap?.toString().handleOverflow(250) ?? ''}');
        return decodedMap;
      case 201:
        logger(
            'RESPONSE: ${decodedMap?.toString().handleOverflow(1000) ?? ''}');
        return decodedMap;
      case 400:
        if (formattedErrorString != null && formattedErrorString.isNotEmpty) {
          throw BadRequestException(
            message: formattedErrorString,
          );
        }
        throw BadRequestException(message: 'Something went wrong');
      case 401:
        if (formattedErrorString != null && formattedErrorString.isNotEmpty) {
          throw AuthenticationException(
            message: formattedErrorString,
          );
        }
        throw AuthenticationException(message: 'Authentication error');
      case 500:
        if (formattedErrorString != null && formattedErrorString.isNotEmpty) {
          throw InternalServerError(
            message: formattedErrorString,
          );
        }
        throw InternalServerError(message: 'Authentication error');
      default:
        throw AsianPaintsException(
          message: 'Something went wrong',
        );
    }
  }

  String _getQueryParameters(Map<String, dynamic>? params) {
    if (params == null) return '';
    List<String> retQueryParameters = [];
    for (final MapEntry<String, dynamic> entry in params.entries) {
      if (entry.value is String) {
        retQueryParameters.add('${entry.key}=${entry.value}');
      }
    }
    return '?${retQueryParameters.join('&')}';
  }

  dynamic _handleStoreLocationResp(http.Response response) {
    String? formattedErrorString;
    dynamic decodedMap;
    decodedMap = json.decode(response.body);

    Map<String, dynamic> mapResponse = Map.fromIterable(decodedMap,
        key: (item) => item['OFFICE_CODE'],
        value: (item) => {
              'OFFICE_CODE': item['OFFICE_CODE'],
              'WAREHOUSE_ID': item['WAREHOUSE_ID'],
              'OFFICE_NAME': item['OFFICE_NAME'],
              'OFFICE_ID': item['OFFICE_ID']
            });
    switch (response.statusCode) {
      case 200:
        logger('RESPONSE: ${response.toString().handleOverflow(0)}');
        return mapResponse;
      case 400:
        if (formattedErrorString != null && formattedErrorString.isNotEmpty) {
          throw BadRequestException(
            message: formattedErrorString,
          );
        }
        throw BadRequestException(message: 'Something went wrong');
      case 401:
        if (formattedErrorString != null && formattedErrorString.isNotEmpty) {
          throw AuthenticationException(
            message: formattedErrorString,
          );
        }
        throw AuthenticationException(message: 'Something went wrong');
      case 500:
        if (formattedErrorString != null && formattedErrorString.isNotEmpty) {
          throw InternalServerError(
            message: formattedErrorString,
          );
        }
        throw InternalServerError(message: 'Authentication error');
      default:
        throw AsianPaintsException(
          message: 'Something went wrong',
        );
    }
  }

  Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Map<String, String>? header,
    skipBaseUrl = false,
    ConfigBaseUrl configBaseUrl = ConfigBaseUrl.baseUrl,
  }) async {
    try {
      bool connection = await _connectivityProvider.checkConnection();
      if (connection) {
        Map<String, String> headers = _getHeaders(
          header: header,
        );

        endpoint = endpoint + _getQueryParameters(params);

        logger('GET REQUEST');
        logger(
            'ENDPOINT: ${skipBaseUrl ? endpoint : '${_configProvider.apiBaseUrl}/$endpoint'}');
        logger('HEADERS: $headers');

        String baseUrl = _configProvider.apiBaseUrl;
        switch (configBaseUrl) {
          case ConfigBaseUrl.baseUrl:
            baseUrl = _configProvider.apiBaseUrl;
            headers = _getHeaders(header: header);
            break;
          case ConfigBaseUrl.baseUrl:
            baseUrl = _configProvider.apiBaseUrl;
            headers = _getFRHeaders(header: header);
            break;
          // case ConfigBaseUrl.FR_LOGIN_BASE_URL:
          //   baseUrl = _configProvider.apiFRLoginUrl;
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_STORELOCATION_BASE_URL:
          //   baseUrl = _configProvider.apiFRStoreLocationUrl;
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_OTP_BASE_URL:
          //   baseUrl = _configProvider.getOTpApi;
          //   headers = _getFROtpHeaders(header: header);
          //   break;
        }

        final response = await r.retry(
          () => http
              .get(
                Uri.parse(skipBaseUrl ? endpoint : '$baseUrl/$endpoint'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 20))
              .interceptWithAlice(getSingleton<AliceProvider>().getAlice()!),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        logger('RESPONSE CODE: ${response.statusCode}');
        switch (configBaseUrl) {
          case ConfigBaseUrl.baseUrl:
            return _handleResponse(response);

          // case ConfigBaseUrl.FR_BASE_URL:
          //   return _handleResponse(response);

          // case ConfigBaseUrl.FR_LOGIN_BASE_URL:
          //   return _handleResponse(response);

          // case ConfigBaseUrl.FR_STORELOCATION_BASE_URL:
          //   return _handleStoreLocationResp(response);
          // case ConfigBaseUrl.FR_OTP_BASE_URL:
          //   return _handleStoreLocationResp(response);
        }
      } else {
        FlutterToastProvider().show(message: 'No internet connection');

        throw NetworkException(
          message: 'No internet connection',
        );
      }
    } on TimeoutException {
      FlutterToastProvider().show(message: 'Poor network connection');
      throw AsianPaintsException(message: 'Poor network connection');
    } on SocketException {
      FlutterToastProvider()
          .show(message: "Sorry! Can't reach servers at the moment");

      throw AsianPaintsException(
          message: "Sorry! Can't reach servers at the moment");
    } catch (e, st) {
      logES(e, st);
      throw BadRequestException(message: e.toString());
    }
  }

  Future<String?> _generateApiToken(userType, userCode) async {
    var tokenModel = await _getTokenRepo.getTokenFuture(userType, userCode);
    return tokenModel.accessToken;
  }

  Future<Map<String, dynamic>?> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? header,
    skipBaseUrl = false,
    ConfigBaseUrl configBaseUrl = ConfigBaseUrl.baseUrl,
    var addOrder,
  }) async {
    try {
      bool connection = await _connectivityProvider.checkConnection();
      logger("Connection: $connection");

      if (connection) {
        Map<String, String> headers = _getHeaders(
          header: header,
        );
        logger('POST REQUEST');
        logger(
            'ENDPOINT: ${skipBaseUrl ? endpoint : '${_configProvider.apiBaseUrl}/$endpoint'}');
        logger('HEADERS: $headers');
        logger('BODY: ${jsonEncode(body)}');
        String baseUrl = _configProvider.apiBaseUrl;
        switch (configBaseUrl) {
          case ConfigBaseUrl.baseUrl:
            baseUrl = _configProvider.apiBaseUrl;
            headers = _getHeaders(header: header);
            break;
          // case ConfigBaseUrl.FR_BASE_URL:
          //   baseUrl = _configProvider.apiFRBaseUrl;
          //   if (body.containsKey("userType") && body.containsKey("userCode")) {
          //     await setFRAuthenticationHeaders(
          //         userType: body["userType"], userCode: body["userCode"]);
          //   }
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_LOGIN_BASE_URL:
          //   baseUrl = _configProvider.apiFRLoginUrl;
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_STORELOCATION_BASE_URL:
          //   baseUrl = _configProvider.apiFRStoreLocationUrl;
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_OTP_BASE_URL:
          //   baseUrl = _configProvider.getOTpApi;
          //   headers = _getFROtpHeaders(header: header);
          //   break;
        }
        final response = await r.retry(
          () => http
              .post(
                Uri.parse(skipBaseUrl ? endpoint : '$baseUrl/$endpoint'),
                body: json.encode(body),
                headers: headers,
              )
              .timeout(const Duration(seconds: 20))
              .interceptWithAlice(getSingleton<AliceProvider>().getAlice()!),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        logger('RESPONSE CODE: ${response.statusCode}');
        return _handleResponse(response);
      } else {
        FlutterToastProvider().show(message: 'No internet connection');
        throw NetworkException(
          message: 'No internet connection',
        );
      }
    } on TimeoutException {
      FlutterToastProvider().show(message: 'Poor internet connection');
      throw AsianPaintsException(message: 'Poor network connection');
    } on SocketException catch (e) {
      logger(e.osError!.message);
      FlutterToastProvider()
          .show(message: "Sorry can't reach the servers at the moment");
      throw AsianPaintsException(
        message: "Sorry can't reach the servers at the moment",
      );
    } catch (e, st) {
      logES(e, st);
      throw BadRequestException(message: e.toString());
    }
  }

  Future<bool> putFile(
    String endpoint, {
    required File file,
    required String fileName,
    Map<String, String>? header,
    skipBaseUrl = false,
  }) async {
    try {
      bool connection = await _connectivityProvider.checkConnection();
      if (connection) {
        Map<String, String> headers = _getHeaders(
          header: header,
        );
        headers = {
          HttpHeaders.contentTypeHeader: "image/png",
        };
        logger('POST REQUEST');
        logger(
            'ENDPOINT: ${skipBaseUrl ? endpoint : '${_configProvider.apiBaseUrl}/$endpoint'}');
        logger('HEADERS: $headers');

        List<int> body = await file.readAsBytes();
        final response = await r.retry(
          () => http
              .put(
                Uri.parse(skipBaseUrl
                    ? endpoint
                    : '${_configProvider.apiBaseUrl}/$endpoint'),
                body: body,
                headers: headers,
              )
              .timeout(const Duration(seconds: 20)),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        logger("RESPONSE: ${response.statusCode}");
        return response.statusCode == 200;
      } else {
        throw NetworkException(
          message: 'No internet connection',
        );
      }
    } on TimeoutException {
      throw AsianPaintsException(message: 'Poor network connection');
    } on SocketException {
      throw AsianPaintsException(
          message: "Sorry! Can't reach the servers at the moment");
    } catch (e, st) {
      logES(e, st);
      throw BadRequestException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>?> frPut(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? header,
    skipBaseUrl = false,
    ConfigBaseUrl configBaseUrl = ConfigBaseUrl.baseUrl,
    var addOrder,
  }) async {
    try {
      bool connection = await _connectivityProvider.checkConnection();

      if (connection) {
        Map<String, String> headers = _getHeaders(
          header: header,
        );
        logger('POST REQUEST');
        logger(
            'ENDPOINT: ${skipBaseUrl ? endpoint : '${_configProvider.apiBaseUrl}/$endpoint'}');
        logger('HEADERS: $headers');
        logger('BODY: ${jsonEncode(body)}');
        var bodyData;
        String baseUrl = _configProvider.apiBaseUrl;
        switch (configBaseUrl) {
          case ConfigBaseUrl.baseUrl:
            baseUrl = _configProvider.apiBaseUrl;
            if (body.containsKey("addOrder")) {
              bodyData = addOrder;
            } else {
              bodyData = body;
            }
            headers = _getHeaders(header: header);
            break;
          case ConfigBaseUrl.baseUrl:
            baseUrl = _configProvider.apiBasePath;
            if (body.containsKey("userType") && body.containsKey("userCode")) {
              await setFRAuthenticationHeaders(
                  userType: body["userType"], userCode: body["userCode"]);
            }
            headers = _getFRHeaders(header: header);
            if (body.containsKey("addOrder")) {
              bodyData = addOrder;
            } else {
              bodyData = body;
            }

            break;
          // case ConfigBaseUrl.FR_LOGIN_BASE_URL:
          //   baseUrl = _configProvider.apiFRLoginUrl;
          //   if (body.containsKey("addOrder")) {
          //     bodyData = addOrder;
          //   } else {
          //     bodyData = body;
          //   }
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_STORELOCATION_BASE_URL:
          //   baseUrl = _configProvider.apiFRStoreLocationUrl;
          //   headers = _getFRHeaders(header: header);
          //   break;
          // case ConfigBaseUrl.FR_OTP_BASE_URL:
          //   break;
        }
        final response = await r.retry(
          () => http
              .put(
                Uri.parse(skipBaseUrl ? endpoint : '$baseUrl/$endpoint'),
                body: json.encode(bodyData),
                headers: headers,
              )
              .timeout(const Duration(seconds: 20))
              .interceptWithAlice(getSingleton<AliceProvider>().getAlice()!),
          retryIf: (e) => e is SocketException || e is TimeoutException,
        );
        logger('RESPONSE CODE: ${response.statusCode}');
        return _handleResponse(response);
      } else {
        throw NetworkException(
          message: 'No internet connection',
        );
      }
    } on TimeoutException {
      throw AsianPaintsException(message: 'Poor network connection');
    } on SocketException {
      throw AsianPaintsException(
          message: "Sorry! Cannot reach the servers at the moment");
    } catch (e, st) {
      logES(e, st);
      throw BadRequestException(message: e.toString());
    }
  }
}
