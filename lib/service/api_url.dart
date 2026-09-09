import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiUrl {
  /// ক্লায়েন্ট বা অন্য ফোনে টেস্ট APK বিল্ড করার জন্য পাবলিক টানেল লিংক
  static const String publicServerUrl = "https://configured-hits-tsunami-bikini.trycloudflare.com";

  /// লোকাল সার্ভার লিংক (আপনার নিজের পিসিতে কাজ করার জন্য)
  static const String localServerUrl = "http://127.0.0.1:8000";
  static const String emulatorServerUrl = "http://10.0.2.2:8000";

  /// মোড সিলেক্টর:
  /// null = স্মার্ট অটোমেটিক (পিসিতে ডেভেলপমেন্টের সময় লোকাল সার্ভার, আর APK বিল্ডের সময় পাবলিক সার্ভার)
  /// true = সবসময় পাবলিক সার্ভার
  /// false = সবসময় লোকাল সার্ভার
  static const bool? forcePublicServer = null;

  static bool get isUsingPublicServer {
    if (forcePublicServer != null) return forcePublicServer!;
    // আপনি যখন APK বিল্ড করে অন্যকে দিবেন (Release mode), তখন অটো পাবলিক সার্ভার কাজ করবে
    // আর পিসিতে কোডিং/টেস্ট করার সময় (Debug mode) লোকাল 127.0.0.1 / 10.0.2.2 কাজ করবে
    return kReleaseMode;
  }

  static String get serverBaseUrl {
    if (isUsingPublicServer && publicServerUrl.isNotEmpty) {
      return publicServerUrl;
    }
    if (kIsWeb) return localServerUrl;
    if (!kIsWeb && Platform.isAndroid) return emulatorServerUrl;
    return localServerUrl;
  }

  static String get baseUrl => "$serverBaseUrl/api/v1";

  static String get uploadImage => "$baseUrl/upload/image";
  static String get sendOtp => "$baseUrl/auth/send-otp";
  static String get verifyOtp => "$baseUrl/auth/verify-otp";
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get me => "$baseUrl/auth/me";
  static String get users => "$baseUrl/users";
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
