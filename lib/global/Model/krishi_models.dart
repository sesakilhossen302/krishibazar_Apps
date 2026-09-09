enum UserRole {
  farmer('কৃষক / উৎপাদনকারী'),
  buyer('পাইকারি ক্রেতা / ব্যাপারি');

  final String labelBn;
  const UserRole(this.labelBn);
}

enum VerificationStatus {
  pending('যাচাইকরণ প্রক্রিয়াধীন'),
  inProgress('তথ্য যাচাই চলমান 🔄'),
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
  final String email;
  final String photoUrl;
  final String district;
  final String upazila;
  final String union;
  final String address;
  final String farmerType;
  final VerificationStatus verificationStatus;
  final String nidOrDoc;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String krishiCardDocUrl;
  final String adminNote;
  final String nidStatus;
  final String nidRejectionNote;
  final int totalCompletedOrders;
  int get completedOrders => totalCompletedOrders;
  final double rating;
  final int reviewsCount;
  final int productsCount;
  final int offersCount;
  final int activeOrdersCount;
  final double totalEarnings;

  FarmerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.photoUrl = '',
    required this.district,
    required this.upazila,
    required this.union,
    required this.address,
    required this.farmerType,
    this.verificationStatus = VerificationStatus.pending,
    this.nidOrDoc = '',
    this.nidFrontUrl = '',
    this.nidBackUrl = '',
    this.krishiCardDocUrl = '',
    this.adminNote = '',
    this.nidStatus = 'pending',
    this.nidRejectionNote = '',
    this.totalCompletedOrders = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.productsCount = 0,
    this.offersCount = 0,
    this.activeOrdersCount = 0,
    this.totalEarnings = 0.0,
  });

  factory FarmerProfile.fromBackendMap(Map<String, dynamic> json) {
    VerificationStatus vStatus = VerificationStatus.pending;
    final rawStatus = (json['verification_status'] ?? '').toString().toLowerCase().replaceAll('_', '');
    if (rawStatus == 'verified') {
      vStatus = VerificationStatus.verified;
    } else if (rawStatus == 'inprogress') {
      vStatus = VerificationStatus.inProgress;
    } else if (rawStatus == 'rejected') {
      vStatus = VerificationStatus.rejected;
    } else if (rawStatus == 'suspended') {
      vStatus = VerificationStatus.suspended;
    } else {
      vStatus = VerificationStatus.pending;
    }

    return FarmerProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'কৃষক',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      upazila: json['upazila']?.toString() ?? '',
      union: json['union']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      farmerType: json['farmer_type']?.toString() ?? 'সাধারণ কৃষক',
      verificationStatus: vStatus,
      nidOrDoc: json['nid_or_doc']?.toString() ?? '',
      nidFrontUrl: json['nid_front_url']?.toString() ?? '',
      nidBackUrl: json['nid_back_url']?.toString() ?? '',
      krishiCardDocUrl: json['krishi_card_doc_url']?.toString() ?? '',
      adminNote: json['admin_note']?.toString() ?? '',
      nidStatus: json['nid_status']?.toString() ?? 'pending',
      nidRejectionNote: json['nid_rejection_note']?.toString() ?? '',
      totalCompletedOrders: (json['completed_orders'] is num)
          ? (json['completed_orders'] as num).toInt()
          : 0,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
      reviewsCount: (json['reviews_count'] is num)
          ? (json['reviews_count'] as num).toInt()
          : 0,
      productsCount: (json['products_count'] is num)
          ? (json['products_count'] as num).toInt()
          : ((json['total_products'] is num) ? (json['total_products'] as num).toInt() : 0),
      offersCount: (json['offers_count'] is num)
          ? (json['offers_count'] as num).toInt()
          : ((json['submitted_offers'] is num) ? (json['submitted_offers'] as num).toInt() : 0),
      activeOrdersCount: (json['active_orders_count'] is num)
          ? (json['active_orders_count'] as num).toInt()
          : ((json['active_orders'] is num) ? (json['active_orders'] as num).toInt() : 0),
      totalEarnings: (json['total_earnings'] is num)
          ? (json['total_earnings'] as num).toDouble()
          : 0.0,
    );
  }

  FarmerProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? district,
    String? upazila,
    String? union,
    String? address,
    String? farmerType,
    VerificationStatus? verificationStatus,
    String? nidOrDoc,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? krishiCardDocUrl,
    String? adminNote,
    String? nidStatus,
    String? nidRejectionNote,
    int? totalCompletedOrders,
    double? rating,
    int? reviewsCount,
    int? productsCount,
    int? offersCount,
    int? activeOrdersCount,
    double? totalEarnings,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      union: union ?? this.union,
      address: address ?? this.address,
      farmerType: farmerType ?? this.farmerType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      nidOrDoc: nidOrDoc ?? this.nidOrDoc,
      nidFrontUrl: nidFrontUrl ?? this.nidFrontUrl,
      nidBackUrl: nidBackUrl ?? this.nidBackUrl,
      krishiCardDocUrl: krishiCardDocUrl ?? this.krishiCardDocUrl,
      adminNote: adminNote ?? this.adminNote,
      nidStatus: nidStatus ?? this.nidStatus,
      nidRejectionNote: nidRejectionNote ?? this.nidRejectionNote,
      totalCompletedOrders: totalCompletedOrders ?? this.totalCompletedOrders,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      productsCount: productsCount ?? this.productsCount,
      offersCount: offersCount ?? this.offersCount,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }
}


class BuyerProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final String businessName;
  final String businessType;
  final String district;
  final String area;
  final String address;
  final String tradeInfo;
  final String tradeLicenseUrl;
  final String nidOrDoc;
  final String nidFrontUrl;
  final String nidBackUrl;
  final VerificationStatus verificationStatus;
  final String adminNote;
  final String nidStatus;
  final String nidRejectionNote;
  final int completedOrders;
  final double rating;
  final int reviewsCount;
  final int paymentReliability;
  final int productsCount;
  final int offersCount;
  final int activeOrdersCount;
  final double totalSpent;

  BuyerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.photoUrl = '',
    required this.businessName,
    required this.businessType,
    required this.district,
    required this.area,
    required this.address,
    this.tradeInfo = '',
    this.tradeLicenseUrl = '',
    this.nidOrDoc = '',
    this.nidFrontUrl = '',
    this.nidBackUrl = '',
    this.verificationStatus = VerificationStatus.pending,
    this.adminNote = '',
    this.nidStatus = 'pending',
    this.nidRejectionNote = '',
    this.completedOrders = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.paymentReliability = 100,
    this.productsCount = 0,
    this.offersCount = 0,
    this.activeOrdersCount = 0,
    this.totalSpent = 0.0,
  });

  factory BuyerProfile.fromBackendMap(Map<String, dynamic> json) {
    VerificationStatus vStatus = VerificationStatus.pending;
    final rawStatus = (json['verification_status'] ?? '').toString().toLowerCase().replaceAll('_', '');
    if (rawStatus == 'verified') {
      vStatus = VerificationStatus.verified;
    } else if (rawStatus == 'inprogress') {
      vStatus = VerificationStatus.inProgress;
    } else if (rawStatus == 'rejected') {
      vStatus = VerificationStatus.rejected;
    } else if (rawStatus == 'suspended') {
      vStatus = VerificationStatus.suspended;
    } else {
      vStatus = VerificationStatus.pending;
    }

    return BuyerProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'পাইকার/আড়তদার',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      businessType: json['business_type']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      area: json['arot_location']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      tradeInfo: json['trade_info']?.toString() ?? '',
      tradeLicenseUrl: json['trade_license_url']?.toString() ?? '',
      nidOrDoc: json['nid_or_doc']?.toString() ?? '',
      nidFrontUrl: json['nid_front_url']?.toString() ?? '',
      nidBackUrl: json['nid_back_url']?.toString() ?? '',
      verificationStatus: vStatus,
      adminNote: json['admin_note']?.toString() ?? '',
      nidStatus: json['nid_status']?.toString() ?? 'pending',
      nidRejectionNote: json['nid_rejection_note']?.toString() ?? '',
      completedOrders: (json['completed_orders'] is num)
          ? (json['completed_orders'] as num).toInt()
          : 0,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : 0.0,
      reviewsCount: (json['reviews_count'] is num)
          ? (json['reviews_count'] as num).toInt()
          : 0,
      paymentReliability: (json['payment_reliability'] is num)
          ? (json['payment_reliability'] as num).toInt()
          : 100,
      productsCount: (json['products_count'] is num)
          ? (json['products_count'] as num).toInt()
          : ((json['total_demands'] is num) ? (json['total_demands'] as num).toInt() : 0),
      offersCount: (json['offers_count'] is num)
          ? (json['offers_count'] as num).toInt()
          : 0,
      activeOrdersCount: (json['active_orders_count'] is num)
          ? (json['active_orders_count'] as num).toInt()
          : ((json['active_orders'] is num) ? (json['active_orders'] as num).toInt() : 0),
      totalSpent: (json['total_spent'] is num)
          ? (json['total_spent'] as num).toDouble()
          : 0.0,
    );
  }

  BuyerProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? businessName,
    String? businessType,
    String? district,
    String? area,
    String? address,
    String? tradeInfo,
    String? tradeLicenseUrl,
    String? nidOrDoc,
    String? nidFrontUrl,
    String? nidBackUrl,
    VerificationStatus? verificationStatus,
    String? adminNote,
    String? nidStatus,
    String? nidRejectionNote,
    int? completedOrders,
    double? rating,
    int? reviewsCount,
    int? paymentReliability,
    int? productsCount,
    int? offersCount,
    int? activeOrdersCount,
    double? totalSpent,
  }) {
    return BuyerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      district: district ?? this.district,
      area: area ?? this.area,
      address: address ?? this.address,
      tradeInfo: tradeInfo ?? this.tradeInfo,
      tradeLicenseUrl: tradeLicenseUrl ?? this.tradeLicenseUrl,
      nidOrDoc: nidOrDoc ?? this.nidOrDoc,
      nidFrontUrl: nidFrontUrl ?? this.nidFrontUrl,
      nidBackUrl: nidBackUrl ?? this.nidBackUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      adminNote: adminNote ?? this.adminNote,
      nidStatus: nidStatus ?? this.nidStatus,
      nidRejectionNote: nidRejectionNote ?? this.nidRejectionNote,
      completedOrders: completedOrders ?? this.completedOrders,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      paymentReliability: paymentReliability ?? this.paymentReliability,
      productsCount: productsCount ?? this.productsCount,
      offersCount: offersCount ?? this.offersCount,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
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

  factory ProductListing.fromBackendMap(Map<String, dynamic> json) {
    // Map category
    ProductCategory cat = ProductCategory.vegetables;
    final rawCat = (json['category'] ?? '').toString();
    for (var c in ProductCategory.values) {
      if (c.name.toLowerCase() == rawCat.toLowerCase() ||
          c.labelBn == rawCat ||
          rawCat.contains(c.labelBn)) {
        cat = c;
        break;
      }
    }

    // Map unit
    ProductUnit u = ProductUnit.kg;
    final rawUnit = (json['unit'] ?? '').toString();
    for (var unitEnum in ProductUnit.values) {
      if (unitEnum.name.toLowerCase() == rawUnit.toLowerCase() ||
          unitEnum.labelBn == rawUnit ||
          rawUnit.contains(unitEnum.labelBn)) {
        u = unitEnum;
        break;
      }
    }

    // Map quality grade
    QualityGrade qg = QualityGrade.gradeA;
    final rawGrade = (json['quality_grade'] ?? '').toString();
    for (var g in QualityGrade.values) {
      if (g.name.toLowerCase() == rawGrade.toLowerCase() ||
          g.labelBn == rawGrade ||
          rawGrade.contains(g.labelBn)) {
        qg = g;
        break;
      }
    }

    // Map images
    List<String> images = [];
    if (json['images'] is List) {
      images = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      images = json['image_url'].toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    // If still empty, add default placeholder
    if (images.isEmpty) {
      images = [
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80'
      ];
    }

    return ProductListing(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? 'কৃষক',
      farmerDistrict: json['farmer_district']?.toString() ?? 'বাংলাদেশ',
      farmerVerified: json['farmer_verified'] == true,
      title: json['title']?.toString() ?? 'পণ্য',
      category: cat,
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : 0.0,
      remainingQuantity: (json['remaining_quantity'] is num) ? (json['remaining_quantity'] as num).toDouble() : ((json['quantity'] is num) ? (json['quantity'] as num).toDouble() : 0.0),
      unit: u,
      expectedPrice: (json['expected_price'] is num) ? (json['expected_price'] as num).toDouble() : 0.0,
      minPrice: (json['min_price'] is num) ? (json['min_price'] as num).toDouble() : 0.0,
      location: json['location']?.toString() ?? '',
      availableDate: json['available_date']?.toString() ?? '',
      harvestDate: json['harvest_date']?.toString() ?? '',
      qualityGrade: qg,
      description: json['description']?.toString() ?? '',
      imageUrls: images,
      videoUrl: json['video_url']?.toString(),
      videoNote: json['video_note']?.toString(),
      status: ProductStatus.active,
      createdAt: json['created_at']?.toString() ?? 'এখনই',
    );
  }
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

  factory BuyerDemand.fromBackendMap(Map<String, dynamic> json) {
    // category mapping
    final catStr = (json['category'] ?? '').toString();
    ProductCategory cat = ProductCategory.other;
    for (var c in ProductCategory.values) {
      if (c.labelBn == catStr || c.name.toLowerCase() == catStr.toLowerCase()) {
        cat = c;
        break;
      }
    }
    if (cat == ProductCategory.other) {
      if (catStr.contains('শাক') || catStr.contains('সবজি') || catStr.contains('vegetable')) {
        cat = ProductCategory.vegetables;
      } else if (catStr.contains('ফল') || catStr.contains('fruit')) {
        cat = ProductCategory.fruits;
      } else if (catStr.contains('ধান') || catStr.contains('paddy')) {
        cat = ProductCategory.paddy;
      } else if (catStr.contains('চাল') || catStr.contains('rice')) {
        cat = ProductCategory.rice;
      } else if (catStr.contains('গম') || catStr.contains('wheat')) {
        cat = ProductCategory.wheat;
      } else if (catStr.contains('আলু') || catStr.contains('potato')) {
        cat = ProductCategory.potato;
      } else if (catStr.contains('পেঁয়াজ') || catStr.contains('onion')) {
        cat = ProductCategory.onion;
      } else if (catStr.contains('মাছ') || catStr.contains('fish')) {
        cat = ProductCategory.fish;
      }
    }

    // unit mapping
    final unitStr = (json['unit'] ?? '').toString();
    ProductUnit u = ProductUnit.kg;
    for (var val in ProductUnit.values) {
      if (val.labelBn == unitStr || val.name.toLowerCase() == unitStr.toLowerCase()) {
        u = val;
        break;
      }
    }
    if (unitStr.contains('মন')) {
      u = ProductUnit.mon;
    } else if (unitStr.contains('টন')) {
      u = ProductUnit.ton;
    } else if (unitStr.contains('পিস') || unitStr.contains('আঁটি')) {
      u = ProductUnit.piece;
    }

    // quality grade mapping
    final gradeStr = (json['quality_grade'] ?? '').toString();
    QualityGrade qGrade = QualityGrade.gradeA;
    if (gradeStr.contains('B') || gradeStr.contains('সাধারণ')) {
      qGrade = QualityGrade.gradeB;
    } else if (gradeStr.contains('জৈব') || gradeStr.contains('অর্গানিক') || gradeStr.toLowerCase().contains('organic')) {
      qGrade = QualityGrade.organic;
    } else {
      qGrade = QualityGrade.gradeA;
    }

    // status mapping
    final statusStr = (json['status'] ?? 'active').toString().toLowerCase();
    DemandStatus st = DemandStatus.active;
    if (statusStr.contains('fulfilled') || statusStr.contains('পূরণ')) {
      st = DemandStatus.fulfilled;
    } else if (statusStr.contains('cancelled') || statusStr.contains('বাতিল')) {
      st = DemandStatus.cancelled;
    }

    return BuyerDemand(
      id: (json['id'] ?? '').toString(),
      buyerId: (json['buyer_id'] ?? '').toString(),
      buyerName: (json['buyer_name'] ?? json['buyer_business_name'] ?? 'ক্রেতা').toString(),
      buyerBusinessName: (json['buyer_business_name'] ?? json['buyer_name'] ?? 'ব্যবসা প্রতিষ্ঠান').toString(),
      buyerDistrict: (json['buyer_district'] ?? json['required_location'] ?? 'ঢাকা').toString(),
      buyerVerified: json['buyer_verified'] == true || json['buyer_verified'] == null,
      productTitle: (json['product_title'] ?? '').toString(),
      category: cat,
      requiredQuantity: (json['required_quantity'] is num)
          ? (json['required_quantity'] as num).toDouble()
          : (double.tryParse(json['required_quantity']?.toString() ?? '') ?? 0.0),
      fulfilledQuantity: (json['fulfilled_quantity'] is num)
          ? (json['fulfilled_quantity'] as num).toDouble()
          : (double.tryParse(json['fulfilled_quantity']?.toString() ?? '') ?? 0.0),
      unit: u,
      requiredLocation: (json['required_location'] ?? '').toString(),
      requiredDate: (json['required_date'] ?? '').toString(),
      minExpectedPrice: (json['min_expected_price'] is num)
          ? (json['min_expected_price'] as num).toDouble()
          : (double.tryParse(json['min_expected_price']?.toString() ?? '') ?? 0.0),
      maxExpectedPrice: (json['max_expected_price'] is num)
          ? (json['max_expected_price'] as num).toDouble()
          : (double.tryParse(json['max_expected_price']?.toString() ?? '') ?? 0.0),
      qualityGrade: qGrade,
      additionalNote: (json['additional_note'] ?? '').toString(),
      status: st,
      offersCount: (json['offers_count'] is int)
          ? json['offers_count']
          : (int.tryParse(json['offers_count']?.toString() ?? '') ?? 0),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
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
  final String notificationType;

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
    this.notificationType = 'info',
  });

  factory NotificationItem.fromBackendMap(Map<String, dynamic> json) {
    final type = (json['notification_type'] ?? 'info').toString();
    final relId = (json['related_id'] ?? '').toString();
    return NotificationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      timestamp: (json['created_at'] ?? 'এখনই').toString(),
      isRead: json['is_read'] == true,
      notificationType: type,
      targetUserId: (json['user_id'] ?? '').toString(),
      relatedOrderId: type == 'order' ? relId : null,
      relatedDemandId: (type == 'demand' || type == 'offer') ? relId : null,
    );
  }

  NotificationItem copyWith({
    String? id,
    UserRole? targetRole,
    String? title,
    String? message,
    String? timestamp,
    bool? isRead,
    String? relatedOrderId,
    String? relatedDemandId,
    String? targetUserId,
    String? notificationType,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      targetRole: targetRole ?? this.targetRole,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedDemandId: relatedDemandId ?? this.relatedDemandId,
      targetUserId: targetUserId ?? this.targetUserId,
      notificationType: notificationType ?? this.notificationType,
    );
  }
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
