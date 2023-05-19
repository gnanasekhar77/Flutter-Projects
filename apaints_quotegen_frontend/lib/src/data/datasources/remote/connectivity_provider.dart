// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:io';

import 'package:APaints_QGen/src/core/utils/exceptions.dart';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider {
  bool offlineShown = false;
  final Connectivity _connectivity = Connectivity();
  final _configProvider = getSingleton<AppConfigProvider>();

  Future<bool> checkAPIStatus() async {
    if (kIsWeb) {
      return true;
    } else {
      final result = await InternetAddress.lookup(
        _configProvider.apiBaseUrl.replaceAll('https://', ''),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    }
  }

  Future<void> update(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      isOnline = await checkAPIStatus();
    } on SocketException catch (_) {
      isOnline = false;
    }
    if (!isOnline && !offlineShown) {
      offlineShown = true;
    }
    if (isOnline) {
      logger('CONNECTED TO: ${_configProvider.apiBaseUrl}');
    } else {
      logger('DISCONNECTED FROM: ${_configProvider.apiBaseUrl}');
    }
    if (offlineShown) {
      /* showSnackBar(
        message:
            AppLocalizations.of(NavigatorService.navigatorKey.currentContext!)
                    .internetConnection +
                ' ' +
                (isOnline
                    ? AppLocalizations.of(
                            NavigatorService.navigatorKey.currentContext!)
                        .backOnline
                    : AppLocalizations.of(
                            NavigatorService.navigatorKey.currentContext!)
                        .offline),
      ); */
    }
  }

  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen(update);
  }

  Future<bool> checkConnection() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      try {
        return checkAPIStatus();
      } on SocketException catch (e, st) {
        logES(e, st);
        throw NetworkException(message: e.toString());
      }
    }
    return false;
  }
}
