import 'package:package_info_plus/package_info_plus.dart';

class AppInfoProvider {
  late PackageInfo _packageInfo;

  String get appVersion => _packageInfo.version;

  Future<void> setupAppInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
