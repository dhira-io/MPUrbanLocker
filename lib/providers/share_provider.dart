
import 'dart:convert';
import 'dart:io';
import 'package:digilocker_flutter/screens/shared_doc_list_screen.dart';
import 'package:digilocker_flutter/utils/FileUtils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';

enum ShareOption { link, qr }

enum ProtectionOption { pin, withoutPin }

enum DurationOption { fifteenMin, oneHour, twentyFourHours, custom }

enum PermissionOption { viewOnly, viewAndDownload }

class ShareProvider with ChangeNotifier {
  int _currentStep = 0;
  bool _isFlowComplete = false;
  ShareResponseModel? _objShareResponse;
  ShareOption? _selectedOption;
  ProtectionOption? _selectedProtectionOption;
  DurationOption? _selectedDurationOption;
  PermissionOption? _selectedPermissionOption;
  Map<String, dynamic> _reqParams = {};
  final TextEditingController _shareWithController = TextEditingController();
  DateTime? _customExpiryDate;
  bool _isLoading = false;

  int get currentStep => _currentStep;
  bool get isFlowComplete => _isFlowComplete;
  ShareResponseModel? get objShareResponse => _objShareResponse;
  ShareOption? get selectedOption => _selectedOption;
  ProtectionOption? get selectedProtectionOption => _selectedProtectionOption;
  DurationOption? get selectedDurationOption => _selectedDurationOption;
  PermissionOption? get selectedPermissionOption => _selectedPermissionOption;
  TextEditingController get shareWithController => _shareWithController;
  DateTime? get customExpiryDate => _customExpiryDate;
  bool get isLoading => _isLoading;

  ShareProvider() {
    _shareWithController.addListener(() {
      notifyListeners();
    });
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setFlowComplete(bool isComplete) {
    _isFlowComplete = isComplete;
    notifyListeners();
  }

  void setSelectedOption(ShareOption? option) {
    _selectedOption = option;
    notifyListeners();
  }

  void setSelectedProtectionOption(ProtectionOption? option) {
    _selectedProtectionOption = option;
    notifyListeners();
  }

  void setSelectedDurationOption(DurationOption? option) {
    _selectedDurationOption = option;
    if (option != DurationOption.custom) {
      _customExpiryDate = null;
    }
    notifyListeners();
  }

  void setSelectedPermissionOption(PermissionOption? option) {
    _selectedPermissionOption = option;
    notifyListeners();
  }

  void setCustomExpiryDate(DateTime? date) {
    _customExpiryDate = date;
    _selectedDurationOption = DurationOption.custom;
    notifyListeners();
  }

  Future<void> apicall_shareIDGenerate(
      BuildContext context, String documentId) async {
    _isLoading = true;
    notifyListeners();
    String customExpiry = DateTime.now().toUtc().toIso8601String();
    String expiresIn = '';
    if (_selectedDurationOption == DurationOption.custom) {
      expiresIn = 'custom';
      customExpiry = _customExpiryDate!.toUtc().toIso8601String();
    } else if (_selectedDurationOption == DurationOption.fifteenMin) {
      expiresIn = '15m';
    } else if (_selectedDurationOption == DurationOption.oneHour) {
      expiresIn = '1h';
    } else if (_selectedDurationOption == DurationOption.twentyFourHours) {
      expiresIn = '24h';
    }

    _reqParams = {
      "shareMethod": _selectedOption == ShareOption.qr ? "qr" : "link",
      "protectionType":
      _selectedProtectionOption == ProtectionOption.pin ? "pin" : "withoutpin",
      "canDownload":
      _selectedPermissionOption == PermissionOption.viewOnly ? false : true,
      "expiresIn": expiresIn,
      "customExpiry": customExpiry,
    };

    try {
      final apiService = context.read<ApiService>();

      final Map<String, dynamic> response = await apiService.postRequest(
        AppConstants.shareDocumentEndpoint(documentId),
        includeAuth: true,
        body: _reqParams,
      );

      if (response['success'] == true && response['data'] != null) {
        _objShareResponse = ShareResponseModel.fromJson(response['data']);
        _isFlowComplete = true;
      } else {
        String errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: errorMessage);
      }
    } on NoInternetException catch (e) {
      Fluttertoast.showToast(msg: '${e.toString()}');
    } catch (e) {
      debugPrint('Fetch Error: $e');
      Fluttertoast.showToast(msg: '${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> apicall_put_shareWithName(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    final String shareID = _objShareResponse?.shareId ?? "";
    _reqParams["sharedWithName"] = _shareWithController.text;

    try {
      final apiService = context.read<ApiService>();

      final Map<String, dynamic> response = await apiService.putRequest(
        AppConstants.editShareDocumentEndpoint(shareID),
        includeAuth: true,
        body: _reqParams,
      );

      if (response['success'] != true || response['data'] == null) {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Something went wrong',
        );
        return;
      }

      final ShareResponseModel model =
      ShareResponseModel.fromJson(response['data']);

      if (model.qrCode != null) {
        final File qrFile = await FileUtils.base64ToImageFile(model.qrCode!);

        await SharePlus.instance.share(
          ShareParams(files: [XFile(qrFile.path)]),
        );

        await _redirect(context);
      } else {
        final result = await SharePlus.instance.share(
          ShareParams(text: model.shareUrl),
        );

        if (result.status == ShareResultStatus.success ||
            result.status == ShareResultStatus.dismissed) {
          await _redirect(context);
        }
      }
    } on NoInternetException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      debugPrint('Share flow error: $e');
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _redirect(BuildContext context) async {
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SharedDocListScreen(),
      ),
    );
  }
}

class ShareResponseModel {
  final String shareId;
  final String shareToken;
  final String shareUrl;
  final String protectionType;
  final String? pin;
  final bool canDownload;
  final DateTime expiresAt;
  final String sharedWithName;
  final String? qrCode;

  ShareResponseModel({
    required this.shareId,
    required this.shareToken,
    required this.shareUrl,
    required this.protectionType,
    this.pin,
    required this.canDownload,
    required this.expiresAt,
    required this.sharedWithName,
    this.qrCode,
  });

  factory ShareResponseModel.fromJson(Map<String, dynamic> json) {
    return ShareResponseModel(
      shareId: json['shareId'] as String,
      shareToken: json['shareToken'] as String,
      shareUrl: json['shareUrl'] as String,
      protectionType: json['protectionType'] as String,
      pin: json['pin']?.toString(),
      canDownload: json['canDownload'] as bool,
      expiresAt: DateTime.parse(json['expiresAt']),
      sharedWithName: json['sharedWithName'] as String,
      qrCode: json['qrCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareId': shareId,
      'shareToken': shareToken,
      'shareUrl': shareUrl,
      'protectionType': protectionType,
      'pin': pin,
      'canDownload': canDownload,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'sharedWithName': sharedWithName,
      'qrCode': qrCode,
    };
  }
}
