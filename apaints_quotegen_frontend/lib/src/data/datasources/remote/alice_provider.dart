import 'dart:io';
import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:alice/alice.dart';

class AliceProvider {
  Alice? _alice;

  AliceProvider() {
    _alice = Alice(
      showNotification: true,
      showShareButton: true,
      // darkTheme: true,
    );
  }

  void setNavigatorKey() {
    _alice?.setNavigatorKey(getSingleton<AppConfigProvider>().navigatorKey);
  }

  void setHttpClient(HttpClientRequest request) {
    _alice?.onHttpClientRequest(request);
  }

  Alice? getAlice() {
    return _alice;
  }
}
