import 'dart:io';

import 'package:digilocker_flutter/providers/share_provider.dart';
import 'package:digilocker_flutter/screens/share_screen.dart';
import 'package:digilocker_flutter/utils/FileUtils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../components/common_appbar.dart';
import '../providers/shared_doc_list_provider.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';

class EditShareDetailsProvider with ChangeNotifier {
  final BuildContext context;
  final SharedDocModel document;

  late String _method;
  late String _protection;
  late DateTime _expiresOn;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _sharedWithController = TextEditingController();
  bool _isLoading = false;

  EditShareDetailsProvider(this.context, this.document) {
    _method = document.shareMethod == ShareOption.qr.name ? "Secure QR" : "Secure Link";
    _protection = document.protectionType == ProtectionOption.pin.name ? "Generate PIN" : "WithOut PIN";
    _pinController.text = document.pin ?? '';
    _sharedWithController.text = document.sharedWithName;
    _expiresOn = document.expiresAt;
  }

  // Getters
  String get method => _method;
  String get protection => _protection;
  DateTime get expiresOn => _expiresOn;
  TextEditingController get pinController => _pinController;
  TextEditingController get sharedWithController => _sharedWithController;
  bool get isLoading => _isLoading;

  void setMethod(String value) {
    _method = value;
    notifyListeners();
  }

  void setProtection(String value) {
    _protection = value;
    notifyListeners();
  }

  void setExpiresOn(DateTime value) {
    _expiresOn = value;
    notifyListeners();
  }

  Future<void> editShare(bool isShare) async {
    _isLoading = true;
    notifyListeners();

    String customExpiry = _expiresOn.toUtc().toIso8601String();
    var reqBody = {
      "shareMethod": _method == "Secure QR" ? ShareOption.qr.name : ShareOption.link.name,
      "protectionType": _protection == "Generate PIN" ? ProtectionOption.pin.name : ProtectionOption.withoutPin.name.toLowerCase(),
      "expiresIn": "custom",
      "customExpiry": customExpiry,
      "sharedWithName": _sharedWithController.text,
      "canDownload": document.canDownload
    };

    try {
      final apiService = context.read<ApiService>();
      final Map<String, dynamic> response = await apiService.putRequest(
        AppConstants.editShareDocumentEndpoint(document.id),
        includeAuth: true,
        body: reqBody,
      );

      if (response['success'] == true && response['data'] != null) {
        ShareResponseModel model = ShareResponseModel.fromJson(response["data"]);
        if (isShare) {
          var result;
          if (model.qrCode != null) {
            File objFile = await FileUtils.base64ToImageFile(model.qrCode ?? "");
            result = await SharePlus.instance.share(ShareParams(files: [XFile(objFile.path)]));
          } else {
            result = await SharePlus.instance.share(ShareParams(text: model.shareUrl));
          }
          if (result.status == ShareResultStatus.success && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          Fluttertoast.showToast(msg: response['message'] ?? 'Details saved');
          Navigator.of(context).pop();
        }
      } else {
        Fluttertoast.showToast(msg: response['message'] ?? 'Something went wrong');
      }
    } on NoInternetException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      debugPrint('Fetch Error: $e');
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSharedDoc() async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.deleteRequest(
        AppConstants.deleteShareEndpoint(document.id),
        includeAuth: true,
      );

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: response["message"] ?? "Link revoked");
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(msg: response['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      debugPrint('Delete Error: $e');
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _sharedWithController.dispose();
    super.dispose();
  }
}
