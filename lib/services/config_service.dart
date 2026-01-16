import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/doc_service_config.dart';

class ConfigService {
  static List<DocServiceConfig> docServices = [];

  static Future<void> loadConfig() async {
    final jsonStr =
    await rootBundle.loadString('assets/config/doc_services.json');
    final jsonList = json.decode(jsonStr) as List<dynamic>;

    docServices = jsonList
        .map((e) => DocServiceConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }
 static String getServiceImage(String checkType){
    String? imageString = ConfigService.docServices
        .firstWhere((e) => e.typeBackend == checkType)
        .imagePath;
    return imageString;  //?? 'assets/services/trade_license_certificate.png';
  }
}
