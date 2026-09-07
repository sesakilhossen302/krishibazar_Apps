enum UserRole {
  farmer('কৃষক / উৎপাদনকারী'),
  buyer('পাইকারি ক্রেতা / ব্যাপারি');

  final String labelBn;
  const UserRole(this.labelBn);
}

enum VerificationStatus {
  pending('যাচাইকরণ প্রক্রিয়াধীন'),
  verified('যাচাইকৃত (Verified)'),
  rejected('বাতিলকৃত (Rejected)'),
  suspended('সাময়িক স্থগিত (Suspended)');

  final String labelBn;
  const VerificationStatus(this.labelBn);
}

enum ProductCategory {
  vegetables('শাকসবজি', '🥦'),
  fruits('ফলমূল', '🍎'),
  paddy('ধান', '🌾'),
  rice('চাল', '🍚'),
  wheat('গম', '🌾'),
  potato('আলু', '🥔'),
  onion('পেঁয়াজ ও রসুন', '🧅'),
  fish('মাছ', '🐟'),
  other('অন্যান্য কৃষি পণ্য', '📦');

  final String labelBn;
  final String icon;
  const ProductCategory(this.labelBn, this.icon);
}

enum QualityGrade {
  gradeA('গ্রেড A (প্রিমিয়াম মান)'),
  gradeB('গ্রেড B (সাধারণ মান)'),
  organic('জৈব / অর্গানিক');

  final String labelBn;
  const QualityGrade(this.labelBn);
}

enum ProductUnit {
  kg('কেজি (kg)'),
  mon('মন (৪০ কেজি)'),
  ton('টন (১০০০ কেজি)'),
  piece('পিস / আঁটি');

  final String labelBn;
  const ProductUnit(this.labelBn);
}

enum ProductStatus {
  pending('অনুমোদনের অপেক্ষায়'),
  active('বিক্রয়ের জন্য প্রস্তুত'),
  partiallySold('আংশিক বিক্রি হয়েছে'),
  sold('সম্পূর্ণ বিক্রি হয়েছে'),
  expired('মেয়াদ উত্তীর্ণ'),
  rejected('বাতিলকৃত');

  final String labelBn;
  const ProductStatus(this.labelBn);
}

enum DemandStatus {
  active('খোলা চাহিদা (Active)'),
  fulfilled('পূরণকৃত (Fulfilled)'),
  cancelled('বাতিল (Cancelled)');

  final String labelBn;
  const DemandStatus(this.labelBn);
}

enum OfferStatus {
  pending('বিবেচনাধীন'),
  accepted('গৃহীত (অর্ডার তৈরি হয়েছে)'),
  rejected('প্রত্যাখ্যাত'),
  cancelled('বাতিল');

  final String labelBn;
  const OfferStatus(this.labelBn);
}

enum OrderStatus {
  pending('অপেক্ষমাণ'),
  paymentConfirmed('ডিপোজিট প্রদান সম্পন্ন'),
  collectionVerified('হাব ওজন ও গুণমান যাচাই সম্পন্ন'),
  inTransit('পরিবহনরত (In Transit)'),
  delivered('পৌঁছেছে (Delivered)'),
  completed('সম্পূর্ণ সম্পন্ন'),
  disputed('অভিযোগ প্রক্রিয়াধীন'),
  cancelled('বাতিল');

  final String labelBn;
  const OrderStatus(this.labelBn);
}

enum TransportStatus {
  waiting('যানবাহনের অপেক্ষায়'),
  atCollectionCenter('কালেকশন সেন্টারে পৌছেছে'),
  inTransit('গন্তব্যের পথে চালিত'),
  delivered('পৌঁছে গেছে');

  final String labelBn;
  const TransportStatus(this.labelBn);
}

enum ProblemType {
  quantityMismatch('ওজনে কম পাওয়া গেছে'),
  qualityIssue('পণ্যের মান খারাপ / নষ্ট'),
  delayedDelivery('পরিবহনে অতিরিক্ত দেরি'),
  fraud('জালিয়াতি বা প্রতারণা'),
  other('অন্যান্য সমস্যা');

