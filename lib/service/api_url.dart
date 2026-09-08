import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiUrl {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000/api/v1";
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:8000/api/v1";
    return "http://127.0.0.1:8000/api/v1";
  }

  static String get uploadImage => "$baseUrl/upload/image";
  static String get sendOtp => "$baseUrl/auth/send-otp";
  static String get verifyOtp => "$baseUrl/auth/verify-otp";
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get me => "$baseUrl/auth/me";
  static String get profile => "$baseUrl/users/profile";
  static String get products => "$baseUrl/products/";
  static String get demands => "$baseUrl/demands/";
  static String get orders => "$baseUrl/orders/";
}
