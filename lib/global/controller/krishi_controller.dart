import 'package:flutter/material.dart';
import '../Model/krishi_models.dart';
import '../../service/api_client.dart';
import '../../helper/shared_pref/shared_pref_helper.dart';

class KrishiController extends ChangeNotifier {
  UserRole _currentRole = UserRole.farmer;
  UserRole get currentRole => _currentRole;

  int _farmerTabIndex = 0;
  int get farmerTabIndex => _farmerTabIndex;

  int _buyerTabIndex = 0;
  int get buyerTabIndex => _buyerTabIndex;

  int _adminTabIndex = 0;
  int get adminTabIndex => _adminTabIndex;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ProductCategory? _selectedCategory;
  ProductCategory? get selectedCategory => _selectedCategory;

  String? _selectedDistrict;
  String? get selectedDistrict => _selectedDistrict;

  // Profiles
  late FarmerProfile _currentFarmer;
  FarmerProfile get currentFarmer => _currentFarmer;

  late BuyerProfile _currentBuyer;
  BuyerProfile get currentBuyer => _currentBuyer;

  bool isProfileLoading = false;

  void updateCurrentFarmer(FarmerProfile profile) {
    _currentFarmer = profile;
    notifyListeners();
  }

  void updateCurrentBuyer(BuyerProfile profile) {
    _currentBuyer = profile;
    notifyListeners();
  }

