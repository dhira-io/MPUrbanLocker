import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';



class ColorUtils {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
class AppVersion {
  Future<String> getAppVersion() async {
   final packageInfo = await PackageInfo.fromPlatform();
   final String appVersion = packageInfo.version;
   return appVersion;
  }

}
