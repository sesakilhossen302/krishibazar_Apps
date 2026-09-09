import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../Core/Config/app_config.dart';

/// Structured location search result model
class LocationSearchResult {
  final String title;
  final String district;       // জেলা
  final String upazila;        // উপজেলা / থানা
  final String unionOrArea;     // ইউনিয়ন / এলাকা
  final String fullAddress;     // সম্পূর্ণ বিস্তারিত ঠিকানা
  final double? latitude;
  final double? longitude;

  LocationSearchResult({
    required this.title,
    required this.district,
    required this.upazila,
    required this.unionOrArea,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });
}

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
  /// Live search locations across Bangladesh using input query
  static Future<List<LocationSearchResult>> searchLocations(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    // 1. Try Google Geocoding if key is present
    if (AppConfig.hasGoogleMapsKey) {
      try {
        final googleResults = await _searchGoogle(q);
        if (googleResults.isNotEmpty) return googleResults;
      } catch (e) {
        debugPrint('⚠️ [GOOGLE SEARCH ERROR]: $e');
      }
    }

    // 2. OpenStreetMap / Nominatim search with Bangladesh filter and Bengali language
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&addressdetails=1&countrycodes=bd&limit=5&accept-language=bn',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'KrishiBazarApp/1.0 (krishibazar@bangladesh.app)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<LocationSearchResult> results = [];

        for (var item in data) {
          final addr = (item['address'] as Map<String, dynamic>?) ?? {};

          // Extract district
          String district = addr['state_district'] ?? addr['state'] ?? '';
          district = _cleanDistrict(district);

          // Extract upazila / city / town / county
          String upazila = addr['town'] ?? addr['suburb'] ?? addr['city'] ?? addr['county'] ?? addr['municipality'] ?? '';
          upazila = _cleanDistrict(upazila);

          // Extract union / village / area
          String unionOrArea = addr['village'] ?? addr['neighbourhood'] ?? addr['quarter'] ?? addr['residential'] ?? '';
          if (unionOrArea == upazila) unionOrArea = '';

          final String title = item['name']?.toString() ?? q;
          final String fullAddress = item['display_name']?.toString() ?? '';

          double? lat;
          double? lng;
          if (item['lat'] != null) lat = double.tryParse(item['lat'].toString());
          if (item['lon'] != null) lng = double.tryParse(item['lon'].toString());

          results.add(LocationSearchResult(
            title: title,
            district: district,
            upazila: upazila,
            unionOrArea: unionOrArea,
            fullAddress: fullAddress,
            latitude: lat,
            longitude: lng,
          ));
        }
        return results;
      }
    } catch (e) {
      debugPrint('⚠️ [NOMINATIM SEARCH ERROR]: $e');
    }

    return [];
  }

  /// Search locations using Google Geocoding REST API
  static Future<List<LocationSearchResult>> _searchGoogle(String query) async {
    final apiKey = AppConfig.googleMapsApiKey.trim();
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&components=country:bd&language=bn&key=$apiKey',
    );

    final res = await http.get(url).timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    if (data['status'] != 'OK' || data['results'] == null) {
      return [];
    }

    final List resultsList = data['results'];
    final List<LocationSearchResult> list = [];

    for (var firstResult in resultsList) {
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

      final geometry = firstResult['geometry']?['location'];
      double? lat = geometry?['lat']?.toDouble();
      double? lng = geometry?['lng']?.toDouble();

      list.add(LocationSearchResult(
        title: query,
        district: _cleanDistrict(district),
        upazila: upazila,
        unionOrArea: unionOrArea,
        fullAddress: formattedAddress,
        latitude: lat,
        longitude: lng,
      ));
    }

    return list;
  }

  /// Fetch user current GPS location safely without crashing on MissingPluginException
  static Future<DetectedLocation> getCurrentLocation() async {
    try {
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
        throw 'লোকেশন পারমিশন বন্ধ রয়েছে। নিচের সার্চ বক্সে এলাকা লিখে সহজে লোকেশন সিলেক্ট করুন।';
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
        return DetectedLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          district: '',
          upazila: '',
          unionOrArea: '',
          fullAddress: 'অক্ষাংশ: ${position.latitude.toStringAsFixed(5)}, দ্রাঘিমাংশ: ${position.longitude.toStringAsFixed(5)}',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [GPS EXCEPTION]: $e');
      if (e.toString().contains('MissingPluginException')) {
        throw 'জিপিএস সেবা চালু হয়নি। অনুগ্রহ করে নিচের সার্চ বক্সে আপনার এলাকা লিখে সরাসরি সিলেক্ট করুন।';
      }
      rethrow;
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
