import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyToken = 'access_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';
  static const String keyDistrict = 'user_district';
  static const String keyUpazila = 'user_upazila';
  static const String keyUnion = 'user_union';
  static const String keyAddress = 'user_address';
  static const String keyFarmerType = 'farmer_type';
  static const String keyNidFront = 'nid_front';
  static const String keyNidBack = 'nid_back';
  static const String keyTradeLicense = 'trade_license';
  static const String keyShopName = 'shop_name';
  static const String keyBusinessLicenseNo = 'business_license_no';
  static const String keyShopLocation = 'shop_location';
  static const String keyVerificationStatus = 'verification_status';
  static const String keyPhotoUrl = 'user_photo_url';

  static Future<void> saveUserSession({
    required bool isLoggedIn,
    required String role,
    required String name,
    required String email,
    required String phone,
    String? photoUrl,
    String? userId,
    String? token,
    String? district,
    String? upazila,
    String? union,
    String? address,
    String? farmerType,
    String? nidFront,
    String? nidBack,
    String? tradeLicense,
    String? shopName,
    String? businessLicenseNo,
    String? shopLocation,
    String? verificationStatus,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, isLoggedIn);
    await prefs.setString(keyUserRole, role);
    await prefs.setString(keyUserName, name);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyUserPhone, phone);

    if (photoUrl != null && photoUrl.isNotEmpty) await prefs.setString(keyPhotoUrl, photoUrl);
    if (userId != null && userId.isNotEmpty) await prefs.setString(keyUserId, userId);
    if (token != null && token.isNotEmpty) await prefs.setString(keyToken, token);
    if (district != null && district.isNotEmpty) await prefs.setString(keyDistrict, district);
    if (upazila != null && upazila.isNotEmpty) await prefs.setString(keyUpazila, upazila);
    if (union != null && union.isNotEmpty) await prefs.setString(keyUnion, union);
    if (address != null && address.isNotEmpty) await prefs.setString(keyAddress, address);
    if (farmerType != null && farmerType.isNotEmpty) await prefs.setString(keyFarmerType, farmerType);
    if (nidFront != null && nidFront.isNotEmpty) await prefs.setString(keyNidFront, nidFront);
    if (nidBack != null && nidBack.isNotEmpty) await prefs.setString(keyNidBack, nidBack);
    if (tradeLicense != null && tradeLicense.isNotEmpty) await prefs.setString(keyTradeLicense, tradeLicense);
    if (shopName != null && shopName.isNotEmpty) await prefs.setString(keyShopName, shopName);
    if (businessLicenseNo != null && businessLicenseNo.isNotEmpty) await prefs.setString(keyBusinessLicenseNo, businessLicenseNo);
    if (shopLocation != null && shopLocation.isNotEmpty) await prefs.setString(keyShopLocation, shopLocation);
    if (verificationStatus != null && verificationStatus.isNotEmpty) await prefs.setString(keyVerificationStatus, verificationStatus);
  }

  static Future<void> updateUserLocation({
    String? district,
    String? upazila,
    String? union,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (district != null) await prefs.setString(keyDistrict, district);
    if (upazila != null) await prefs.setString(keyUpazila, upazila);
    if (union != null) await prefs.setString(keyUnion, union);
    if (address != null) await prefs.setString(keyAddress, address);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? '';
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyToken) ?? '';
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyToken, token);
    await prefs.setBool(keyIsLoggedIn, token.trim().isNotEmpty);
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserRole, role);
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

  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserPhone) ?? '';
  }

  static Future<String> getUserDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyDistrict) ?? '';
  }

  static Future<String> getUserUpazila() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUpazila) ?? '';
  }

  static Future<String> getFarmerType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyFarmerType) ?? '';
  }

  static Future<String> getNidFront() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyNidFront) ?? '';
  }

  static Future<String> getNidBack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyNidBack) ?? '';
  }

  static Future<String> getTradeLicense() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyTradeLicense) ?? '';
  }

  static Future<String> getUserPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPhotoUrl) ?? '';
  }

  static Future<void> savePhotoUrl(String photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPhotoUrl, photoUrl);
  }

  static Future<String> getVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyVerificationStatus) ?? 'pending';
  }

  static Future<void> saveVerificationStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyVerificationStatus, status);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
