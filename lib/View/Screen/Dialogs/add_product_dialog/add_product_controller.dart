import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../../helper/shared_pref/shared_pref_helper.dart';
import '../../../../service/api_client.dart';
import '../../../../service/location_service.dart';

class AddProductController extends ChangeNotifier {
  final KrishiRepository repository;
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final titleController = TextEditingController();
  final quantityController = TextEditingController();
  final expectedPriceController = TextEditingController();
  final minPriceController = TextEditingController();
  final locationController = TextEditingController();
  final harvestDateController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final descController = TextEditingController();

  // Form States
  ProductCategory category = ProductCategory.vegetables;
  ProductUnit unit = ProductUnit.kg;
  QualityGrade qualityGrade = QualityGrade.gradeA;

  // Media States
  final List<XFile> selectedImages = [];
  XFile? selectedVideo;
  String? videoFileName;

  // Location Autocomplete States
  List<LocationSearchResult> locationSuggestions = [];
  bool isSearchingLocation = false;
  bool showLocationSuggestions = false;
  Timer? _locationDebounceTimer;

  // Submission States
  bool isSubmitting = false;
  String submitProgressText = '';

  AddProductController(this.repository) {
    locationController.text = repository.currentFarmer.address.isNotEmpty
        ? repository.currentFarmer.address
        : (repository.currentFarmer.district.isNotEmpty
              ? '${repository.currentFarmer.upazila}, ${repository.currentFarmer.district}'
              : '');
    harvestDateController.text = '';
    deliveryDateController.text = '';
  }

  @override
  void dispose() {
    _locationDebounceTimer?.cancel();
    titleController.dispose();
    quantityController.dispose();
    expectedPriceController.dispose();
    minPriceController.dispose();
    locationController.dispose();
    harvestDateController.dispose();
    deliveryDateController.dispose();
    descController.dispose();
    super.dispose();
  }

  // ================= UNIT & PRICING LOGIC =================
  void setCategory(ProductCategory cat) {
    category = cat;
    notifyListeners();
  }

  void setUnit(ProductUnit u) {
    unit = u;
    notifyListeners();
  }

  void setQualityGrade(QualityGrade grade) {
    qualityGrade = grade;
    notifyListeners();
  }

  String get unitShortName {
    switch (unit) {
      case ProductUnit.mon:
        return 'মণ';
      case ProductUnit.ton:
        return 'টন';
      case ProductUnit.piece:
        return 'পিস';
      case ProductUnit.kg:
        return 'কেজি';
    }
  }

  String get expectedPriceLabel => '$unitShortName হিসেবে কাঙ্ক্ষিত দর (৳)';
  String get minPriceLabel => '$unitShortName হিসেবে সর্বনিম্ন দর (৳)';

  String get unitExplanationText {
    switch (unit) {
      case ProductUnit.mon:
        return '💡 আপনি "মণ (৪০ কেজি)" নির্ধারণ করেছেন। এখানে ১ মণ ফসলের দর লিখুন। ক্রেতারা প্রতি মণ হিসেবে দর দেখতে পাবেন।';
      case ProductUnit.ton:
        return '💡 আপনি "টন (১০০০ কেজি)" নির্ধারণ করেছেন। এখানে ১ টন ফসলের পাইকারি দর লিখুন।';
      case ProductUnit.piece:
        return '💡 আপনি "পিস / আঁটি" নির্ধারণ করেছেন। এখানে প্রতি ১ পিস বা আঁটির দর লিখুন।';
      case ProductUnit.kg:
        return '💡 আপনি "কেজি" নির্ধারণ করেছেন। এখানে প্রতি ১ কেজি ফসলের দর লিখুন।';
    }
  }

