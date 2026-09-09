import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiUrl {
  /// পাবলিক টানেল লিংক: ক্লায়েন্ট বা অন্য ফোনে টেস্ট APK দেওয়ার জন্য
  /// পিসিতে সার্ভার চালু থাকা অবস্থায় যেকোনো ফোন থেকে কাজ করবে
  static const String publicServerUrl = "https://configured-hits-tsunami-bikini.trycloudflare.com";

  /// true থাকলে ক্লায়েন্টের ফোন/অন্য যেকোনো ফোনে APK কাজ করবে
  static const bool usePublicServer = true;

  static String get serverBaseUrl {
    if (usePublicServer && publicServerUrl.isNotEmpty) {
      return publicServerUrl;
    }
    if (kIsWeb) return "http://127.0.0.1:8000";
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  static String get baseUrl => "$serverBaseUrl/api/v1";

  static String get uploadImage => "$baseUrl/upload/image";
  static String get sendOtp => "$baseUrl/auth/send-otp";
  static String get verifyOtp => "$baseUrl/auth/verify-otp";
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get me => "$baseUrl/auth/me";
  static String get profile => "$baseUrl/users/profile";
  static String get userByIdentifier => "$baseUrl/users/by-identifier";
  static String get products => "$baseUrl/products/";
  static String get demands => "$baseUrl/demands/";
  static String get orders => "$baseUrl/orders/";

  /// Helper to convert backend image URLs or paths to valid network image URLs
  static String formatMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return "";
    String formatted = url.trim();
    if (formatted.startsWith("/")) {
      return "$serverBaseUrl$formatted";
    }
    if (!formatted.startsWith("http://") && !formatted.startsWith("https://")) {
      return "$serverBaseUrl/$formatted";
    }
    if (!kIsWeb && Platform.isAndroid && formatted.contains("127.0.0.1:8000")) {
      formatted = formatted.replaceAll("127.0.0.1:8000", "10.0.2.2:8000");
    }
    return formatted;
  }
}
