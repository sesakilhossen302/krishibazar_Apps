import '../../../../global/Model/krishi_models.dart';

class RegistrationFormData {
  UserRole role;
  String fullName;
  String email;
  String phone;
  String password;
  String nidFrontPath;
  String nidBackPath;

  // Buyer Specific
  String tradeLicensePath;
  String shopName;
  String businessLicenseNo;
  String shopLocation;

  // Farmer Specific
  String farmerCropDetails;
  String farmerLocation;

  RegistrationFormData({
    required this.role,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.nidFrontPath = '',
    this.nidBackPath = '',
    this.tradeLicensePath = '',
    this.shopName = '',
    this.businessLicenseNo = '',
    this.shopLocation = '',
    this.farmerCropDetails = '',
    this.farmerLocation = '',
  });
}
