import 'dart:async';
import 'package:flutter/material.dart';
import '../Model/krishi_models.dart';
import '../../Utils/StaticString/static_string.dart';
import '../../service/api_client.dart';
import '../../helper/shared_pref/shared_pref_helper.dart';

class KrishiRepository extends ChangeNotifier {
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

  bool _onlyVerifiedFarmers = false;
  bool get onlyVerifiedFarmers => _onlyVerifiedFarmers;

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

  void onNidReuploaded({
    required String nidNumber,
    required String nidFrontUrl,
    required String nidBackUrl,
  }) {
    if (_currentRole == UserRole.farmer) {
      _currentFarmer = _currentFarmer.copyWith(
        verificationStatus: VerificationStatus.pending,
        adminNote: 'ইউজার নতুন এনআইডি জমা দিয়েছেন (যাচাই প্রয়োজন)',
        nidStatus: 'pending',
        nidRejectionNote: '',
        nidFrontUrl: nidFrontUrl,
        nidBackUrl: nidBackUrl,
        nidOrDoc: nidNumber.isNotEmpty ? nidNumber : _currentFarmer.nidOrDoc,
      );
    } else {
      _currentBuyer = _currentBuyer.copyWith(
        verificationStatus: VerificationStatus.pending,
        adminNote: 'ইউজার নতুন এনআইডি জমা দিয়েছেন (যাচাই প্রয়োজন)',
        nidStatus: 'pending',
        nidRejectionNote: '',
        nidFrontUrl: nidFrontUrl,
        nidBackUrl: nidBackUrl,
        nidOrDoc: nidNumber.isNotEmpty ? nidNumber : _currentBuyer.nidOrDoc,
      );
    }
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
        final rawStatus = data["verification_status"]?.toString() ?? "pending";

        if (userRole == "farmer") {
          _currentFarmer = FarmerProfile.fromBackendMap(data);
        } else {
          _currentBuyer = BuyerProfile.fromBackendMap(data);
        }

        await SharedPrefHelper.saveVerificationStatus(rawStatus);
      }
    } catch (e) {
      debugPrint("Error loading profile from backend: $e");
    } finally {
      isProfileLoading = false;
      notifyListeners();
      // Fetch latest notifications whenever profile loads
      fetchNotificationsFromBackend();
    }
  }

  bool isNotificationsLoading = false;

  Future<void> fetchNotificationsFromBackend() async {
    final isLoggedIn = await SharedPrefHelper.isLoggedIn();
    if (!isLoggedIn) return;

    final token = await SharedPrefHelper.getToken();
    final userId = await SharedPrefHelper.getUserId();

    isNotificationsLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient.fetchNotifications(
        token: token.isNotEmpty ? token : null,
        userId: userId.isNotEmpty ? userId : null,
      );

      if (res["success"] == true && res["data"] is List) {
        final list = res["data"] as List;
        final fetched = list.map((item) {
          if (item is Map<String, dynamic>) {
            return NotificationItem.fromBackendMap(item);
          } else if (item is Map) {
            return NotificationItem.fromBackendMap(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<NotificationItem>().toList();

        _notifications = fetched;
      }
    } catch (e) {
      debugPrint("Error fetching notifications from backend: $e");
    } finally {
      isNotificationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
    final token = await SharedPrefHelper.getToken();
    await ApiClient.markNotificationRead(id, token: token.isNotEmpty ? token : null);
  }

  Future<void> markAllNotificationsAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    final token = await SharedPrefHelper.getToken();
    final userId = await SharedPrefHelper.getUserId();
    await ApiClient.markAllNotificationsRead(
      token: token.isNotEmpty ? token : null,
      userId: userId.isNotEmpty ? userId : null,
    );
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();

    final token = await SharedPrefHelper.getToken();
    await ApiClient.deleteNotification(id, token: token.isNotEmpty ? token : null);
  }


  List<FarmerProfile> _farmers = [];
  List<FarmerProfile> get farmers => _farmers;

  List<BuyerProfile> _buyers = [];
  List<BuyerProfile> get buyers => _buyers;

  List<ProductListing> _products = [];
  List<ProductListing> get products => _products;

  List<BuyerDemand> _demands = [];
  List<BuyerDemand> get demands => _demands;

  List<FarmerOffer> _offers = [];
  List<FarmerOffer> get offers => _offers;

  List<MarketplaceOrder> _orders = [];
  List<MarketplaceOrder> get orders => _orders;

  final List<Dispute> _disputes = [];
  List<Dispute> get disputes => _disputes;

  final List<UserReview> _reviews = [];
  List<UserReview> get reviews => _reviews;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  // Active Dialog Overlay States
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

  Timer? _periodicSyncTimer;

  void startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final isLoggedIn = await SharedPrefHelper.isLoggedIn();
      if (isLoggedIn) {
        loadProfileFromBackend();
      }
    });
  }

  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  KrishiRepository() {
    _initData();
    loadProfileFromBackend();
    startPeriodicSync();
  }

  void _initData() {
    _farmers = [
      FarmerProfile(
        id: 'farmer_1',
        name: 'মো: আব্দুল রহিম',
        phone: '01712-892102',
        district: 'রাজশাহী',
        upazila: 'গোদাগাড়ী',
        union: 'বাণিজ্যিক খামারি',
        address: 'গ্রাম: গোদাগাড়ী, রাজশাহী',
        farmerType: 'বাণিজ্যিক খামারি',
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
        farmerName: 'মো: আব্দুল রহিম',
        farmerDistrict: 'রাজশাহী',
        title: 'রাজশাহীর মিষ্টি পাকা টমেটো',
        category: ProductCategory.vegetables,
        quantity: 3500.0,
        remainingQuantity: 3500.0,
        unit: ProductUnit.kg,
        expectedPrice: 38.0,
        minPrice: 35.0,
        location: 'গোদাগাড়ী, রাজশাহী',
        availableDate: 'তাত্ক্ষণিক',
        harvestDate: 'গতকাল তোলা',
        qualityGrade: QualityGrade.gradeA,
        description:
            'ক্ষেতের টাটকা ও মিষ্টি পাকা টমেটো। চমৎকার লাল রঙ ও উন্নত গ্রেড।',
        imageUrls: [
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
        ],
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        videoNote: 'ক্ষেতের ভিডিও 🎬',
        status: ProductStatus.active,
        createdAt: '১০ মিনিট আগে',
      ),
      ProductListing(
        id: 'prod_2',
        farmerId: 'farmer_1',
        farmerName: 'মো: আব্দুল রহিম',
        farmerDistrict: 'রাজশাহী',
        title: 'হিমসাগর আম (অগ্রিম বুকিং)',
        category: ProductCategory.fruits,
        quantity: 2000.0,
        remainingQuantity: 2000.0,
        unit: ProductUnit.kg,
        expectedPrice: 95.0,
        minPrice: 90.0,
        location: 'বাঘা, রাজশাহী',
        availableDate: 'আগামী সপ্তাহ',
        harvestDate: 'গাছপাকা',
        qualityGrade: QualityGrade.gradeA,
        description:
            'রাজশাহীর বিখ্যাত সুস্বাদু হিমসাগর আম। কেমিক্যালমুক্ত গাছপাকা আম।',
        imageUrls: [
          'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=600&q=80',
        ],
        status: ProductStatus.active,
        createdAt: '১ ঘন্টা আগে',
      ),
      ProductListing(
        id: 'prod_3',
        farmerId: 'farmer_1',
        farmerName: 'মো: আব্দুল রহিম',
        farmerDistrict: 'রাজশাহী',
        title: 'সবুজ কাঁচা পেঁপে (রান্নার জন্য)',
        category: ProductCategory.vegetables,
        quantity: 2000.0,
        remainingQuantity: 2000.0,
        unit: ProductUnit.kg,
        expectedPrice: 24.0,
        minPrice: 22.0,
        location: 'গোদাগাড়ী, রাজশাহী',
        availableDate: 'তাত্ক্ষণিক',
        harvestDate: 'তাজা ডাল কাটা',
        qualityGrade: QualityGrade.gradeA,
        description:
            'সরাসরি গাছ থেকে তাজা কাটা কাঁচা পেঁপে। তরকারি ও রান্নার উপযোগী।',
        imageUrls: [
          'https://images.unsplash.com/photo-1617112848923-cc2234396a8d?auto=format&fit=crop&w=600&q=80',
        ],
        status: ProductStatus.pending,
        createdAt: '৩ ঘন্টা আগে',
      ),
    ];

    _demands = [
      BuyerDemand(
        id: 'dem_1',
        buyerId: 'buyer_1',
        buyerName: 'আলহাজ্ব শফিকুল ইসলাম',
        buyerBusinessName: 'কাওরান বাজার পাইকারি আড়ত',
        buyerDistrict: 'ঢাকা',
        productTitle: 'টমেটো (Tomato)',
        category: ProductCategory.vegetables,
        requiredQuantity: 2000.0,
        unit: ProductUnit.kg,
        requiredLocation: 'কাওরান বাজার আড়ত, ঢাকা',
        requiredDate: '২০ সেপ্টেম্বর',
        minExpectedPrice: 40.0,
        maxExpectedPrice: 45.0,
        qualityGrade: QualityGrade.gradeA,
        additionalNote: 'লাল পাকা ফ্রেশ টমেটো প্রয়োজন, ক্র্যাটিং ভালো হতে হবে।',
        offersCount: 3,
        createdAt: '১০ মিনিট আগে',
      ),
      BuyerDemand(
        id: 'dem_2',
        buyerId: 'buyer_1',
        buyerName: 'আলহাজ্ব শফিকুল ইসলাম',
        buyerBusinessName: 'কাওরান বাজার পাইকারি আড়ত',
        buyerDistrict: 'ঢাকা',
        productTitle: 'পুকুরের তাজা রুই মাছ (Fish)',
        category: ProductCategory.fish,
        requiredQuantity: 1200.0,
        unit: ProductUnit.kg,
        requiredLocation: 'কাওরান বাজার মাছের আড়ত, ঢাকা',
        requiredDate: '১৭ সেপ্টেম্বর',
        minExpectedPrice: 270.0,
        maxExpectedPrice: 290.0,
        qualityGrade: QualityGrade.gradeA,
        additionalNote: '১.৫ থেকে ২ কেজি সাইজের তাজা রুই মাছ।',
        offersCount: 2,
        createdAt: '১ ঘন্টা আগে',
      ),
      BuyerDemand(
        id: 'dem_3',
        buyerId: 'buyer_2',
        buyerName: 'উত্তরা ট্রেডার্স',
        buyerBusinessName: 'উত্তরা পাইকারি ঘর',
        buyerDistrict: 'ঢাকা',
        productTitle: 'মিষ্টি হানিকুইন আনারস (Pineapple)',
        category: ProductCategory.fruits,
        requiredQuantity: 2000.0,
        unit: ProductUnit.piece,
        requiredLocation: 'উত্তরা সেক্টর ৭ বাজার, ঢাকা',
        requiredDate: '২০ সেপ্টেম্বর',
        minExpectedPrice: 32.0,
        maxExpectedPrice: 36.0,
        qualityGrade: QualityGrade.gradeA,
        additionalNote: 'রসালো ও মিষ্টি টাঙ্গাইল মধুপুরের আনারস।',
        offersCount: 2,
        createdAt: '২ ঘন্টা আগে',
      ),
      BuyerDemand(
        id: 'dem_4',
        buyerId: 'buyer_2',
        buyerName: 'শ্যামবাজার এগ্রো',
        buyerBusinessName: 'শ্যামবাজার ট্রেডার্স',
        buyerDistrict: 'ঢাকা',
        productTitle: 'শুকনো আটা গম (Wheat)',
        category: ProductCategory.wheat,
        requiredQuantity: 4000.0,
        unit: ProductUnit.kg,
        requiredLocation: 'শ্যামবাজার ঘাট, ঢাকা',
        requiredDate: '২৪ সেপ্টেম্বর',
        minExpectedPrice: 40.0,
        maxExpectedPrice: 44.0,
        qualityGrade: QualityGrade.gradeB,
        additionalNote: 'ভালো মানের গম। পোকা বা ভেজাল থাকা চলবে না।',
        offersCount: 4,
        createdAt: '৩ ঘন্টা আগে',
      ),
    ];

    _offers = [
      FarmerOffer(
        id: 'off_101',
        demandId: 'dem_1',
        farmerId: 'farmer_1',
        farmerName: 'মো: আব্দুল রহিম',
        farmerPhone: '01712-892102',
        farmerLocation: 'গোদাগাড়ী, রাজশাহী',
        offeredQuantity: 500.0,
        unit: ProductUnit.kg,
        pricePerUnit: 42.0,
        qualityGrade: QualityGrade.gradeA,
        availableDate: '১৮ সেপ্টেম্বর',
        note:
            'আমি ৫০০ কেজি দিতে পারব। গ্রেড এ পাকা টমেটো। প্লাস্টিক ক্রেটে ডেলিভারি।',
        status: OfferStatus.accepted,
        createdAt: '১০ মিনিট আগে',
      ),
      FarmerOffer(
        id: 'off_102',
        demandId: 'dem_1',
        farmerId: 'farmer_2',
        farmerName: 'করিম উল্লাহ মৃধা',
        farmerPhone: '01892-120934',
        farmerLocation: 'শিবগঞ্জ, বগুড়া',
        offeredQuantity: 800.0,
        unit: ProductUnit.kg,
        pricePerUnit: 41.0,
        qualityGrade: QualityGrade.gradeA,
        availableDate: '১৯ সেপ্টেম্বর',
        note: 'আমি ৮০০ কেজি দিতে পারব। একদম তাজা বাগান থেকে তোলা।',
        status: OfferStatus.pending,
        createdAt: '২০ মিনিট আগে',
      ),
      FarmerOffer(
        id: 'off_103',
        demandId: 'dem_1',
        farmerId: 'farmer_3',
        farmerName: 'খলিলুর রহমান',
        farmerPhone: '01923-456789',
        farmerLocation: 'ঝিকরগাছা, যশোর',
        offeredQuantity: 700.0,
        unit: ProductUnit.kg,
        pricePerUnit: 42.0,
        qualityGrade: QualityGrade.gradeA,
        availableDate: '২০ সেপ্টেম্বর',
        note: 'আমি ৭০০ কেজি দেওয়ার জন্য প্রস্তুত।',
        status: OfferStatus.pending,
        createdAt: '৩০ মিনিট আগে',
      ),
      FarmerOffer(
        id: 'off_201',
        demandId: 'dem_2',
        farmerId: 'farmer_4',
        farmerName: 'আব্দুল লতিফ',
        farmerPhone: '01711-223344',
        farmerLocation: 'ত্রিশাল, ময়মনসিংহ',
        offeredQuantity: 1200.0,
        unit: ProductUnit.kg,
        pricePerUnit: 275.0,
        qualityGrade: QualityGrade.gradeA,
        availableDate: '১৬ সেপ্টেম্বর',
        note: 'অক্সিজেন ড্রামে করে একদম জীবন্ত রুই মাছ পৌঁছানো হবে।',
        status: OfferStatus.pending,
        createdAt: '১৫ মিনিট আগে',
      ),
      FarmerOffer(
        id: 'off_202',
        demandId: 'dem_2',
        farmerId: 'farmer_3',
        farmerName: 'খলিলুর রহমান',
        farmerPhone: '01923-456789',
        farmerLocation: 'ঝিকরগাছা, যশোর',
        offeredQuantity: 600.0,
        unit: ProductUnit.kg,
        pricePerUnit: 280.0,
        qualityGrade: QualityGrade.gradeA,
        availableDate: '১৭ সেপ্টেম্বর',
        note: 'পুকুরের তাজা রুই মাছ ৬০০ কেজি পাঠাতে পারি।',
        status: OfferStatus.pending,
        createdAt: '৪০ মিনিট আগে',
      ),
    ];

    _orders = [
      MarketplaceOrder(
        id: 'ord_1011',
        orderNumber: 'KB-1011',
        buyerId: 'buyer_1',
        buyerName: 'হাজী সালাহউদ্দিন',
        buyerBusinessName: 'কাওরান বাজার পাইকারি আড়ত',
        buyerPhone: '01911-543210',
        farmerId: 'farmer_1',
        farmerName: 'মো: আব্দুল রহিম (গোদাগাড়ী, রাজশাহী)',
        farmerPhone: '01712-892102',
        farmerLocation: 'রাজশাহী',
        productTitle: 'টমেটো (Tomato)',
        category: ProductCategory.vegetables,
        quantity: 500.0,
        unit: ProductUnit.kg,
        pricePerUnit: 42.0,
        totalAmount: 21000.0,
        depositRequired: 4200.0,
        isDepositPaid: false,
        orderStatus: OrderStatus.pending,
        deliveryLocation: 'কাওরান বাজার কাঁচাবাজার, ঢাকা',
        expectedDeliveryDate: '০৭ সেপ্টেম্বর',
        deliveryInfo: DeliveryInfo(
          pickupLocation: 'গোদাগাড়ী, রাজশাহী',
          collectionCenter: 'রাজশাহী কালেকশন হাব',
          deliveryLocation: 'কাওরান বাজার, ঢাকা',
          transportStatus: TransportStatus.waiting,
        ),
        verification: QualityVerification(
          expectedWeight: 500.0,
          actualWeight: 500.0,
          unit: ProductUnit.kg,
          qualityGrade: QualityGrade.gradeA,
          isVerified: false,
        ),
        createdAt: '02:29 PM, 07 Sep',
      ),
      MarketplaceOrder(
        id: 'ord_1001',
        orderNumber: 'KB-1001',
        buyerId: 'buyer_1',
        buyerName: 'হাজী সালাহউদ্দিন',
        buyerBusinessName: 'কাওরান বাজার পাইকারি আড়ত',
        buyerPhone: '01911-543210',
        farmerId: 'farmer_1',
        farmerName: 'মো: আব্দুল রহিম (গোদাগাড়ী, রাজশাহী)',
        farmerPhone: '01712-892102',
        farmerLocation: 'রাজশাহী',
        productTitle: 'মিষ্টি পাকা টমেটো',
        category: ProductCategory.vegetables,
        quantity: 10000.0,
        unit: ProductUnit.kg,
        pricePerUnit: 4.0,
        totalAmount: 40000.0,
        depositRequired: 8000.0,
        isDepositPaid: true,
        orderStatus: OrderStatus.completed,
        deliveryLocation: 'কাওরান বাজার কাঁচাবাজার, ঢাকা',
        expectedDeliveryDate: '২৯ আগস্ট',
        deliveryInfo: DeliveryInfo(
          pickupLocation: 'গোদাগাড়ী, রাজশাহী',
          collectionCenter: 'রাজশাহী কালেকশন হাব',
          deliveryLocation: 'কাওরান বাজার, ঢাকা',
          transportStatus: TransportStatus.delivered,
        ),
        verification: QualityVerification(
          expectedWeight: 10000.0,
          actualWeight: 10000.0,
          unit: ProductUnit.kg,
          qualityGrade: QualityGrade.gradeA,
          isVerified: true,
        ),
        createdAt: '২৯ আগস্ট',
      ),
      MarketplaceOrder(
        id: 'ord_1007',
        orderNumber: 'KB-1007',
        buyerId: 'buyer_1',
        buyerName: 'হাজী সালাহউদ্দিন',
        buyerBusinessName: 'কাওরান বাজার পাইকারি আড়ত',
        buyerPhone: '01911-543210',
        farmerId: 'farmer_2',
        farmerName: 'আব্দুল লতিফ (ত্রিশাল, ময়মনসিংহ)',
        farmerPhone: '01892-120934',
        farmerLocation: 'ময়মনসিংহ',
        productTitle: 'পুকুরের তাজা রুই মাছ',
        category: ProductCategory.fish,
        quantity: 800.0,
        unit: ProductUnit.kg,
        pricePerUnit: 275.0,
        totalAmount: 220000.0,
        depositRequired: 44000.0,
        isDepositPaid: true,
        orderStatus: OrderStatus.completed,
        deliveryLocation: 'কাওরান বাজার মাছের আড়ত, ঢাকা',
        expectedDeliveryDate: '১৫ আগস্ট',
        deliveryInfo: DeliveryInfo(
          pickupLocation: 'ত্রিশাল, ময়মনসিংহ',
          collectionCenter: 'ময়মনসিংহ কালেকশন হাব',
          deliveryLocation: 'কাওরান বাজার, ঢাকা',
          transportStatus: TransportStatus.delivered,
        ),
        verification: QualityVerification(
          expectedWeight: 800.0,
          actualWeight: 800.0,
          unit: ProductUnit.kg,
          qualityGrade: QualityGrade.gradeA,
          isVerified: true,
        ),
        createdAt: '১৫ আগস্ট',
      ),
    ];

    _notifications = [];

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
        message:
            'ওয়ালাইকুম আসসালাম। ধন্যবাদ হাশেম ভাই, ড্রাইভারের নাম্বার পাইছি।',
        timestamp: 'দুপুর ১২:০৫',
      ),
    ];
  }

  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void closeAllOverlays() {
    showAddProductDialog = false;
    showAddDemandDialog = false;
    showNotificationsSheet = false;
    showRoleSwitcherDialog = false;

    activeProductForDetail = null;
    activeDemandForOffer = null;
    activeDemandForOfferManagement = null;
    activeOrderForDetail = null;
    activeOrderForChat = null;
    activeOrderForDispute = null;
    activeOrderForRating = null;
    activeOrderForVerification = null;
  }

  void setFarmerTab(int index) {
    _farmerTabIndex = index;
    closeAllOverlays();
    notifyListeners();
  }

  void setBuyerTab(int index) {
    _buyerTabIndex = index;
    closeAllOverlays();
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
    if (district == 'সকল জেলা') {
      _selectedDistrict = null;
    } else {
      _selectedDistrict = district;
    }
    notifyListeners();
  }

  void toggleOnlyVerifiedFarmers() {
    _onlyVerifiedFarmers = !_onlyVerifiedFarmers;
    notifyListeners();
  }

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
    fetchNotificationsFromBackend();
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
      imageUrls: [
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
      ],
      createdAt: 'এখনই',
    );
    _products.insert(0, newProduct);
    closeAddProductDialog();
    snackbarMessage = StaticString.productAddedSuccess;
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    snackbarMessage = StaticString.productDeletedSuccess;
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
    snackbarMessage = StaticString.demandAddedSuccess;
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
    snackbarMessage = StaticString.offerSentSuccess;
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
    snackbarMessage = StaticString.offerAcceptedSuccess;
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
      snackbarMessage = StaticString.depositPaidSuccess;
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
      snackbarMessage = StaticString.transportUpdatedSuccess;
      notifyListeners();
    }
  }

  void submitWeightVerification(
    String orderId,
    double actualWeight,
    QualityGrade grade,
    String notes,
  ) {
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
      snackbarMessage = StaticString.verifSavedSuccess;
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
        reporterName: _currentRole == UserRole.buyer
            ? _currentBuyer.name
            : _currentFarmer.name,
        reporterPhone: _currentRole == UserRole.buyer
            ? _currentBuyer.phone
            : _currentFarmer.phone,
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
      snackbarMessage = StaticString.disputeSubmittedSuccess;
      notifyListeners();
    }
  }

  void sendChatMessage(String orderId, String text) {
    if (text.trim().isEmpty) return;
    final senderName = _currentRole == UserRole.buyer
        ? _currentBuyer.name
        : _currentFarmer.name;
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

  @override
  void dispose() {
    stopPeriodicSync();
    super.dispose();
  }
}
