import 'dart:convert';
import 'package:http/http.dart';
import 'package:get/get.dart' hide Response;

import '../../ui/login_reg_screens/controllers/auth_service.dart';

class networkResponse {
  final bool isSuccess;
  final int statusCode;
  final dynamic data;
  final String? errorMessage;

  networkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.errorMessage,
  });
}

class networkClient {
  // --- টোকেন সহ হেডার তৈরি ---
  static Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    try {
      if (Get.isRegistered<AuthService>()) {
        final AuthService authService = Get.find<AuthService>();
        if (authService.token.value.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${authService.token.value}';
        }
      }
    } catch (e) {
      print("Token Error: $e");
    }
    return headers;
  }

  static Future<networkResponse> getRequest({required String url}) async {
    try {
      Uri uri = Uri.parse(url);
      Response response = await get(uri, headers: _getHeaders()); // হেডার ব্যবহার

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return networkResponse(
          isSuccess: true,
          data: decodedJson,
          statusCode: response.statusCode,
        );
      } else {
        return networkResponse(
          isSuccess: false,
          errorMessage: "Something went wrong!",
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return networkResponse(isSuccess: false, errorMessage: e.toString(), statusCode: -1);
    }
  }

  static Future<networkResponse> postRequest({
    required String url,
    required Map<String, dynamic>? body,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      Response response = await post(
        uri,
        headers: _getHeaders(), // হেডার ব্যবহার
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return networkResponse(
          isSuccess: true,
          data: decodedJson,
          statusCode: response.statusCode,
        );
      } else {
        // এরর হ্যান্ডলিং
        String msg = "Request Failed";
        try {
          final decoded = jsonDecode(response.body);
          if(decoded['message'] != null) msg = decoded['message'];
        } catch(_) {}
        return networkResponse(isSuccess: false, errorMessage: msg, statusCode: response.statusCode);
      }
    } catch (e) {
      return networkResponse(isSuccess: false, errorMessage: e.toString(), statusCode: -1);
    }
  }
}