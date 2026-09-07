import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';
  static const String keyNidFront = 'nid_front';
  static const String keyNidBack = 'nid_back';
  static const String keyTradeLicense = 'trade_license';
  static const String keyShopName = 'shop_name';
  static const String keyBusinessLicenseNo = 'business_license_no';
  static const String keyShopLocation = 'shop_location';

  static Future<void> saveUserSession({
    required bool isLoggedIn,
    required String role,
    required String name,
    required String email,
    required String phone,
    String? nidFront,
    String? nidBack,
    String? tradeLicense,
    String? shopName,
    String? businessLicenseNo,
    String? shopLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, isLoggedIn);
    await prefs.setString(keyUserRole, role);
    await prefs.setString(keyUserName, name);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyUserPhone, phone);

    if (nidFront != null) await prefs.setString(keyNidFront, nidFront);
    if (nidBack != null) await prefs.setString(keyNidBack, nidBack);
    if (tradeLicense != null) await prefs.setString(keyTradeLicense, tradeLicense);
    if (shopName != null) await prefs.setString(keyShopName, shopName);
    if (businessLicenseNo != null) await prefs.setString(keyBusinessLicenseNo, businessLicenseNo);
    if (shopLocation != null) await prefs.setString(keyShopLocation, shopLocation);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserRole) ?? 'farmer';
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? '';
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail) ?? '';
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
