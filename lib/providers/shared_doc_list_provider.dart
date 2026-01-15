import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../utils/constants.dart';

class SharedDocListProvider extends ChangeNotifier {
  final List<SharedDocModel> documents = [];
  final List<SharedDocModel> _allDocuments = [];
  List<bool> expanded = [];
  bool isLoading = false;
  String errorMessage = '';
  String searchQuery = '';

  Future<void> apicall_GetAllShareDocList(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final apiService = context.read<ApiService>();

      final response = await apiService.getRequest(
        AppConstants.shareListEndpoint,
        includeAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['shares'];
        _allDocuments
          ..clear()
          ..addAll(
            list
                .where((e) => e['isRevoked'] == false)
                .map((e) => SharedDocModel.fromJson(e))
                .toList(),
          );

// initially show all
        documents
          ..clear()
          ..addAll(_allDocuments);

        expanded = List.generate(documents.length, (_) => false);

      } else {
        errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: errorMessage);
      }
    } catch (e) {
      debugPrint('Fetch Error: $e');
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> apicall_DeleteSharedDoc(
      BuildContext context,
      String id,
      ) async {
    print("calll");
    isLoading = true;
    notifyListeners();

    try {
      final apiService = context.read<ApiService>();

      final response = await apiService.deleteRequest(
        AppConstants.deleteShareEndpoint(id),
        includeAuth: true,
      );

      if (response['success'] == true) {

        // 🔥 REMOVE FROM LIST
        final index = documents.indexWhere((e) => e.id == id);

        if (index != -1) {
          documents.removeAt(index);
          expanded.removeAt(index);
        }

        Fluttertoast.showToast(msg: 'Share removed successfully');
      } else {
        errorMessage = response['message'] ?? 'Something went wrong';
        Fluttertoast.showToast(msg: errorMessage);
      }
    } catch (e) {
      debugPrint('Delete Error: $e');
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleExpanded(int index) {
    expanded[index] = !expanded[index];
    notifyListeners();
  }

  bool isExpanded(int index) => expanded[index];

  void searchDocuments(String query) {
    searchQuery = query.toLowerCase();

    documents
      ..clear()
      ..addAll(
        _allDocuments.where((doc) {
          return doc.documentName.toLowerCase().contains(searchQuery) ||
              doc.sharedWithName.toLowerCase().contains(searchQuery) ||
              doc.shareMethod.toLowerCase().contains(searchQuery);
        }),
      );

    expanded = List.generate(documents.length, (_) => false);
    notifyListeners();
  }

}


class SharedDocModel {
  final String id;
  final String documentName;
  final String documentType;
  final String documentSource;
  final String shareToken;
  final String shareUrl;
  final String shareMethod;
  final String protectionType;
  final String? pin;
  final bool canDownload;
  final DateTime expiresAt;
  final String sharedWithName;
  final int accessCount;
  final DateTime? lastAccessedAt;
  final bool isRevoked;
  final bool isExpired;
  final DateTime createdAt;

  SharedDocModel({
    required this.id,
    required this.documentName,
    required this.documentType,
    required this.documentSource,
    required this.shareToken,
    required this.shareUrl,
    required this.shareMethod,
    required this.protectionType,
    this.pin,
    required this.canDownload,
    required this.expiresAt,
    required this.sharedWithName,
    required this.accessCount,
    this.lastAccessedAt,
    required this.isRevoked,
    required this.isExpired,
    required this.createdAt,
  });

  // ---------- FROM JSON ----------
  factory SharedDocModel.fromJson(Map<String, dynamic> json) {
    return SharedDocModel(
      id: json['id'] as String,
      documentName: json['documentName'] as String,
      documentType: json['documentType'] as String,
      documentSource: json['documentSource'] as String,
      shareToken: json['shareToken'] as String,
      shareUrl: json['shareUrl'] as String,
      shareMethod: json['shareMethod'] as String,
      protectionType: json['protectionType'] as String,

      // 🔥 pin can be int / string / null
      pin: json['pin']?.toString(),

      canDownload: json['canDownload'] as bool,

      // 🔥 Convert UTC → local for UI safety
      expiresAt: DateTime.parse(json['expiresAt']).toLocal(),

      sharedWithName: json['sharedWithName'] as String,

      accessCount: json['accessCount'] as int,

      // 🔥 nullable date
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt']).toLocal()
          : null,

      isRevoked: json['isRevoked'] as bool,
      isExpired: json['isExpired'] as bool,

      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }

  // ---------- TO JSON (optional) ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentName': documentName,
      'documentType': documentType,
      'documentSource': documentSource,
      'shareToken': shareToken,
      'shareUrl': shareUrl,
      'shareMethod': shareMethod,
      'protectionType': protectionType,
      'pin': pin,
      'canDownload': canDownload,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'sharedWithName': sharedWithName,
      'accessCount': accessCount,
      'lastAccessedAt': lastAccessedAt?.toUtc().toIso8601String(),
      'isRevoked': isRevoked,
      'isExpired': isExpired,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
