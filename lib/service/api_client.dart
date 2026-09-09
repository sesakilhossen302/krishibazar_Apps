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
          "filename": data["filename"] ?? "",
          "data": data,
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

  /// Fetch User Profile Data from Backend
  static Future<Map<String, dynamic>> fetchUserProfile({
    String? token,
    String? userId,
    String? phone,
    String? email,
  }) async {
    Uri uri;
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    if (token != null && token.trim().isNotEmpty) {
      uri = Uri.parse(ApiUrl.profile);
      headers["Authorization"] = "Bearer ${token.trim()}";
    } else if (userId != null && userId.trim().isNotEmpty) {
      uri = Uri.parse("${ApiUrl.profile}/${userId.trim()}");
    } else if ((phone != null && phone.trim().isNotEmpty) || (email != null && email.trim().isNotEmpty)) {
      final queryParams = <String, String>{};
      if (phone != null && phone.trim().isNotEmpty) queryParams['phone'] = phone.trim();
      if (email != null && email.trim().isNotEmpty) queryParams['email'] = email.trim().toLowerCase();
      uri = Uri.parse(ApiUrl.userByIdentifier).replace(queryParameters: queryParams);
    } else {
      return {
        "success": false,
        "message": "প্রোফাইল শনাক্তকরণের কোনো তথ্য দেওয়া হয়নি।"
      };
    }

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] GET User Profile: $uri');

    try {
      final response = await http.get(uri, headers: headers);

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) {}

      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        final msg = _extractErrorMessage(data, "প্রোফাইল তথ্য পেতে সমস্যা হয়েছে।");
        return {
          "success": false,
          "message": msg,
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [API ERROR - FETCH USER PROFILE]: $e');
      debugPrint('📜 [STACK TRACE]: $stackTrace');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। দয়া করে ইন্টারনেট সংযোগ চেক করুন।"
      };
    }
  }

  /// Update User Profile Data via PATCH /users/profile or /users/profile/{userId}
  static Future<Map<String, dynamic>> updateUserProfile({
    String? token,
    String? userId,
    required Map<String, dynamic> updateData,
  }) async {
    Uri uri = Uri.parse(ApiUrl.profile);
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    } else if (userId != null && userId.trim().isNotEmpty) {
      uri = Uri.parse("${ApiUrl.profile}/${userId.trim()}");
    }

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] PATCH User Profile: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(updateData)}');

    try {
      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode(updateData),
      );

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) {}

      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return {
          "success": true,
          "data": data,
          "message": "প্রোফাইল তথ্য সফলভাবে আপডেট করা হয়েছে!",
        };
      } else {
        final msg = _extractErrorMessage(data, "প্রোফাইল আপডেট করতে ব্যর্থ হয়েছে।");
        return {
          "success": false,
          "message": msg,
        };
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [API ERROR - UPDATE PROFILE]: $e');
      debugPrint('📜 [STACK TRACE]: $stackTrace');
      debugPrint('==================================================');
      return {
        "success": false,
        "message": "সার্ভারে সংযোগ দেওয়া যায়নি। ইন্টারনেট সংযোগ চেক করুন।"
      };
    }
  }

  /// Re-upload NID documents when rejected by admin
  static Future<Map<String, dynamic>> reuploadNid({
    String? token,
    String? userId,
    required String nidFrontUrl,
    required String nidBackUrl,
    String? nidNumber,
  }) async {
    final queryStr = (userId != null && userId.trim().isNotEmpty) ? "?user_id=${userId.trim()}" : "";
    final uri = Uri.parse("${ApiUrl.users}/reupload-nid$queryStr");
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }

    final body = {
      if (userId != null && userId.trim().isNotEmpty) "user_id": userId.trim(),
      "nid_front_url": nidFrontUrl,
      "nid_back_url": nidBackUrl,
      if (nidNumber != null && nidNumber.trim().isNotEmpty) "nid_or_doc": nidNumber.trim(),
    };

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] POST Re-upload NID: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      dynamic data;
      try { data = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) {}

      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return {
          "success": true,
          "data": data,
          "message": "এনআইডি কার্ড সফলভাবে আপলোড করা হয়েছে!",
        };
      } else {
        final msg = _extractErrorMessage(data, "এনআইডি কার্ড আপলোড করতে সমস্যা হয়েছে।");
        return {
          "success": false,
          "message": msg,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
      };
    }
  }

  /// Fetch user notifications from backend
  static Future<Map<String, dynamic>> fetchNotifications({
    String? token,
    String? userId,
  }) async {
    Uri uri = Uri.parse(ApiUrl.notifications);
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }
    if (userId != null && userId.trim().isNotEmpty) {
      uri = uri.replace(queryParameters: {"user_id": userId.trim()});
    }

    try {
      final response = await http.get(uri, headers: headers);
      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        final msg = _extractErrorMessage(data, "বিজ্ঞপ্তি পেতে সমস্যা হয়েছে।");
        return {
          "success": false,
          "message": msg,
          "data": [],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "বিজ্ঞপ্তি লোড করা যায়নি: $e",
        "data": [],
      };
    }
  }

  /// Mark single notification as read
  static Future<bool> markNotificationRead(String notificationId, {String? token}) async {
    final uri = Uri.parse("${ApiUrl.notifications}$notificationId/read");
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }

    try {
      final response = await http.patch(uri, headers: headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllNotificationsRead({String? token, String? userId}) async {
    Uri uri = Uri.parse(ApiUrl.markAllNotificationsRead);
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }
    if (userId != null && userId.trim().isNotEmpty) {
      uri = uri.replace(queryParameters: {"user_id": userId.trim()});
    }

    try {
      final response = await http.patch(uri, headers: headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Delete notification
  static Future<bool> deleteNotification(String notificationId, {String? token}) async {
    final uri = Uri.parse("${ApiUrl.notifications}$notificationId");
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }

    try {
      final response = await http.delete(uri, headers: headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Upload multiple image files to backend /upload/images
  static Future<Map<String, dynamic>> uploadMultipleImages(List<File> imageFiles) async {
    if (imageFiles.isEmpty) {
      return {"success": true, "urls": <String>[]};
    }

    final uri = Uri.parse(ApiUrl.uploadImages);
    debugPrint('🚀 [API REQ] POST Upload Multiple Images: $uri (${imageFiles.length} files)');

    try {
      final request = http.MultipartRequest("POST", uri);
      for (var file in imageFiles) {
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath('files', file.path));
        }
      }

      if (request.files.isEmpty) {
        return {"success": true, "urls": <String>[]};
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<String> urls = (data['urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
        return {
          "success": true,
          "urls": urls,
          "primary_url": data['primary_url'] ?? (urls.isNotEmpty ? urls.first : ""),
          "message": data['message'] ?? "",
        };
      } else {
        final msg = _extractErrorMessage(data, "ছবি আপলোড করতে ব্যর্থ হয়েছে।");
        return {"success": false, "message": msg, "urls": <String>[]};
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - UPLOAD MULTIPLE IMAGES]: $e');
      return {"success": false, "message": "ছবি আপলোড করার সময় নেটওয়ার্ক ত্রুটি ঘটেছে: $e", "urls": <String>[]};
    }
  }

  /// Upload video clip to backend /upload/video
  static Future<Map<String, dynamic>> uploadVideoFile(File videoFile) async {
    final uri = Uri.parse(ApiUrl.uploadVideo);
    debugPrint('🚀 [API REQ] POST Upload Video: $uri (${videoFile.path})');

    try {
      final request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "url": data['url'] ?? "",
          "full_url": data['full_url'] ?? "",
          "message": data['message'] ?? "ভিডিও সফলভাবে আপলোড হয়েছে",
        };
      } else {
        final msg = _extractErrorMessage(data, "ভিডিও আপলোড করতে ব্যর্থ হয়েছে।");
        return {"success": false, "message": msg};
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - UPLOAD VIDEO]: $e');
      return {"success": false, "message": "ভিডিও আপলোড করার সময় নেটওয়ার্ক ত্রুটি ঘটেছে: $e"};
    }
  }

  /// Create a new product on the backend
  static Future<Map<String, dynamic>> createProduct({
    String? token,
    String? farmerId,
    required String title,
    required String category,
    required double quantity,
    required String unit,
    required double expectedPrice,
    required double minPrice,
    required String location,
    required String availableDate,
    required String harvestDate,
    required String qualityGrade,
    String description = "",
    List<String> images = const [],
    String videoUrl = "",
    String videoNote = "",
  }) async {
    final uri = Uri.parse(ApiUrl.products);
    final Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8",
    };
    if (token != null && token.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer ${token.trim()}";
    }

    final body = {
      if (farmerId != null && farmerId.trim().isNotEmpty) "farmer_id": farmerId.trim(),
      "title": title.trim(),
      "category": category.trim(),
      "quantity": quantity,
      "unit": unit.trim(),
      "expected_price": expectedPrice,
      "min_price": minPrice,
      "location": location.trim(),
      "available_date": availableDate.trim(),
      "harvest_date": harvestDate.trim(),
      "quality_grade": qualityGrade.trim(),
      "description": description.trim(),
      "images": images,
      "image_url": images.isNotEmpty ? images.first : "",
      "video_url": videoUrl.trim(),
      "video_note": videoNote.trim(),
    };

    debugPrint('==================================================');
    debugPrint('🚀 [API REQ] POST Create Product: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');
      debugPrint('==================================================');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
          "message": "পণ্যটি সফলভাবে লিস্টিং করা হয়েছে!",
        };
      } else {
        final msg = _extractErrorMessage(data, "নতুন পণ্য যুক্ত করতে সমস্যা হয়েছে।");
        return {
          "success": false,
          "message": msg,
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - CREATE PRODUCT]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
      };
    }
  }

  /// Fetch all active products from backend with optional filters
  static Future<Map<String, dynamic>> fetchProducts({
    String? category,
    String? district,
    String? farmerId,
    String? search,
  }) async {
    Uri uri = Uri.parse(ApiUrl.products);
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'all') {
      queryParams['category'] = category;
    }
    if (district != null && district.isNotEmpty) {
      queryParams['district'] = district;
    }
    if (farmerId != null && farmerId.isNotEmpty) {
      queryParams['farmer_id'] = farmerId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    debugPrint('🚀 [API REQ] GET Products: $uri');

    try {
      final response = await http.get(uri);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "পণ্য তালিকা লোড করা যায়নি।"),
          "data": [],
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - FETCH PRODUCTS]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
        "data": [],
      };
    }
  }

  /// Fetch products posted by the currently authenticated farmer
  static Future<Map<String, dynamic>> fetchMyProducts({
    String? token,
    String? farmerId,
  }) async {
    Uri uri = Uri.parse("${ApiUrl.products}my-products");
    if (farmerId != null && farmerId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'farmer_id': farmerId});
    }

    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('🚀 [API REQ] GET My Products: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "কৃষকের পণ্য তালিকা লোড করা যায়নি।"),
          "data": [],
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - FETCH MY PRODUCTS]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
        "data": [],
      };
    }
  }

  // ================= DEMANDS (চাহিদা) =================

  /// Create a new buyer demand
  static Future<Map<String, dynamic>> createDemand(
    Map<String, dynamic> body, {
    String? token,
    String? userId,
  }) async {
    Uri uri = Uri.parse(ApiUrl.demands);
    if (userId != null && userId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'buyer_id': userId});
    }

    final headers = <String, String>{
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('🚀 [API REQ] POST Create Demand: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "চাহিদা সফলভাবে পোস্ট করা হয়েছে!",
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "চাহিদা পোস্ট করতে সমস্যা হয়েছে।"),
          "data": data,
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - CREATE DEMAND]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
      };
    }
  }

  /// Fetch demands posted by the currently logged-in buyer / shopkeeper
  static Future<Map<String, dynamic>> fetchMyDemands({
    String? token,
    String? buyerId,
  }) async {
    Uri uri = Uri.parse(ApiUrl.myDemands);
    if (buyerId != null && buyerId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'buyer_id': buyerId});
    }

    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('🚀 [API REQ] GET My Demands: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "আপনার চাহিদার তালিকা লোড করা যায়নি।"),
          "data": [],
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - FETCH MY DEMANDS]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
        "data": [],
      };
    }
  }

  /// Fetch public demands (with optional category, district, search filter)
  static Future<Map<String, dynamic>> fetchDemands({
    String? buyerId,
    String? category,
    String? district,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (buyerId != null && buyerId.isNotEmpty) queryParams['buyer_id'] = buyerId;
    if (category != null && category.isNotEmpty && category != 'সকল') queryParams['category'] = category;
    if (district != null && district.isNotEmpty) queryParams['district'] = district;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    Uri uri = Uri.parse(ApiUrl.demands);
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    debugPrint('🚀 [API REQ] GET Demands: $uri');

    try {
      final response = await http.get(uri);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "চাহিদার তালিকা লোড করা যায়নি।"),
          "data": [],
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - FETCH DEMANDS]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
        "data": [],
      };
    }
  }

  /// Delete a demand
  static Future<Map<String, dynamic>> deleteDemand(
    String demandId, {
    String? token,
    String? userId,
  }) async {
    Uri uri = Uri.parse("${ApiUrl.demands}$demandId");
    if (userId != null && userId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'user_id': userId});
    }

    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('🚀 [API REQ] DELETE Demand: $uri');

    try {
      final response = await http.delete(uri, headers: headers);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          "success": true,
          "message": "চাহিদা সফলভাবে মুছে ফেলা হয়েছে!",
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "চাহিদা মুছতে সমস্যা হয়েছে।"),
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - DELETE DEMAND]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
      };
    }
  }

  // ================= OFFERS (দরপত্র / অফার) =================

  /// Create / submit a new farmer offer
  static Future<Map<String, dynamic>> createOffer(
    Map<String, dynamic> body, {
    String? token,
    String? farmerId,
  }) async {
    Uri uri = Uri.parse(ApiUrl.offers);
    if (farmerId != null && farmerId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'farmer_id': farmerId});
    }

    final headers = <String, String>{
      "Content-Type": "application/json",
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('🚀 [API REQ] POST Create Offer: $uri');
    debugPrint('📦 [BODY]: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');
      debugPrint('📄 [API RES BODY]: ${response.body}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": "অফারটি সফলভাবে পাঠানো হয়েছে!",
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "অফার পাঠাতে সমস্যা হয়েছে।"),
          "data": data,
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - CREATE OFFER]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
      };
    }
  }

  /// Fetch offers submitted by the current farmer
  static Future<Map<String, dynamic>> fetchMyOffers({
    String? token,
    String? farmerId,
  }) async {
    Uri uri = Uri.parse(ApiUrl.myOffers);
    if (farmerId != null && farmerId.isNotEmpty) {
      uri = uri.replace(queryParameters: {'farmer_id': farmerId});
    }

    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('🚀 [API REQ] GET My Offers: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "আপনার অফারের তালিকা লোড করা যায়নি।"),
          "data": [],
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - FETCH MY OFFERS]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
        "data": [],
      };
    }
  }

  /// Fetch all offers for a specific demand
  static Future<Map<String, dynamic>> fetchOffersForDemand(String demandId) async {
    final uri = Uri.parse(ApiUrl.demandOffers(demandId));
    debugPrint('🚀 [API REQ] GET Offers For Demand: $uri');

    try {
      final response = await http.get(uri);
      debugPrint('📥 [API RES STATUS]: ${response.statusCode}');

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {}

      if (response.statusCode == 200 && data is List) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": _extractErrorMessage(data, "অফারের তালিকা লোড করা যায়নি।"),
          "data": [],
        };
      }
    } catch (e) {
      debugPrint('❌ [API ERROR - FETCH DEMAND OFFERS]: $e');
      return {
        "success": false,
        "message": "সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি: $e",
        "data": [],
      };
    }
  }
}



