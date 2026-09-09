import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../Core/Config/app_config.dart';

/// Structured location model returned after detecting user coordinates
class DetectedLocation {
  final double latitude;
  final double longitude;
  final String district;       // জেলা (যেমন: ঢাকা, রাজশাহী, রংপুর)
  final String upazila;        // উপজেলা / থানা (যেমন: গুলশান, গোদাগাড়ী)
  final String unionOrArea;     // ইউনিয়ন / এলাকা (যেমন: মহাখালী, সদর)
  final String fullAddress;     // সম্পূর্ণ বিস্তারিত ঠিকানা

  DetectedLocation({
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.upazila,
    required this.unionOrArea,
    required this.fullAddress,
  });

  @override
  String toString() {
    return 'DetectedLocation(district: $district, upazila: $upazila, unionOrArea: $unionOrArea, address: $fullAddress)';
  }
}

class LocationService {
  /// Fetch user current GPS location and automatically reverse-geocode to
  /// District, Upazila, Union/Area, and Full Address in one click!
  static Future<DetectedLocation> getCurrentLocation() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'ফোনের লোকেশন/GPS সার্ভিস বন্ধ রয়েছে। অনুগ্রহ করে সেটিংস থেকে GPS চালু করুন।';
    }

    // 2. Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'লোকেশন পারমিশন দেওয়া হয়নি। অনুগ্রহ করে লোকেশন ব্যবহারের অনুমতি দিন।';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'লোকেশন পারমিশন স্থায়ীভাবে বন্ধ রয়েছে। অনুগ্রহ করে ফোন সেটিংস থেকে KrishiBazar অ্যাপের লোকেশন পারমিশন অন করুন।';
    }

    // 3. Fetch exact GPS coordinates
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    debugPrint('📍 [GPS DETECTED]: Lat ${position.latitude}, Lng ${position.longitude}');

    // 4. Try Google Maps Geocoding API if key is present
    if (AppConfig.hasGoogleMapsKey) {
      try {
        final googleResult = await _reverseGeocodeGoogle(position.latitude, position.longitude);
        if (googleResult != null) {
          return googleResult;
        }
      } catch (e) {
        debugPrint('⚠️ [GOOGLE MAPS GEOCODE ERROR]: $e. Falling back to native geocoder.');
      }
    }

    // 5. Native Geocoder Fallback
    try {
      final nativeResult = await _reverseGeocodeNative(position.latitude, position.longitude);
      return nativeResult;
    } catch (e) {
      debugPrint('⚠️ [NATIVE GEOCODE ERROR]: $e');
      // Return coordinates even if reverse geocoding names failed
      return DetectedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        district: '',
        upazila: '',
        unionOrArea: '',
        fullAddress: 'অক্ষাংশ: ${position.latitude.toStringAsFixed(5)}, দ্রাঘিমাংশ: ${position.longitude.toStringAsFixed(5)}',
      );
    }
  }

  /// Reverse geocode using Google Maps Geocoding REST API
  static Future<DetectedLocation?> _reverseGeocodeGoogle(double lat, double lng) async {
    final apiKey = AppConfig.googleMapsApiKey.trim();
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey&language=bn',
    );

    final res = await http.get(url).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data['status'] != 'OK' || data['results'] == null || (data['results'] as List).isEmpty) {
      return null;
    }

    final firstResult = data['results'][0];
    final String formattedAddress = firstResult['formatted_address'] ?? '';
    final List components = firstResult['address_components'] ?? [];

    String district = '';
    String upazila = '';
    String unionOrArea = '';

    for (var comp in components) {
      final List types = comp['types'] ?? [];
      final String longName = comp['long_name'] ?? '';

      if (types.contains('administrative_area_level_2')) {
        district = longName;
      } else if (types.contains('locality') || types.contains('sublocality_level_1')) {
        if (upazila.isEmpty) upazila = longName;
      } else if (types.contains('sublocality') || types.contains('neighborhood') || types.contains('sublocality_level_2')) {
        if (unionOrArea.isEmpty) unionOrArea = longName;
      } else if (types.contains('administrative_area_level_1') && district.isEmpty) {
        district = longName;
      }
    }

    return DetectedLocation(
      latitude: lat,
      longitude: lng,
      district: _cleanDistrict(district),
      upazila: upazila,
      unionOrArea: unionOrArea,
      fullAddress: formattedAddress,
    );
  }

  /// Reverse geocode using native device Geocoding plugin
  static Future<DetectedLocation> _reverseGeocodeNative(double lat, double lng) async {
    final geocoding = Geocoding();
    final List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) {
      return DetectedLocation(
        latitude: lat,
        longitude: lng,
        district: '',
        upazila: '',
        unionOrArea: '',
        fullAddress: 'Lat: $lat, Lng: $lng',
      );
    }

    final place = placemarks.first;

    // Extract district
    String district = place.subAdministrativeArea?.trim() ?? '';
    if (district.isEmpty) {
      district = place.administrativeArea?.trim() ?? '';
    }

    // Extract upazila / thana / city
    String upazila = place.locality?.trim() ?? '';
    if (upazila.isEmpty) {
      upazila = place.subAdministrativeArea?.trim() ?? '';
    }

    // Extract union / sub-locality / area
    String unionOrArea = place.subLocality?.trim() ?? '';
    if (unionOrArea.isEmpty) {
      unionOrArea = place.thoroughfare?.trim() ?? '';
    }

    // Build human readable full address
    final parts = <String>[];
    if ((place.street ?? '').isNotEmpty) parts.add(place.street!);
    if ((place.subLocality ?? '').isNotEmpty && !parts.contains(place.subLocality)) parts.add(place.subLocality!);
    if ((place.locality ?? '').isNotEmpty && !parts.contains(place.locality)) parts.add(place.locality!);
    if (district.isNotEmpty && !parts.contains(district)) parts.add(district);

    final fullAddress = parts.isNotEmpty ? parts.join(', ') : '${place.name ?? ''}, $district';

    return DetectedLocation(
      latitude: lat,
      longitude: lng,
      district: _cleanDistrict(district),
      upazila: upazila,
      unionOrArea: unionOrArea,
      fullAddress: fullAddress,
    );
  }

  static String _cleanDistrict(String raw) {
    // Clean words like 'District' or 'বিভাগ' if appended
    return raw
        .replaceAll('District', '')
        .replaceAll('জেলা', '')
        .replaceAll('Division', '')
        .replaceAll('বিভাগ', '')
        .trim();
  }
}
