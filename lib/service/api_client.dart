import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_url.dart';

class ApiClient {
  /// Upload image file (from Camera or Gallery) to FastAPI Backend
  static Future<Map<String, dynamic>> uploadImageFile(File imageFile) async {
    final uri = Uri.parse(ApiUrl.uploadImage);
    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] POST Upload Image: $uri');
    debugPrint('📁 [FILE PATH]: ${imageFile.path}');

    try {
      final request = http.MultipartRequest("POST", uri);
      final multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "url": data["url"] ?? "",
          "full_url": data["full_url"] ?? "",
          "filename": data["filename"] ?? ""
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["detail"] ?? "ইমেজ আপলোড করতে সমস্যা হয়েছে।"
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR]: $e');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "নেটওয়ার্ক কানেকশন এরর: ${e.toString()}"
      };
    }
  }

  /// Send OTP to user's Gmail
  static Future<Map<String, dynamic>> sendOtp({
    required String email,
    required String name,
    String purpose = "signup",
    String phone = "",
  }) async {
    final uri = Uri.parse(ApiUrl.sendOtp);
    final body = {
      "email": email,
      "name": name,
      "purpose": purpose,
      "phone": phone
    };

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] POST Send OTP: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "ওটিপি ইমেইলে পাঠানো হয়েছে।",
          "otp_code": data["otp_code"]
        };
      } else {
        return {
          "success": false,
          "message": data["detail"] ?? "ওটিপি পাঠাতে ব্যর্থ হয়েছে।"
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR]: $e');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারে কানেক্ট করা যাচ্ছে না: ${e.toString()}"
      };
    }
  }

  /// Perform User Signup with OTP verification
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> body) async {
    final uri = Uri.parse(ApiUrl.signup);

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] POST Signup: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
          "access_token": data["access_token"],
          "user_id": data["user_id"],
          "role": data["role"]
        };
      } else {
        return {
          "success": false,
          "message": data["detail"] ?? "সাইনআপ করতে ব্যর্থ হয়েছে।"
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR]: $e');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারে কানেক্ট করা যাচ্ছে না: ${e.toString()}"
      };
    }
  }

  /// Perform User Login
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse(ApiUrl.login);
    final body = {
      "identifier": identifier,
      "password": password
    };

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] POST Login: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
          "access_token": data["access_token"],
          "user_id": data["user_id"],
          "role": data["role"],
          "name": data["name"]
        };
      } else {
        return {
          "success": false,
          "message": data["detail"] ?? "লগইন করতে ব্যর্থ হয়েছে।"
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR]: $e');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারে কানেক্ট করা যাচ্ছে না: ${e.toString()}"
      };
    }
  }
}
