/// Global App Configurations
class AppConfig {
  /// Google Maps Geocoding & Maps API Key.
  /// Replace this string with your Google Maps API Key:
  /// (e.g., from Google Cloud Console: Maps JavaScript / Geocoding API).
  /// If left empty, the app will automatically fall back to the device's
  /// native geocoder to find District, Upazila, and Address!
  static const String googleMapsApiKey =
      "AIzaSyDNi9vMrTXlv9ui_jqnqdWXLT7ifVAFmCg";

  /// Whether Google Maps API is configured
  static bool get hasGoogleMapsKey => googleMapsApiKey.trim().isNotEmpty;
}