  final String labelBn;
  const ProblemType(this.labelBn);
}

enum DisputeStatus {
  open('নতুন অভিযোগ'),
  underReview('তদন্তধীন (Under Review)'),
  resolved('মীমাংসিত (Resolved)'),
  dismissed('খারিজ (Dismissed)');

  final String labelBn;
  const DisputeStatus(this.labelBn);
}

class FarmerProfile {
  final String id;
  final String name;
  final String phone;
  final String photoUrl;
  final String district;
  final String upazila;
  final String union;
  final String address;
  final String farmerType;
  final VerificationStatus verificationStatus;
  final String nidOrDoc;
  final int totalCompletedOrders;
  final double rating;
  final int reviewsCount;

  FarmerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl = '',
    required this.district,
    required this.upazila,
    required this.union,
    required this.address,
    required this.farmerType,
    this.verificationStatus = VerificationStatus.verified,
    this.nidOrDoc = 'NID-7829102938',
    this.totalCompletedOrders = 12,
    this.rating = 4.8,
    this.reviewsCount = 18,
  });
}

class BuyerProfile {
  final String id;
  final String name;
  final String phone;
  final String businessName;
  final String businessType;
  final String district;
  final String area;
  final String address;
  final String tradeInfo;
  final VerificationStatus verificationStatus;
  final int completedOrders;
  final double rating;
  final int reviewsCount;
  final int paymentReliability;

  BuyerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.businessName,
    required this.businessType,
    required this.district,
    required this.area,
    required this.address,
    this.tradeInfo = 'TR-DH-892182',
    this.verificationStatus = VerificationStatus.verified,
    this.completedOrders = 24,
    this.rating = 4.9,
    this.reviewsCount = 30,
    this.paymentReliability = 98,
  });
}

class ProductListing {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerDistrict;
  final bool farmerVerified;
  final String title;
  final ProductCategory category;
  final double quantity;
  final double remainingQuantity;
  final ProductUnit unit;
  final double expectedPrice;
  final double minPrice;
  final String location;
  final String availableDate;
  final String harvestDate;
  final QualityGrade qualityGrade;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? videoNote;
  final ProductStatus status;
  final String createdAt;

  ProductListing({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerDistrict,
    this.farmerVerified = true,
    required this.title,
    required this.category,
    required this.quantity,
    required this.remainingQuantity,
    required this.unit,
    required this.expectedPrice,
    required this.minPrice,
    required this.location,
    required this.availableDate,
    required this.harvestDate,
    required this.qualityGrade,
    required this.description,
    this.imageUrls = const [],
    this.videoUrl,
    this.videoNote,
    this.status = ProductStatus.active,
    required this.createdAt,
  });
}

class BuyerDemand {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerBusinessName;
  final String buyerDistrict;
  final bool buyerVerified;
  final String productTitle;
  final ProductCategory category;
  final double requiredQuantity;
  final double fulfilledQuantity;
  final ProductUnit unit;
  final String requiredLocation;
  final String requiredDate;
  final double minExpectedPrice;
  final double maxExpectedPrice;
  final QualityGrade qualityGrade;
  final String additionalNote;
  final DemandStatus status;
  final int offersCount;
  final String createdAt;

  BuyerDemand({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerBusinessName,
    required this.buyerDistrict,
    this.buyerVerified = true,
    required this.productTitle,
    required this.category,
    required this.requiredQuantity,
    this.fulfilledQuantity = 0.0,
    required this.unit,
    required this.requiredLocation,
    required this.requiredDate,
    required this.minExpectedPrice,
    required this.maxExpectedPrice,
    required this.qualityGrade,
    required this.additionalNote,
    this.status = DemandStatus.active,
    this.offersCount = 0,
    required this.createdAt,
  });
}

class FarmerOffer {
  final String id;
  final String demandId;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmerLocation;
  final bool farmerVerified;
  final double offeredQuantity;
  final ProductUnit unit;
  final double pricePerUnit;
  final QualityGrade qualityGrade;
  final String availableDate;
  final String note;
  final OfferStatus status;
  final String createdAt;

