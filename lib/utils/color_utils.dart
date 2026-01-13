import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';



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
class DataToImageFile {

 static Future<File> base64ToImageFile(String base64Data) async {
    // Remove data:image/...;base64, if present
    final cleanBase64 = base64Data.contains(',')
        ? base64Data.split(',').last
        : base64Data;

    final bytes = base64Decode(cleanBase64);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/shared_qr.png');

    await file.writeAsBytes(bytes);
    return file;
  }
}

