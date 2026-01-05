//
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import '../utils/constants.dart';
//
//
// class ApiManager {
//   ApiManager._();
//   static final ApiManager instance = ApiManager._();
//
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//
// /* =======================
//    * TOKEN
//    * ======================= */
//   Future<String?> get _token async {
//     return _secureStorage.read(key: AppConstants.tokenKey);
//   }
//
//   /* =======================
//    * HEADERS
//    * ======================= */
//   Future<Map<String, String>> _getHeaders({
//     bool includeAuth = true,
//   }) async {
//     final headers = <String, String>{
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//
//     if (includeAuth) {
//       final authToken = await _token;
//       if (authToken != null && authToken.isNotEmpty) {
//         headers['Authorization'] = 'Bearer $authToken';
//       }
//     }
//
//     return headers;
//   }
//
//   /* =======================
//    * GET API CALL
//    * ======================= */
//   Future<ApiResponse> get(
//       String endpoint,
//
//       ) async {
//     final Uri url = Uri.parse(endpoint);
//
//     try {
//       final response = await http.get(url,
//           headers: await _getHeaders(includeAuth: true),);
//
//       return _handleResponse(response);
//     } catch (e) {
//       return ApiResponse(
//         'Exception: ${e.toString()}',
//         statusCode: 0,
//         data: {},
//       );
//     }
//   }
//
//   Future<ApiResponse> post(
//       String endpoint,
//       Map<String, dynamic> requestBody,
//       ) async {
//     final Uri url = Uri.parse(endpoint);
//
//     try {
//       final response = await http.post(
//         url,
//         headers: await _getHeaders(includeAuth: true),
//         body: jsonEncode(requestBody),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       return ApiResponse(
//         'Exception: ${e.toString()}',
//         statusCode: 0,
//         data: {},
//       );
//     }
//   }
//
//   /* =======================
//    * RESPONSE HANDLER
//    * ======================= */
//   ApiResponse _handleResponse(http.Response response) {
//     final Map<String, dynamic> body =
//     jsonDecode(response.body) as Map<String, dynamic>;
//
//     // Success
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return ApiResponse(
//         'success',
//         statusCode: response.statusCode,
//         data: body,
//       );
//     }
//
//     // Unauthorized
//     if (response.statusCode == 401) {
//       throw ApiResponse(
//         body['error'] ?? 'Unauthorized',
//         statusCode: 401,
//         data: body,
//       );
//     }
//
//     // Other errors
//     throw ApiResponse(
//       body['error'] ?? body['message'] ?? 'Request failed',
//       statusCode: response.statusCode,
//       data: body,
//     );
//   }
// }
//
// /* =======================
//  * API RESPONSE MODEL
//  * ======================= */
// class ApiResponse implements Exception {
//   final String message;
//   final int? statusCode;
//   final dynamic data;
//
//   ApiResponse(
//       this.message, {
//         this.statusCode,
//         this.data,
//       });
//
//   @override
//   String toString() {
//     return 'ApiException: $message (status: $statusCode)';
//   }
// }