  FarmerOffer({
    required this.id,
    required this.demandId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerLocation,
    this.farmerVerified = true,
    required this.offeredQuantity,
    required this.unit,
    required this.pricePerUnit,
    required this.qualityGrade,
    required this.availableDate,
    required this.note,
    this.status = OfferStatus.pending,
    required this.createdAt,
  });
}

class DeliveryInfo {
  final String pickupLocation;
  final String collectionCenter;
  final String deliveryLocation;
  final TransportStatus transportStatus;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String estimatedArrival;

  DeliveryInfo({
    required this.pickupLocation,
    required this.collectionCenter,
    required this.deliveryLocation,
    this.transportStatus = TransportStatus.waiting,
    this.driverName = 'মোঃ রফিকুল ইসলাম',
    this.driverPhone = '01712-345678',
    this.vehicleNumber = 'ঢাকা মেট্রো-ট ১১-৪৫২৩',
    this.estimatedArrival = 'আজ বিকাল ৪:০০',
  });
}

class QualityVerification {
  final double expectedWeight;
  final double actualWeight;
  final ProductUnit unit;
  final QualityGrade qualityGrade;
  final String verifiedBy;
  final String verificationDate;
  final String notes;
  final bool isVerified;

  QualityVerification({
    required this.expectedWeight,
    required this.actualWeight,
    required this.unit,
    required this.qualityGrade,
    this.verifiedBy = 'মোঃ আশরাফুল (কালেকশন হাব ইন্সপেক্টর)',
    this.verificationDate = 'আজ দুপুর ১২:৩০',
    this.notes = 'ওজন সম্পূর্ণ সঠিক, গ্রেড A মান নিশ্চিত করা হয়েছে',
    this.isVerified = true,
  });
}

class MarketplaceOrder {
  final String id;
  final String orderNumber;
  final String? demandId;
  final String? offerId;
  final String buyerId;
  final String buyerName;
  final String buyerBusinessName;
  final String buyerPhone;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmerLocation;
  final String productTitle;
  final ProductCategory category;
  final double quantity;
  final ProductUnit unit;
  final double pricePerUnit;
  final double totalAmount;
  final double depositRequired;
  final bool isDepositPaid;
  final OrderStatus orderStatus;
  final String deliveryLocation;
  final String expectedDeliveryDate;
  final DeliveryInfo deliveryInfo;
  final QualityVerification verification;
  final bool hasDispute;
  final bool isRated;
  final String createdAt;

  MarketplaceOrder({
    required this.id,
    required this.orderNumber,
    this.demandId,
    this.offerId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerBusinessName,
    required this.buyerPhone,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerLocation,
    required this.productTitle,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.depositRequired,
    this.isDepositPaid = false,
    this.orderStatus = OrderStatus.pending,
    required this.deliveryLocation,
    required this.expectedDeliveryDate,
    required this.deliveryInfo,
    required this.verification,
    this.hasDispute = false,
    this.isRated = false,
    required this.createdAt,
  });
}

class Dispute {
  final String id;
  final String orderId;
  final String orderNumber;
  final UserRole reportedByRole;
  final String reporterName;
  final String reporterPhone;
  final ProblemType problemType;
  final String description;
  final DisputeStatus status;
  final String adminNotes;
  final String createdAt;

  Dispute({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.reportedByRole,
    required this.reporterName,
    required this.reporterPhone,
    required this.problemType,
    required this.description,
    this.status = DisputeStatus.underReview,
    this.adminNotes = '',
    required this.createdAt,
  });
}

class NotificationItem {
  final String id;
  final UserRole? targetRole;
  final String title;
  final String message;
  final String timestamp;
  final bool isRead;
  final String? relatedOrderId;
  final String? relatedDemandId;
  final String? targetUserId;

  NotificationItem({
    required this.id,
    this.targetRole,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedOrderId,
    this.relatedDemandId,
    this.targetUserId,
  });
}

class ChatMessage {
  final String id;
  final String orderId;
  final String senderName;
  final UserRole senderRole;
  final String message;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
  });
}

class UserReview {
  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  UserReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