  Future<void> loadProfileFromBackend() async {
    final isLoggedIn = await SharedPrefHelper.isLoggedIn();
    if (!isLoggedIn) return;

    final token = await SharedPrefHelper.getToken();
    final userId = await SharedPrefHelper.getUserId();
    final phone = await SharedPrefHelper.getUserPhone();
    final email = await SharedPrefHelper.getUserEmail();
    final role = await SharedPrefHelper.getUserRole();

    isProfileLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient.fetchUserProfile(
        token: token.isNotEmpty ? token : null,
        userId: userId.isNotEmpty ? userId : null,
        phone: phone.isNotEmpty ? phone : null,
        email: email.isNotEmpty ? email : null,
      );

      if (res["success"] == true && res["data"] is Map<String, dynamic>) {
        final data = res["data"] as Map<String, dynamic>;
        final userRole = (data["role"] ?? role).toString().toLowerCase();

        if (userRole == "farmer") {
          _currentFarmer = FarmerProfile.fromBackendMap(data);
        } else {
          _currentBuyer = BuyerProfile.fromBackendMap(data);
        }
      }
    } catch (e) {
      debugPrint("Error loading profile from backend: $e");
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  List<FarmerProfile> _farmers = [];
  List<FarmerProfile> get farmers => _farmers;

  List<BuyerProfile> _buyers = [];
  List<BuyerProfile> get buyers => _buyers;

  // Core Data Lists
  List<ProductListing> _products = [];
  List<ProductListing> get products => _products;

  List<BuyerDemand> _demands = [];
  List<BuyerDemand> get demands => _demands;

  List<FarmerOffer> _offers = [];
  List<FarmerOffer> get offers => _offers;

  List<MarketplaceOrder> _orders = [];
  List<MarketplaceOrder> get orders => _orders;

  List<Dispute> _disputes = [];
  List<Dispute> get disputes => _disputes;

  List<UserReview> _reviews = [];
  List<UserReview> get reviews => _reviews;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  // Active Dialog / Modal States
  bool showAddProductDialog = false;
  bool showAddDemandDialog = false;
  bool showNotificationsSheet = false;
  bool showRoleSwitcherDialog = false;

  ProductListing? activeProductForDetail;
  BuyerDemand? activeDemandForOffer;
  BuyerDemand? activeDemandForOfferManagement;
  MarketplaceOrder? activeOrderForDetail;
  MarketplaceOrder? activeOrderForChat;
  MarketplaceOrder? activeOrderForDispute;
  MarketplaceOrder? activeOrderForRating;
  MarketplaceOrder? activeOrderForVerification;

  String? snackbarMessage;

  KrishiController() {
    _initData();
    loadProfileFromBackend();
  }

  void _initData() {
    _farmers = [
      FarmerProfile(
        id: 'farmer_1',
        name: 'মোঃ আব্দুল হাশেম',
        phone: '01712-892102',
        district: 'বগুড়া',
        upazila: 'শিবগঞ্জ',
        union: 'মহাস্থান',
        address: 'গ্রাম: মহাস্থানগড়, শিবগঞ্জ, বগুড়া',
        farmerType: 'সবজি ও আলু চাষী (১৫ বিঘা)',
      ),
      FarmerProfile(
        id: 'farmer_2',
        name: 'খলিলুর রহমান',
        phone: '01892-120934',
        district: 'দিনাজপুর',
        upazila: 'বীরগঞ্জ',
        union: 'মোহাম্মদপুর',
        address: 'গ্রাম: সুজালপুর, বীরগঞ্জ, দিনাজপুর',
        farmerType: 'ধান ও গম চাষী (২৫ বিঘা)',
      ),
    ];
    _currentFarmer = _farmers.first;

    _buyers = [
      BuyerProfile(
        id: 'buyer_1',
        name: 'আলহাজ্ব শফিকুল ইসলাম',
        phone: '01911-543210',
        businessName: 'কারওয়ান বাজার পাইকারি আরত store',
        businessType: 'পাইকারি আড়তদার ও সরবরাহকারী',
        district: 'ঢাকা',
        area: 'কারওয়ান বাজার',
        address: 'শেড নং ৪, কারওয়ান বাজার কাঁচাবাজার, ঢাকা',
      ),
      BuyerProfile(
        id: 'buyer_2',
        name: 'মাহমুদুল হাসান',
        phone: '01552-890123',
        businessName: 'গ্রিন ক্রপস এগ্রো ট্রেডার্স',
        businessType: 'সুপারশপ ও কর্পোরেট সাপ্লাই',
        district: 'গাজীপুর',
        area: 'টঙ্গী',
        address: 'প্লট ৪৫, স্টেশন রোড, টঙ্গী, গাজীপুর',
      ),
    ];
    _currentBuyer = _buyers.first;

    _products = [
      ProductListing(
        id: 'prod_1',
        farmerId: 'farmer_1',
        farmerName: 'মোঃ আব্দুল হাশেম',
        farmerDistrict: 'বগুড়া',
        title: 'টাটকা ডায়মন্ড লাল আলু (উচ্চ ফলনশীল)',
        category: ProductCategory.potato,
        quantity: 5000.0,
        remainingQuantity: 4200.0,
        unit: ProductUnit.kg,
        expectedPrice: 28.0,
        minPrice: 26.5,
        location: 'শিবগঞ্জ হিমাগার রোড, বগুড়া',
        availableDate: 'তাত্ক্ষণিক',
        harvestDate: 'গত ৩ দিন আগে',
        qualityGrade: QualityGrade.gradeA,
        description: 'মাটি থেকে তোলা টাটকা ও চকচকে লাল আলু। রোগবালাইমুক্ত ও চমৎকার মানের।',
        imageUrls: [
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=600&q=80'
        ],
        createdAt: '১০ মিনিট আগে',
      ),
      ProductListing(
        id: 'prod_2',
        farmerId: 'farmer_1',
        farmerName: 'মোঃ আব্দুল হাশেম',
        farmerDistrict: 'বগুড়া',
        title: 'দেশি লাল পাকা টমেটো (গ্রেড A)',
        category: ProductCategory.vegetables,
        quantity: 1200.0,
        remainingQuantity: 1200.0,
        unit: ProductUnit.kg,
        expectedPrice: 42.0,
        minPrice: 40.0,
        location: 'মহাস্থান হাট, বগুড়া',
        availableDate: 'আগামীকাল',
        harvestDate: 'আজ সকালে তোলা',
        qualityGrade: QualityGrade.gradeA,
        description: 'সরাসরি ক্ষেত থেকে তোলা তাজা শক্ত লাল টমেটো। পরিবহনের জন্য উপযুক্ত।',
        imageUrls: [
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80'
        ],
        createdAt: '১ ঘন্টা আগে',
      ),
      ProductListing(
        id: 'prod_3',
        farmerId: 'farmer_2',
        farmerName: 'খলিলুর রহমান',
        farmerDistrict: 'দিনাজপুর',
        title: 'সুগন্ধি কাটারিভোগ চাল (নতুন ধান)',
        category: ProductCategory.rice,
        quantity: 200.0,
        remainingQuantity: 180.0,
        unit: ProductUnit.mon,
        expectedPrice: 2450.0,
        minPrice: 2400.0,
        location: 'বীরগঞ্জ চাল কল রোড, দিনাজপুর',
        availableDate: 'তাত্ক্ষণিক',
        harvestDate: 'গত সপ্তাহে ছাঁটাই',
        qualityGrade: QualityGrade.organic,
        description: 'দিনাজপুরের বিখ্যাত কাটারিভোগ চাল। সুবাসিত ও দীর্ঘ দানা।',
        imageUrls: [
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80'
        ],
        createdAt: '৩ ঘন্টা আগে',
      ),
    ];

    _demands = [
      BuyerDemand(
        id: 'dem_1',
        buyerId: 'buyer_1',
        buyerName: 'আলহাজ্ব শফিকুল ইসলাম',
        buyerBusinessName: 'কারওয়ান বাজার পাইকারি আরত store',
        buyerDistrict: 'ঢাকা',
        productTitle: 'দেশি গোল পেঁয়াজ (জরুরি প্রয়োজন)',
        category: ProductCategory.onion,
        requiredQuantity: 3000.0,
        unit: ProductUnit.kg,
        requiredLocation: 'কারওয়ান বাজার, ঢাকা',
        requiredDate: 'আগামী ২ দিনের মধ্যে',
        minExpectedPrice: 65.0,
        maxExpectedPrice: 72.0,
        qualityGrade: QualityGrade.gradeA,
        additionalNote: 'শুকনো ও ভালো মানের পেঁয়াজ হতে হবে। ক্যাশ অন ডেলিভারি বা হাব যাচাই সাপেক্ষে পেমেন্ট।',
        offersCount: 3,
        createdAt: '২ ঘন্টা আগে',
      ),
    ];

    _offers = [
      FarmerOffer(
        id: 'off_1',
        demandId: 'dem_1',
        farmerId: 'farmer_1',
        farmerName: 'মোঃ আব্দুল হাশেম',
        farmerPhone: '01712-892102',
        farmerLocation: 'বগুড়া',
        offeredQuantity: 3000.0,
        unit: ProductUnit.kg,
        pricePerUnit: 68.0,
        qualityGrade: QualityGrade.gradeA,
        availableDate: 'আগামীকাল সকাল',
        note: 'সম্পূর্ণ শুকনো ও শুকানো পেঁয়াজ প্রস্তুত আছে। ট্রাক লোড করা যাবে।',
        status: OfferStatus.pending,
        createdAt: '১ ঘন্টা আগে',
      ),
    ];

    _orders = [
      MarketplaceOrder(
        id: 'ord_1001',
        orderNumber: 'KB-1001',
        buyerId: 'buyer_1',
        buyerName: 'আলহাজ্ব শফিকুল ইসলাম',
        buyerBusinessName: 'কারওয়ান বাজার পাইকারি আরত store',
        buyerPhone: '01911-543210',
        farmerId: 'farmer_1',
        farmerName: 'মোঃ আব্দুল হাশেম',
        farmerPhone: '01712-892102',
        farmerLocation: 'বগুড়া',
        productTitle: 'টাটকা ডায়মন্ড লাল আলু',
        category: ProductCategory.potato,
        quantity: 800.0,
        unit: ProductUnit.kg,
        pricePerUnit: 28.0,
        totalAmount: 22400.0,
        depositRequired: 4480.0,
        isDepositPaid: true,
        orderStatus: OrderStatus.inTransit,
        deliveryLocation: 'কারওয়ান বাজার কাঁচাবাজার, ঢাকা',
        expectedDeliveryDate: 'আজ বিকাল ৫:০০',
        deliveryInfo: DeliveryInfo(
          pickupLocation: 'শিবগঞ্জ, বগুড়া',
          collectionCenter: 'বগুড়া মেইন কালেকশন হাব',
          deliveryLocation: 'কারওয়ান বাজার, ঢাকা',
          transportStatus: TransportStatus.inTransit,
        ),
        verification: QualityVerification(
          expectedWeight: 800.0,
          actualWeight: 800.0,
          unit: ProductUnit.kg,
          qualityGrade: QualityGrade.gradeA,
        ),
        createdAt: 'গতকাল',
      ),
    ];

    _disputes = [];
    _reviews = [];

    _notifications = [
      NotificationItem(
        id: 'notif_1',
        title: 'কৃষি বাজার বাজারে নতুন আপডেট! 🌾',
        message: 'আপনাদের সুবিধার জন্য কালেকশন হাবে সরাসরি ওজন যাচাই ব্যবস্থা চালু হয়েছে।',
        timestamp: 'আজ সকাল ১০:০০',
      ),
    ];

    _chatMessages = [
      ChatMessage(
        id: 'msg_1',
        orderId: 'ord_1001',
        senderName: 'মোঃ আব্দুল হাশেম',
        senderRole: UserRole.farmer,
        message: 'আসসালামু আলাইকুম ভাই, মাল ট্রাকে লোড হয়ে রওনা দিয়েছে।',
        timestamp: 'দুপুর ১২:০০',
      ),
      ChatMessage(
        id: 'msg_2',
        orderId: 'ord_1001',
        senderName: 'আলহাজ্ব শফিকুল ইসলাম',
        senderRole: UserRole.buyer,
        message: 'ওয়ালাইকুম আসসালাম। ধন্যবাদ হাশেম ভাই, ড্রাইভারের নাম্বার পাইছি।',
        timestamp: 'দুপুর ১২:০৫',
      ),
    ];
  }

  // --- Role Switcher & Tab Control ---
  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void setFarmerTab(int index) {
    _farmerTabIndex = index;
    notifyListeners();
  }

  void setBuyerTab(int index) {
    _buyerTabIndex = index;
    notifyListeners();
  }

  void setAdminTab(int index) {
    _adminTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(ProductCategory? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setSelectedDistrict(String? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  // --- Dialog Triggers ---
  void openAddProductDialog() {
    showAddProductDialog = true;
    notifyListeners();
  }

  void closeAddProductDialog() {
    showAddProductDialog = false;
    notifyListeners();
  }

  void openAddDemandDialog() {
    showAddDemandDialog = true;
    notifyListeners();
  }

  void closeAddDemandDialog() {
    showAddDemandDialog = false;
    notifyListeners();
  }

  void openOfferDialog(BuyerDemand demand) {
    activeDemandForOffer = demand;
    notifyListeners();
  }

  void closeOfferDialog() {
    activeDemandForOffer = null;
    notifyListeners();
  }

  void openDemandOfferManagement(BuyerDemand demand) {
    activeDemandForOfferManagement = demand;
    notifyListeners();
  }

  void closeDemandOfferManagement() {
    activeDemandForOfferManagement = null;
    notifyListeners();
  }

  void openProductDetail(ProductListing product) {
    activeProductForDetail = product;
    notifyListeners();
  }

  void closeProductDetail() {
    activeProductForDetail = null;
    notifyListeners();
  }

  void openOrderDetail(MarketplaceOrder order) {
    activeOrderForDetail = order;
    notifyListeners();
  }

  void closeOrderDetail() {
    activeOrderForDetail = null;
    notifyListeners();
  }

  void openChat(MarketplaceOrder order) {
    activeOrderForChat = order;
    notifyListeners();
  }

  void closeChat() {
    activeOrderForChat = null;
    notifyListeners();
  }

  void openDisputeDialog(MarketplaceOrder order) {
    activeOrderForDispute = order;
    notifyListeners();
  }

  void closeDisputeDialog() {
    activeOrderForDispute = null;
    notifyListeners();
  }

  void openRatingDialog(MarketplaceOrder order) {
    activeOrderForRating = order;
    notifyListeners();
  }

  void closeRatingDialog() {
    activeOrderForRating = null;
    notifyListeners();
  }

  void openVerificationDialog(MarketplaceOrder order) {
    activeOrderForVerification = order;
    notifyListeners();
  }

  void closeVerificationDialog() {
    activeOrderForVerification = null;
    notifyListeners();
  }

  void openNotifications() {
    showNotificationsSheet = true;
    notifyListeners();
  }

  void closeNotifications() {
    showNotificationsSheet = false;
    notifyListeners();
  }

  void openRoleSwitcher() {
    showRoleSwitcherDialog = true;
    notifyListeners();
  }

  void closeRoleSwitcher() {
    showRoleSwitcherDialog = false;
    notifyListeners();
  }

  // --- Core Business Logic Actions ---
  void submitProduct({
    required String title,
    required ProductCategory category,
    required double quantity,
    required ProductUnit unit,
    required double expectedPrice,
    required double minPrice,
    required String location,
    required String availableDate,
    required String harvestDate,
    required QualityGrade qualityGrade,
    required String description,
    List<String> imageUrls = const [],
    String? videoUrl,
    String? videoNote,
  }) {
    final newProduct = ProductListing(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      farmerId: _currentFarmer.id,
      farmerName: _currentFarmer.name,
      farmerDistrict: _currentFarmer.district,
      title: title,
      category: category,
      quantity: quantity,
      remainingQuantity: quantity,
      unit: unit,
      expectedPrice: expectedPrice,
      minPrice: minPrice,
      location: location,
      availableDate: availableDate,
      harvestDate: harvestDate,
      qualityGrade: qualityGrade,
      description: description,
      imageUrls: imageUrls.isEmpty
          ? ['https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80']
          : imageUrls,
      videoUrl: videoUrl,
      videoNote: videoNote,
      createdAt: 'এখনই',
    );
    _products.insert(0, newProduct);
    closeAddProductDialog();
    snackbarMessage = "নতুন ফসল সফলভাবে বাজারে তালিকাভুক্ত হয়েছে!";
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    snackbarMessage = "ফসল তালিকা মুছে ফেলা হয়েছে।";
    notifyListeners();
  }

  void submitDemand(
    String title,
    ProductCategory cat,
    double qty,
    ProductUnit unit,
    String loc,
    String reqDate,
    double minP,
    double maxP,
    QualityGrade grade,
    String note,
  ) {
    final newDemand = BuyerDemand(
      id: 'dem_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: _currentBuyer.id,
      buyerName: _currentBuyer.name,
      buyerBusinessName: _currentBuyer.businessName,
      buyerDistrict: _currentBuyer.district,
      productTitle: title,
      category: cat,
      requiredQuantity: qty,
      unit: unit,
      requiredLocation: loc,
      requiredDate: reqDate,
      minExpectedPrice: minP,
      maxExpectedPrice: maxP,
      qualityGrade: grade,
      additionalNote: note,
      createdAt: 'এখনই',
    );
    _demands.insert(0, newDemand);
    closeAddDemandDialog();
    snackbarMessage = "চাহিদা পোস্ট সফলভাবে প্রকাশিত হয়েছে!";
    notifyListeners();
  }

  void submitOffer(
    String demandId,
    double qty,
    ProductUnit unit,
    double price,
    QualityGrade grade,
    String date,
    String note,
  ) {
    final newOffer = FarmerOffer(
      id: 'off_${DateTime.now().millisecondsSinceEpoch}',
      demandId: demandId,
      farmerId: _currentFarmer.id,
      farmerName: _currentFarmer.name,
      farmerPhone: _currentFarmer.phone,
      farmerLocation: _currentFarmer.district,
      offeredQuantity: qty,
      unit: unit,
      pricePerUnit: price,
      qualityGrade: grade,
      availableDate: date,
      note: note,
      createdAt: 'এখনই',
    );
    _offers.insert(0, newOffer);
    closeOfferDialog();
    snackbarMessage = "অফারটি সফলভাবে পাঠানো হয়েছে!";
    notifyListeners();
  }

  void acceptOffer(String offerId) {
    final offerIndex = _offers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) return;
    final offer = _offers[offerIndex];

    final demandIndex = _demands.indexWhere((d) => d.id == offer.demandId);
    final demand = demandIndex != -1 ? _demands[demandIndex] : null;

    final totalAmt = offer.offeredQuantity * offer.pricePerUnit;
    final deposit = totalAmt * 0.20;

    final newOrder = MarketplaceOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'KB-${1000 + _orders.length + 1}',
      demandId: offer.demandId,
      offerId: offer.id,
      buyerId: _currentBuyer.id,
      buyerName: _currentBuyer.name,
      buyerBusinessName: _currentBuyer.businessName,
      buyerPhone: _currentBuyer.phone,
      farmerId: offer.farmerId,
      farmerName: offer.farmerName,
      farmerPhone: offer.farmerPhone,
      farmerLocation: offer.farmerLocation,
      productTitle: demand?.productTitle ?? 'কৃষি ফসল অর্ডার',
      category: demand?.category ?? ProductCategory.vegetables,
      quantity: offer.offeredQuantity,
      unit: offer.unit,
      pricePerUnit: offer.pricePerUnit,
      totalAmount: totalAmt,
      depositRequired: deposit,
      isDepositPaid: false,
      orderStatus: OrderStatus.pending,
      deliveryLocation: demand?.requiredLocation ?? _currentBuyer.address,
      expectedDeliveryDate: offer.availableDate,
      deliveryInfo: DeliveryInfo(
        pickupLocation: offer.farmerLocation,
        collectionCenter: '${offer.farmerLocation} কালেকশন হাব',
        deliveryLocation: demand?.requiredLocation ?? _currentBuyer.address,
      ),
      verification: QualityVerification(
        expectedWeight: offer.offeredQuantity,
        actualWeight: offer.offeredQuantity,
        unit: offer.unit,
        qualityGrade: offer.qualityGrade,
        isVerified: false,
      ),
      createdAt: 'এখনই',
    );

    _orders.insert(0, newOrder);
    _offers[offerIndex] = FarmerOffer(
      id: offer.id,
      demandId: offer.demandId,
      farmerId: offer.farmerId,
      farmerName: offer.farmerName,
      farmerPhone: offer.farmerPhone,
      farmerLocation: offer.farmerLocation,
      offeredQuantity: offer.offeredQuantity,
      unit: offer.unit,
      pricePerUnit: offer.pricePerUnit,
      qualityGrade: offer.qualityGrade,
      availableDate: offer.availableDate,
      note: offer.note,
      status: OfferStatus.accepted,
      createdAt: offer.createdAt,
    );

    closeDemandOfferManagement();
    snackbarMessage = "অফারটি গ্রহণ করা হয়েছে এবং নতুন অর্ডার তৈরি হয়েছে!";
    notifyListeners();
  }

  void orderDirectProduct(String productId, double qty) {
    final prod = _products.firstWhere((p) => p.id == productId);
    final totalAmt = qty * prod.expectedPrice;
    final deposit = totalAmt * 0.20;

    final newOrder = MarketplaceOrder(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'KB-${1000 + _orders.length + 1}',
      buyerId: _currentBuyer.id,
      buyerName: _currentBuyer.name,
      buyerBusinessName: _currentBuyer.businessName,
      buyerPhone: _currentBuyer.phone,
      farmerId: prod.farmerId,
      farmerName: prod.farmerName,
      farmerPhone: '01712-892102',
      farmerLocation: prod.farmerDistrict,
      productTitle: prod.title,
      category: prod.category,
      quantity: qty,
      unit: prod.unit,
      pricePerUnit: prod.expectedPrice,
      totalAmount: totalAmt,
      depositRequired: deposit,
      isDepositPaid: false,
      orderStatus: OrderStatus.pending,
      deliveryLocation: _currentBuyer.address,
      expectedDeliveryDate: 'আগামী ২ দিনের মধ্যে',
      deliveryInfo: DeliveryInfo(
        pickupLocation: prod.location,
        collectionCenter: '${prod.farmerDistrict} কালেকশন হাব',
        deliveryLocation: _currentBuyer.address,
      ),
      verification: QualityVerification(
        expectedWeight: qty,
        actualWeight: qty,
        unit: prod.unit,
        qualityGrade: prod.qualityGrade,
        isVerified: false,
      ),
      createdAt: 'এখনই',
    );

    _orders.insert(0, newOrder);
    closeProductDetail();
    snackbarMessage = "সরাসরি অর্ডার তৈরি হয়েছে! অনুগ্রহ করে ২০% ডিপোজিট প্রদান করুন।";
    notifyListeners();
  }

  void payDeposit(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final o = _orders[index];
      _orders[index] = MarketplaceOrder(
        id: o.id,
        orderNumber: o.orderNumber,
        demandId: o.demandId,
        offerId: o.offerId,
        buyerId: o.buyerId,
        buyerName: o.buyerName,
        buyerBusinessName: o.buyerBusinessName,
        buyerPhone: o.buyerPhone,
        farmerId: o.farmerId,
        farmerName: o.farmerName,
        farmerPhone: o.farmerPhone,
        farmerLocation: o.farmerLocation,
        productTitle: o.productTitle,
        category: o.category,
        quantity: o.quantity,
        unit: o.unit,
        pricePerUnit: o.pricePerUnit,
        totalAmount: o.totalAmount,
        depositRequired: o.depositRequired,
        isDepositPaid: true,
        orderStatus: OrderStatus.paymentConfirmed,
        deliveryLocation: o.deliveryLocation,
        expectedDeliveryDate: o.expectedDeliveryDate,
        deliveryInfo: o.deliveryInfo,
        verification: o.verification,
        createdAt: o.createdAt,
      );

      if (activeOrderForDetail?.id == orderId) {
        activeOrderForDetail = _orders[index];
      }
      snackbarMessage = "২০% ডিপোজিট প্রদান সফল হয়েছে!";
      notifyListeners();
    }
  }

  void advanceTransport(String orderId, TransportStatus nextStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final o = _orders[index];
      OrderStatus nextOrderStatus = o.orderStatus;
      if (nextStatus == TransportStatus.atCollectionCenter) {
        nextOrderStatus = OrderStatus.collectionVerified;
      } else if (nextStatus == TransportStatus.inTransit) {
        nextOrderStatus = OrderStatus.inTransit;
      } else if (nextStatus == TransportStatus.delivered) {
        nextOrderStatus = OrderStatus.delivered;
      }

      _orders[index] = MarketplaceOrder(
        id: o.id,
        orderNumber: o.orderNumber,
        demandId: o.demandId,
        offerId: o.offerId,
        buyerId: o.buyerId,
        buyerName: o.buyerName,
        buyerBusinessName: o.buyerBusinessName,
        buyerPhone: o.buyerPhone,
        farmerId: o.farmerId,
        farmerName: o.farmerName,
        farmerPhone: o.farmerPhone,
        farmerLocation: o.farmerLocation,
        productTitle: o.productTitle,
        category: o.category,
        quantity: o.quantity,
        unit: o.unit,
        pricePerUnit: o.pricePerUnit,
        totalAmount: o.totalAmount,
        depositRequired: o.depositRequired,
        isDepositPaid: o.isDepositPaid,
        orderStatus: nextOrderStatus,
        deliveryLocation: o.deliveryLocation,
        expectedDeliveryDate: o.expectedDeliveryDate,
        deliveryInfo: DeliveryInfo(
          pickupLocation: o.deliveryInfo.pickupLocation,
          collectionCenter: o.deliveryInfo.collectionCenter,
          deliveryLocation: o.deliveryInfo.deliveryLocation,
          transportStatus: nextStatus,
          driverName: o.deliveryInfo.driverName,
          driverPhone: o.deliveryInfo.driverPhone,
          vehicleNumber: o.deliveryInfo.vehicleNumber,
          estimatedArrival: o.deliveryInfo.estimatedArrival,
        ),
        verification: o.verification,
        createdAt: o.createdAt,
      );

      if (activeOrderForDetail?.id == orderId) {
        activeOrderForDetail = _orders[index];
      }
      snackbarMessage = "পরিবহন স্ট্যাটাস আপডেট হয়েছে!";
      notifyListeners();
    }
  }

