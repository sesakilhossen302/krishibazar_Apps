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
  BuyerDemand? activeDemandForDetail;
  BuyerDemand? activeDemandForOffer;
  BuyerDemand? activeDemandForOfferManagement;
  MarketplaceOrder? activeOrderForDetail;
  MarketplaceOrder? activeOrderForChat;
  MarketplaceOrder? activeOrderForDispute;
  MarketplaceOrder? activeOrderForRating;
  MarketplaceOrder? activeOrderForVerification;

  String? snackbarMessage;

  bool isLoadingProducts = false;

  Future<void> fetchProductsFromBackend({bool force = false}) async {
    isLoadingProducts = true;
    notifyListeners();

    try {
      final res = await ApiClient.fetchProducts();
      if (res['success'] == true && res['data'] is List) {
        final List list = res['data'];
        final List<ProductListing> backendProducts = list.map((item) {
          return ProductListing.fromBackendMap(item);
        }).toList();

        _products = backendProducts;
      }
    } catch (e) {
      debugPrint('Error fetching products from backend: $e');
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  bool isLoadingDemands = false;

  Future<void> fetchDemandsFromBackend({bool force = false}) async {
    isLoadingDemands = true;
    notifyListeners();

    try {
      final res = await ApiClient.fetchDemands();
      if (res['success'] == true && res['data'] is List) {
        final List list = res['data'];
        final List<BuyerDemand> backendDemands = list.map((item) {
          return BuyerDemand.fromBackendMap(item);
        }).toList();

        _demands = backendDemands;
      }
    } catch (e) {
      debugPrint('Error fetching demands from backend: $e');
    } finally {
      isLoadingDemands = false;
      notifyListeners();
    }
  }

  bool isLoadingOffers = false;

  Future<void> fetchMyOffersFromBackend({bool force = false}) async {
    // Only farmers have "my submitted offers"
    if (_currentRole != UserRole.farmer && _currentFarmer.id.isEmpty) {
      return;
    }
    isLoadingOffers = true;
    notifyListeners();

    try {
      final token = await SharedPrefHelper.getToken();
      final farmerId = _currentFarmer.id;
      final res = await ApiClient.fetchMyOffers(
        token: token.isNotEmpty ? token : null,
        farmerId: farmerId.isNotEmpty ? farmerId : null,
      );
      if (res['success'] == true && res['data'] is List) {
        final List list = res['data'];
        final List<FarmerOffer> backendOffers = list.map((item) {
          return FarmerOffer.fromBackendMap(item);
        }).toList();

        for (var o in backendOffers) {
          _offers.removeWhere((item) => item.id == o.id);
          _offers.add(o);
        }
      }
    } catch (e) {
      debugPrint('Error fetching offers from backend: $e');
    } finally {
      isLoadingOffers = false;
      notifyListeners();
    }
  }

  Timer? _periodicSyncTimer;

  void startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final isLoggedIn = await SharedPrefHelper.isLoggedIn();
      if (isLoggedIn) {
        loadProfileFromBackend();
        fetchProductsFromBackend();
        fetchDemandsFromBackend();
        fetchMyOffersFromBackend();
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
    fetchProductsFromBackend();
    fetchDemandsFromBackend();
    fetchMyOffersFromBackend();
    startPeriodicSync();
  }

  void _initData() {
    _farmers = [];
    _currentFarmer = FarmerProfile(
      id: '',
      name: '',
      phone: '',
      district: '',
      upazila: '',
      union: '',
      address: '',
      farmerType: '',
    );

    _buyers = [];
    _currentBuyer = BuyerProfile(
      id: '',
      name: '',
      phone: '',
      businessName: '',
      businessType: '',
      district: '',
      area: '',
      address: '',
    );

    _products = [];
    _demands = [];
    _offers = [];
    _orders = [];
    _notifications = [];
    _chatMessages = [];
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

  void openDemandDetail(BuyerDemand demand) {
    activeDemandForDetail = demand;
    notifyListeners();
  }

  void closeDemandDetail() {
    activeDemandForDetail = null;
    notifyListeners();
  }

  void openOfferDialog(BuyerDemand demand) {
    activeDemandForDetail = null;
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

  void addNewProduct(ProductListing product) {
    _products.removeWhere((p) => p.id == product.id);
    _products.insert(0, product);
    _currentFarmer = _currentFarmer.copyWith(
      productsCount: _currentFarmer.productsCount + 1,
    );
    closeAddProductDialog();
    snackbarMessage = StaticString.productAddedSuccess;
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
    List<String> imageUrls = const [],
    String? videoUrl,
    String? videoNote,
    String? productId,
  }) {
    final newProduct = ProductListing(
      id: productId ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
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
      imageUrls: imageUrls.isNotEmpty
          ? imageUrls
          : [
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
            ],
      videoUrl: videoUrl,
      videoNote: videoNote,
      createdAt: 'এখনই',
    );
    addNewProduct(newProduct);
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    snackbarMessage = StaticString.productDeletedSuccess;
    notifyListeners();
  }

  Future<bool> submitDemand(
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
  ) async {
    final token = await SharedPrefHelper.getToken();
    final currentUserId = _currentBuyer.id;

    final body = {
      "product_title": title,
      "category": cat.labelBn,
      "required_quantity": qty,
      "unit": unit.labelBn,
      "required_location": loc,
      "required_date": reqDate,
      "min_expected_price": minP,
      "max_expected_price": maxP,
      "quality_grade": grade.labelBn,
      "additional_note": note.trim().isNotEmpty ? note.trim() : null,
    };

    final res = await ApiClient.createDemand(
      body,
      token: token.isNotEmpty ? token : null,
      userId: currentUserId.isNotEmpty ? currentUserId : null,
    );

    BuyerDemand newDemand;
    if (res['success'] == true && res['data'] is Map<String, dynamic>) {
      newDemand = BuyerDemand.fromBackendMap(res['data']);
    } else {
      newDemand = BuyerDemand(
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
    }

    _demands.insert(0, newDemand);
    closeAddDemandDialog();
    snackbarMessage = StaticString.demandAddedSuccess;
    notifyListeners();
    fetchDemandsFromBackend();
    return res['success'] == true;
  }

  Future<bool> deleteDemand(String demandId) async {
    final token = await SharedPrefHelper.getToken();
    final res = await ApiClient.deleteDemand(
      demandId,
      token: token.isNotEmpty ? token : null,
      userId: _currentBuyer.id.isNotEmpty ? _currentBuyer.id : null,
    );
    _demands.removeWhere((d) => d.id == demandId);
    snackbarMessage = "চাহিদা সফলভাবে মুছে ফেলা হয়েছে!";
    notifyListeners();
    return res['success'] == true;
  }

  Future<bool> submitOffer(
    String demandId,
    double qty,
    ProductUnit unit,
    double price,
    QualityGrade grade,
    String date,
    String note,
  ) async {
    final token = await SharedPrefHelper.getToken();
    final currentUserId = _currentFarmer.id;

    final body = {
      "demand_id": demandId,
      "farmer_id": currentUserId.isNotEmpty ? currentUserId : null,
      "farmer_name": _currentFarmer.name.isNotEmpty ? _currentFarmer.name : "কৃষক",
      "farmer_phone": _currentFarmer.phone.isNotEmpty ? _currentFarmer.phone : "০১৭০০০০০০০০",
      "farmer_location": _currentFarmer.district.isNotEmpty ? _currentFarmer.district : "বাংলাদেশ",
      "farmer_verified": _currentFarmer.isVerified,
      "offered_quantity": qty,
      "unit": unit.labelBn,
      "price_per_unit": price,
      "quality_grade": grade.labelBn,
      "available_date": date,
      "note": note.trim(),
    };

    final res = await ApiClient.createOffer(
      body,
      token: token.isNotEmpty ? token : null,
      farmerId: currentUserId.isNotEmpty ? currentUserId : null,
    );

    FarmerOffer newOffer;
    if (res['success'] == true && res['data'] is Map<String, dynamic>) {
      newOffer = FarmerOffer.fromBackendMap(res['data']);
    } else {
      newOffer = FarmerOffer(
        id: 'off_${DateTime.now().millisecondsSinceEpoch}',
        demandId: demandId,
        farmerId: _currentFarmer.id,
        farmerName: _currentFarmer.name,
        farmerPhone: _currentFarmer.phone,
        farmerLocation: _currentFarmer.district,
        farmerVerified: _currentFarmer.isVerified,
        offeredQuantity: qty,
        unit: unit,
        pricePerUnit: price,
        qualityGrade: grade,
        availableDate: date,
        note: note,
        createdAt: 'এখনই',
      );
    }

    _offers.removeWhere((o) => o.id == newOffer.id);
    _offers.insert(0, newOffer);

    // Update local demand offersCount if present
    final dIdx = _demands.indexWhere((d) => d.id == demandId);
    if (dIdx != -1) {
      final oldD = _demands[dIdx];
      _demands[dIdx] = BuyerDemand(
        id: oldD.id,
        buyerId: oldD.buyerId,
        buyerName: oldD.buyerName,
        buyerBusinessName: oldD.buyerBusinessName,
        buyerDistrict: oldD.buyerDistrict,
        buyerVerified: oldD.buyerVerified,
        buyerPhotoUrl: oldD.buyerPhotoUrl,
        buyerPhone: oldD.buyerPhone,
        productTitle: oldD.productTitle,
        category: oldD.category,
        requiredQuantity: oldD.requiredQuantity,
        fulfilledQuantity: oldD.fulfilledQuantity,
        unit: oldD.unit,
        requiredLocation: oldD.requiredLocation,
        requiredDate: oldD.requiredDate,
        minExpectedPrice: oldD.minExpectedPrice,
        maxExpectedPrice: oldD.maxExpectedPrice,
        qualityGrade: oldD.qualityGrade,
        additionalNote: oldD.additionalNote,
        status: oldD.status,
        offersCount: oldD.offersCount + 1,
        createdAt: oldD.createdAt,
      );
    }

    closeOfferDialog();
    snackbarMessage = res['message'] ?? StaticString.offerSentSuccess;
    notifyListeners();
    fetchDemandsFromBackend();
    return res['success'] == true;
  }

  Future<List<FarmerOffer>> fetchOffersForDemand(String demandId) async {
    try {
      final res = await ApiClient.fetchOffersForDemand(demandId);
      if (res['success'] == true && res['data'] is List) {
        final List list = res['data'];
        final fetched = list.map((item) => FarmerOffer.fromBackendMap(item)).toList();
        for (var o in fetched) {
          _offers.removeWhere((existing) => existing.id == o.id);
          _offers.add(o);
        }
        notifyListeners();
        return fetched;
      }
    } catch (e) {
      debugPrint('Error fetching offers for demand $demandId: $e');
    }
    return _offers.where((o) => o.demandId == demandId).toList();
  }

  Future<bool> acceptOffer(String offerId) async {
    final token = await SharedPrefHelper.getToken();
    final buyerId = _currentBuyer.id;

    final offerIndex = _offers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) return false;
    final offer = _offers[offerIndex];
    final demandIndex = _demands.indexWhere((d) => d.id == offer.demandId);
    final demand = demandIndex != -1 ? _demands[demandIndex] : null;

    final res = await ApiClient.acceptOffer(
      offerId,
      token: token.isNotEmpty ? token : null,
      buyerId: buyerId.isNotEmpty ? buyerId : null,
    );

    final totalAmt = offer.offeredQuantity * offer.pricePerUnit;
    final deposit = totalAmt * 0.20;

    final newOrder = MarketplaceOrder(
      id: (res['data'] is Map && res['data']['id'] != null)
          ? res['data']['id'].toString()
          : 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: (res['data'] is Map && res['data']['order_number'] != null)
          ? res['data']['order_number'].toString()
          : 'KB-${1000 + _orders.length + 1}',
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
      farmerVerified: offer.farmerVerified,
      farmerPhotoUrl: offer.farmerPhotoUrl,
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
    snackbarMessage = res['message'] ?? StaticString.offerAcceptedSuccess;
    notifyListeners();
    fetchDemandsFromBackend();
    return res['success'] == true;
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
