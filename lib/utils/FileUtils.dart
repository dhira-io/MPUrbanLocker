import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class FileUtils {

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