  void submitWeightVerification(String orderId, double actualWeight, QualityGrade grade, String notes) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final o = _orders[index];
      _orders[index] = MarketplaceOrder(
        id: o.id,
        orderNumber: o.orderNumber,
        demandId: o.demandId,
        offerId: o.offerId,
        buyerId: o.buyerId,
        buyerName: o.buyerName,
        buyerBusinessName: o.buyerBusinessName,
        buyerPhone: o.buyerPhone,
        farmerId: o.farmerId,
        farmerName: o.farmerName,
        farmerPhone: o.farmerPhone,
        farmerLocation: o.farmerLocation,
        productTitle: o.productTitle,
        category: o.category,
        quantity: o.quantity,
        unit: o.unit,
        pricePerUnit: o.pricePerUnit,
        totalAmount: o.totalAmount,
        depositRequired: o.depositRequired,
        isDepositPaid: o.isDepositPaid,
        orderStatus: OrderStatus.collectionVerified,
        deliveryLocation: o.deliveryLocation,
        expectedDeliveryDate: o.expectedDeliveryDate,
        deliveryInfo: o.deliveryInfo,
        verification: QualityVerification(
          expectedWeight: o.quantity,
          actualWeight: actualWeight,
          unit: o.unit,
          qualityGrade: grade,
          notes: notes,
          isVerified: true,
        ),
        createdAt: o.createdAt,
      );

