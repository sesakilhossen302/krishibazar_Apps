import 'dart:io';

/// Global App Configurations
class AppConfig {
  static String _cachedApiKey = '';

  /// Compile-time define via:
  /// flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key
  /// or flutter run --dart-define-from-file=.env
  static const String _envDefineApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Google Maps Geocoding & Maps API Key.
  /// Loaded dynamically from environment or local .env file.
  /// If left empty, the app will automatically fall back to OpenStreetMap / Nominatim
  /// and the device native geocoder!
  static String get googleMapsApiKey {
    if (_cachedApiKey.isNotEmpty) return _cachedApiKey;
    if (_envDefineApiKey.isNotEmpty) {
      _cachedApiKey = _envDefineApiKey;
      return _cachedApiKey;
    }

    try {
      final envFile = File('.env');
      if (envFile.existsSync()) {
        final lines = envFile.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('#') || trimmed.isEmpty) continue;
          if (trimmed.startsWith('GOOGLE_MAPS_API_KEY=')) {
            final parts = trimmed.split('=');
            if (parts.length >= 2) {
              _cachedApiKey = parts
                  .sublist(1)
                  .join('=')
                  .trim()
                  .replaceAll('"', '')
                  .replaceAll("'", "");
              return _cachedApiKey;
            }
          }
        }
      }
    } catch (_) {}

    return '';
  }

  /// Whether Google Maps API is configured
  static bool get hasGoogleMapsKey => googleMapsApiKey.trim().isNotEmpty;
}