  // ================= LOCATION AUTOCOMPLETE =================
  void onLocationChanged(String query) {
    _locationDebounceTimer?.cancel();
    final q = query.trim();

    if (q.length < 2) {
      locationSuggestions = [];
      isSearchingLocation = false;
      showLocationSuggestions = false;
      notifyListeners();
      return;
    }

    isSearchingLocation = true;
    showLocationSuggestions = true;
    notifyListeners();

    _locationDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final results = await LocationService.searchLocations(q);
        locationSuggestions = results;
      } catch (_) {
        locationSuggestions = [];
      } finally {
        isSearchingLocation = false;
        notifyListeners();
      }
    });
  }

  void selectLocationSuggestion(LocationSearchResult result) {
    locationController.text = result.fullAddress.isNotEmpty
        ? result.fullAddress
        : (result.district.isNotEmpty
              ? '${result.title}, ${result.district}'
              : result.title);
    showLocationSuggestions = false;
    locationSuggestions = [];
    notifyListeners();
  }

  Future<void> autoDetectLocation(BuildContext context) async {
    try {
      final detected = await LocationService.getCurrentLocation();
      locationController.text = detected.fullAddress.isNotEmpty
          ? detected.fullAddress
          : '${detected.upazila}, ${detected.district}';
      showLocationSuggestions = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ জিপিএস লোকেশন সনাক্ত হয়েছে: ${detected.district}'),
            backgroundColor: const Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ লোকেশন পাওয়া যায়নি: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ================= IMAGE PICKER LOGIC =================
  /// Unlimited / multiple images from gallery
  Future<void> pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (images.isNotEmpty) {
        selectedImages.addAll(images);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  /// Take fresh photo from field camera
  Future<void> capturePhotoWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (photo != null) {
        selectedImages.add(photo);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  // ================= VIDEO PICKER LOGIC =================
  /// Pick video from gallery
  Future<void> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (video != null) {
        selectedVideo = video;
        videoFileName = video.name;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking gallery video: $e');
    }
  }

  /// Record live video directly using camera
  Future<void> recordLiveVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );
      if (video != null) {
        selectedVideo = video;
        videoFileName = video.name;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error recording live video: $e');
    }
  }

  void removeVideo() {
    selectedVideo = null;
    videoFileName = null;
    notifyListeners();
  }

  // ================= SUBMIT PRODUCT TO BACKEND =================
  Future<void> submit(BuildContext context) async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      _showWarning(context, 'অনুগ্রহ করে ফসলের নাম লিখুন!');
      return;
    }

    final quantity = double.tryParse(quantityController.text.trim()) ?? 0.0;
    if (quantity <= 0) {
      _showWarning(context, 'অনুগ্রহ করে ফসলের সঠিক পরিমাণ লিখুন!');
      return;
    }

    final expPrice =
        double.tryParse(expectedPriceController.text.trim()) ?? 0.0;
    if (expPrice <= 0) {
      _showWarning(context, 'অনুগ্রহ করে কাঙ্ক্ষিত দর (৳) লিখুন!');
      return;
    }

    final minPrice =
        double.tryParse(minPriceController.text.trim()) ?? (expPrice * 0.9);
    final location = locationController.text.trim().isNotEmpty
        ? locationController.text.trim()
        : (repository.currentFarmer.district.isNotEmpty
              ? repository.currentFarmer.district
              : 'বাংলাদেশ');

    isSubmitting = true;
    submitProgressText = 'ছবি ও ফাইল আপলোড হচ্ছে...';
    notifyListeners();

    try {
      // 1. Upload Images
      List<String> uploadedImageUrls = [];
      if (selectedImages.isNotEmpty) {
        submitProgressText = '${selectedImages.length} টি ছবি আপলোড হচ্ছে...';
        notifyListeners();

        final List<File> imageFiles = selectedImages
            .map((x) => File(x.path))
            .toList();
        final imgRes = await ApiClient.uploadMultipleImages(imageFiles);
        if (imgRes['success'] == true && imgRes['urls'] != null) {
          uploadedImageUrls = (imgRes['urls'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }

      // If no images picked, use a high quality agricultural placeholder
      if (uploadedImageUrls.isEmpty) {
        uploadedImageUrls = [
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
        ];
      }

      // 2. Upload Video
      String uploadedVideoUrl = '';
      if (selectedVideo != null) {
        submitProgressText = 'ফসলের ভিডিও আপলোড হচ্ছে...';
        notifyListeners();

        final vidRes = await ApiClient.uploadVideoFile(
          File(selectedVideo!.path),
        );
        if (vidRes['success'] == true && vidRes['url'] != null) {
          uploadedVideoUrl = vidRes['url'].toString();
        }
      }

      // 3. Post to Backend API
      submitProgressText = 'নতুন পণ্য ডাটাবেজে সংরক্ষণ করা হচ্ছে...';
      notifyListeners();

      final token = await SharedPrefHelper.getToken();
      final farmerId = repository.currentFarmer.id.isNotEmpty
          ? repository.currentFarmer.id
          : await SharedPrefHelper.getUserId();

      final apiRes = await ApiClient.createProduct(
        token: token,
        farmerId: farmerId,
        title: title,
        category: category.labelBn,
        quantity: quantity,
        unit: unit.labelBn,
        expectedPrice: expPrice,
        minPrice: minPrice,
        location: location,
        availableDate: deliveryDateController.text.trim().isNotEmpty
            ? deliveryDateController.text.trim()
            : '',
        harvestDate: harvestDateController.text.trim().isNotEmpty
            ? harvestDateController.text.trim()
            : '',
        qualityGrade: qualityGrade.labelBn,
        description: descController.text.trim(),
        images: uploadedImageUrls,
        videoUrl: uploadedVideoUrl,
        videoNote: uploadedVideoUrl.isNotEmpty ? 'ক্ষেত থেকে সরাসরি ভিডিও' : '',
      );

      if (apiRes['success'] == true && apiRes['data'] != null) {
        // Backend Success: parse and add to repository
        final createdProduct = ProductListing.fromBackendMap(apiRes['data']);
        repository.addNewProduct(createdProduct);
      } else {
        // Fallback locally
        repository.submitProduct(
          title: title,
          category: category,
          quantity: quantity,
          unit: unit,
          expectedPrice: expPrice,
          minPrice: minPrice,
          location: location,
          availableDate: deliveryDateController.text.trim().isNotEmpty
              ? deliveryDateController.text.trim()
              : '',
          harvestDate: harvestDateController.text.trim().isNotEmpty
              ? harvestDateController.text.trim()
              : '',
          qualityGrade: qualityGrade,
          description: descController.text.trim(),
          imageUrls: uploadedImageUrls,
          videoUrl: uploadedVideoUrl.isNotEmpty ? uploadedVideoUrl : null,
          videoNote: uploadedVideoUrl.isNotEmpty
              ? 'ক্ষেত থেকে সরাসরি ভিডিও'
              : null,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 নতুন পণ্য সফলভাবে যুক্ত হয়েছে!'),
            backgroundColor: Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error creating product: $e');
      // Fallback
      repository.submitProduct(
        title: title,
        category: category,
        quantity: quantity,
        unit: unit,
        expectedPrice: expPrice,
        minPrice: minPrice,
        location: location,
        availableDate: deliveryDateController.text.trim().isNotEmpty
            ? deliveryDateController.text.trim()
            : '',
        harvestDate: harvestDateController.text.trim().isNotEmpty
            ? harvestDateController.text.trim()
            : '',
        qualityGrade: qualityGrade,
        description: descController.text.trim(),
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void close() => repository.closeAddProductDialog();
}
