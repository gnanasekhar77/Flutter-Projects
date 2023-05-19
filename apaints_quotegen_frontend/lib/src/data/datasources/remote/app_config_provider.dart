import 'dart:io';

import 'package:flutter/material.dart';

enum ConfigBaseUrl {
  baseUrl,
}

class AppConfigProvider {
  late GlobalKey<NavigatorState> _navigatorKey;
  late String _appVersion;
  late void Function(String? message, bool showHideButton) _globalSnackbar;

  /* String get apiBaseUrl => "https://apidev.asianpaints.com";
  String get apiBasePath => "codetru-api-check-proxy"; */

  /* UAT Proxy*/
  String get apiBaseUrl => "https://apidev.asianpaints.com";
  String get apiBasePath => "quote-sprint-one";

  /* Dev Proxy*/
  // String get apiBaseUrl => "https://apidev.asianpaints.com";
  // String get apiBasePath => "quote-sprint-2-dev";
  // String get apiBasePath => "bath_quotation";

  String get appVersion => _appVersion;
  String get appStoreUrl =>
      'https://apps.apple.com/us/app/colligo/id6444064660';
  String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=com.asianpaints.apg.collections';
  String get appVersionNormalizedString =>
      "1.0.0"; //_appVersionNormalizedString;
  String get platform => Platform.operatingSystem;
  String get applicationType => 'asianpaints';
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  void Function(String? message, bool showHideButton) get globalSnackbar =>
      _globalSnackbar;

  void setNavigatorKey(key) {
    _navigatorKey = key;
  }

  void setGlobalSnackbar(
      void Function(String? message, bool showHideButton) globalSnackbar) {
    _globalSnackbar = globalSnackbar;
  }
}
