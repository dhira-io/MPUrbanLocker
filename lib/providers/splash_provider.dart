// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class SplashProvider with ChangeNotifier {
  bool _isReady = false;
  bool _isLoggedIn = false;
  bool _isNewUser = false;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get isNewUser => _isNewUser;


  Future<void> getAppStoreStatus() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();

      // Fetch store config (expecting single document)
      final snapshot = await firestore.collection('store').limit(1).get();

      if (snapshot.docs.isEmpty) {
        prefs.setBool("in_store_review", false);
        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      debugPrint("in_store_review data : $data");

      final String androidVersion = data['android_version'] ?? '';
      final String iosVersion = data['ios_version'] ?? '';
      final bool inAndroidReview = data['in_android_review'] ?? false;
      final bool inIosReview = data['in_apple_review'] ?? false;

      final String appVersion = packageInfo.version;
      print("current app version ${appVersion}");
      bool isInStoreReview = false;

      if (Platform.isAndroid) {
        isInStoreReview =
            inAndroidReview && androidVersion == appVersion;
      } else if (Platform.isIOS) {
        isInStoreReview =
            inIosReview && iosVersion == appVersion;
      }
      debugPrint("in_store_review : $isInStoreReview");

      await prefs.setBool("in_store_review", isInStoreReview);
    } catch (e) {
      debugPrint("getAppStoreStatus error: $e");
    }
  }

  Future<void> startSplash() async {
    // 1. Splash delay
    await Future.delayed(Duration(seconds: 5));

    // 2. Check statuses

    await _checkLoginStatus(); // Check login status regardless of NewUser status
    await getAppStoreStatus();
    // 3. Mark as ready
    _isReady = true;
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    final pref = await SharedPreferences.getInstance();
    final token = await pref.getString(AppConstants.tokenKey);
    print("here is token ${token}");
    // Check for an 'authToken' to determine login state
    _isLoggedIn = token != null && token.isNotEmpty;
    print("here is token ${_isLoggedIn}");

  }




}