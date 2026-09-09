import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_url.dart';

class ApiClient {
  /// Extract clean message from FastAPI response body or error
  static String _extractErrorMessage(dynamic data, String defaultMsg) {
    if (data is Map) {
      if (data["detail"] != null) {
        if (data["detail"] is String) {
          return data["detail"];
        } else if (data["detail"] is List) {
          final list = data["detail"] as List;
          if (list.isNotEmpty && list[0] is Map && list[0]["msg"] != null) {
            return list[0]["msg"].toString();
          }
          return list.join(", ");
        }
      }
      if (data["message"] != null) {
        return data["message"].toString();
      }
    }
    return defaultMsg;
  }

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
        dynamic data;
        try { data = jsonDecode(response.body); } catch (_) {}
        final msg = _extractErrorMessage(data, "ইমেজ আপলোড করতে সমস্যা হয়েছে।");
        return {
          "success": false,
          "message": msg
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [API ERROR - UPLOAD IMAGE]: $e');
      debugPrint('📜 [STACK TRACE]: $stackTrace');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। দয়া করে আপনার ইন্টারনেট এবং ব্যাকএন্ড সার্ভিস চেক করুন।"
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

      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) {}

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": (data is Map && data["message"] != null)
              ? data["message"]
              : "আপনার জিমেইলে ওটিপি কোড পাঠানো হয়েছে।",
          "otp_code": (data is Map) ? data["otp_code"] : null
        };
      } else {
        final msg = _extractErrorMessage(data, "ওটিপি পাঠাতে ব্যর্থ হয়েছে।");
        return {
          "success": false,
          "message": msg
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [API ERROR - SEND OTP]: $e');
      debugPrint('📜 [STACK TRACE]: $stackTrace');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। দয়া করে আপনার ইন্টারনেট এবং ব্যাকএন্ড সার্ভিস চেক করুন।"
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

      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) {}

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
          "access_token": (data is Map) ? data["access_token"] : null,
          "user_id": (data is Map) ? data["user_id"] : null,
          "role": (data is Map) ? data["role"] : null
        };
      } else {
        final msg = _extractErrorMessage(data, "সাইনআপ করতে ব্যর্থ হয়েছে।");
        return {
          "success": false,
          "message": msg
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [API ERROR - SIGNUP]: $e');
      debugPrint('📜 [STACK TRACE]: $stackTrace');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। দয়া করে আপনার ইন্টারনেট এবং ব্যাকএন্ড সার্ভিস চেক করুন।"
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

      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) {}

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
          "access_token": (data is Map) ? data["access_token"] : null,
          "user_id": (data is Map) ? data["user_id"] : null,
          "role": (data is Map) ? data["role"] : null,
          "name": (data is Map) ? data["name"] : null
        };
      } else {
        final msg = _extractErrorMessage(data, "লগইন করতে ব্যর্থ হয়েছে।");
        return {
          "success": false,
          "message": msg
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [API ERROR - LOGIN]: $e');
      debugPrint('📜 [STACK TRACE]: $stackTrace');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। দয়া করে আপনার ইন্টারনেট এবং ব্যাকএন্ড সার্ভিস চেক করুন।"
      };
    }
  }
}