      closeVerificationDialog();
      snackbarMessage = "কালেকশন হাবের ওজন ও গুণমান আপডেট সম্পূর্ণ হয়েছে!";
      notifyListeners();
    }
  }

  void submitDispute(String orderId, ProblemType type, String description) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final o = _orders[index];
      final newDispute = Dispute(
        id: 'disp_${DateTime.now().millisecondsSinceEpoch}',
        orderId: o.id,
        orderNumber: o.orderNumber,
        reportedByRole: _currentRole,
        reporterName: _currentRole == UserRole.buyer ? _currentBuyer.name : _currentFarmer.name,
        reporterPhone: _currentRole == UserRole.buyer ? _currentBuyer.phone : _currentFarmer.phone,
        problemType: type,
        description: description,
        createdAt: 'এখনই',
      );
      _disputes.insert(0, newDispute);

      _orders[index] = MarketplaceOrder(
        id: o.id,
        orderNumber: o.orderNumber,
        demandId: o.demandId,
        offerId: o.offerId,
        buyerId: o.buyerId,
        buyerName: o.buyerName,
        buyerBusinessName: o.buyerBusinessName,
        buyerPhone: o.buyerPhone,
        farmerId: o.farmerId,
        farmerName: o.farmerName,
        farmerPhone: o.farmerPhone,
        farmerLocation: o.farmerLocation,
        productTitle: o.productTitle,
        category: o.category,
        quantity: o.quantity,
        unit: o.unit,
        pricePerUnit: o.pricePerUnit,
        totalAmount: o.totalAmount,
        depositRequired: o.depositRequired,
        isDepositPaid: o.isDepositPaid,
        orderStatus: OrderStatus.disputed,
        deliveryLocation: o.deliveryLocation,
        expectedDeliveryDate: o.expectedDeliveryDate,
        deliveryInfo: o.deliveryInfo,
        verification: o.verification,
        hasDispute: true,
        createdAt: o.createdAt,
      );

      closeDisputeDialog();
      snackbarMessage = "অভিযোগটি জমা দেওয়া হয়েছে। অ্যাডমিন টিম দ্রুত যাচাই করবে।";
      notifyListeners();
    }
  }

  void sendChatMessage(String orderId, String text) {
    if (text.trim().isEmpty) return;
    final senderName = _currentRole == UserRole.buyer ? _currentBuyer.name : _currentFarmer.name;
    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      senderName: senderName,
      senderRole: _currentRole,
      message: text,
      timestamp: 'এখনই',
    );
    _chatMessages.add(newMsg);
    notifyListeners();
  }

  void clearSnackbar() {
    snackbarMessage = null;
    notifyListeners();
  }
}
