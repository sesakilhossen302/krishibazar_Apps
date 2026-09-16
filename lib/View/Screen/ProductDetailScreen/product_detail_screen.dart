import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../global/Model/krishi_models.dart';
import '../../../global/controller/krishi_repository.dart';
import '../../../service/api_url.dart';
import '../../Widgegt/app_media_image.dart';
import '../ProductOffersScreen/product_offers_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductListing product;
  final VoidCallback? onBack;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onBack,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  bool _isPlaying = false;
  bool _isMuted = false;

  ProductOffer? _myOffer;
  bool _isLoadingMyOffer = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyOffer();
    });
  }

  Future<void> _fetchMyOffer() async {
    final repo = context.read<KrishiRepository>();
    if (repo.currentRole == UserRole.buyer) {
      final cached = repo.getCachedOfferForProduct(widget.product.id);
      if (cached != null && mounted) {
        setState(() => _myOffer = cached);
      }
      setState(() => _isLoadingMyOffer = true);
      final offer = await repo.fetchMyOfferForProduct(widget.product.id);
      if (mounted) {
        setState(() {
          _myOffer = offer ?? _myOffer;
          _isLoadingMyOffer = false;
        });
      }
    }
  }

  void _initVideoPlayer() {
    final videoUrl = widget.product.videoUrl;
    if (videoUrl == null || videoUrl.trim().isEmpty) return;

    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _isVideoError = false;

    try {
      final raw = videoUrl.trim();
      final isLocal = !kIsWeb && _isLocalFilePath(raw) && File(raw).existsSync();

      if (isLocal) {
        _videoController = VideoPlayerController.file(
          File(raw),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        final formattedUrl = ApiUrl.formatMediaUrl(raw);
        debugPrint('🎬 [ProductDetailScreen] Initializing video: $formattedUrl');
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(formattedUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      _videoController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isVideoError = false;
          });
        }
      }).catchError((error) {
        debugPrint('⚠️ [Video Player Error]: $error');
        if (mounted) {
          setState(() {
            _isVideoError = true;
          });
        }
      });

      _videoController!.addListener(() {
        if (mounted) {
          final isPlaying = _videoController!.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        }
      });
    } catch (e) {
      debugPrint('Error creating video controller: $e');
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  bool _isLocalFilePath(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('/uploads/') ||
        path.startsWith('uploads/')) {
      return false;
    }
    return path.startsWith('/') || path.contains(':\\') || path.contains(':/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  void _toggleMute() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _toBnDigits(dynamic input) {
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final str = input.toString();
    final sb = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      final digit = int.tryParse(char);
      if (digit != null) {
        sb.write(bnDigits[digit]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final isFarmer = repo.currentRole == UserRole.farmer;
    final product = widget.product;
    final images = product.imageUrls;
    final hasVideo = product.videoUrl != null && product.videoUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.read<KrishiRepository>().closeProductDetail();
            }
          },
        ),
        title: Text(
          product.title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF166534)),
            tooltip: 'শেয়ার করুন',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("✓ '${product.title}' এর লিংক কপি করা হয়েছে!"),
                  backgroundColor: const Color(0xFF166534),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          if (isFarmer) ...[
            IconButton(
              icon: Badge(
                label: Text('${product.offersCount}'),
                isLabelVisible: product.offersCount > 0,
                backgroundColor: const Color(0xFFEA580C),
                child: const Icon(Icons.inbox_rounded, color: Color(0xFF166534)),
              ),
              tooltip: 'প্রাপ্ত ক্রয় প্রস্তাবসমূহ',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductOffersScreen(product: product)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'লিস্টিং মুছুন',
              onPressed: () => _confirmDelete(context, repo, product),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Media Carousel (All Images)
            _buildImageCarousel(images, product.category.icon),

            // 2. Video Player Section (If video exists)
            if (hasVideo) _buildVideoPlayerSection(product),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Header & Status Card
                  _buildHeaderCard(product),
                  const SizedBox(height: 14),

                  // 4. Pricing & Stock Card
                  _buildPricingCard(product),
                  const SizedBox(height: 14),

                  // 5. Timeline & Location Card
                  _buildTimelineAndLocationCard(product),
                  const SizedBox(height: 14),

                  // 6. Farmer Information Card
                  _buildFarmerCard(product),
                  const SizedBox(height: 14),

                  // 7. Product Description Card
                  _buildDescriptionCard(product),
                  const SizedBox(height: 24),

                  // 8. Bottom Action Buttons
                  _buildActionButtons(context, repo, isFarmer, product),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Image Carousel ---
  Widget _buildImageCarousel(List<String> images, String emoji) {
    if (images.isEmpty) {
      return Container(
        height: 240,
        width: double.infinity,
        color: const Color(0xFFDCFCE7),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 72)),
        ),
      );
    }

    return Container(
      height: 260,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imgUrl = images[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, imgUrl, emoji),
                child: Hero(
                  tag: 'product_img_${imgUrl}_$index',
                  child: AppMediaImage(
                    url: imgUrl,
                    fit: BoxFit.contain,
                    fallbackEmoji: emoji,
                  ),
                ),
              );
            },
          ),

          // Pagination Dots & Counter Badge
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_toBnDigits(_currentImageIndex + 1)} / ${_toBnDigits(images.length)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tap to Zoom hint badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'জুম করুন',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Video Player Section ---
  Widget _buildVideoPlayerSection(ProductListing product) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                Icon(Icons.videocam_rounded, color: Color(0xFFEA580C), size: 20),
                SizedBox(width: 8),
                Text(
                  'ফসলের লাইভ ভিডিও প্রমাণ 🎬',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  'তাজা ক্ষেতের ভিডিও',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),

          // Video View Area
          SizedBox(
            height: 220,
            width: double.infinity,
            child: _isVideoInitialized && _videoController != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio > 0
                              ? _videoController!.value.aspectRatio
                              : 16 / 9,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),

                      // Big Play Button Overlay
                      if (!_isPlaying)
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                          ),
                        ),

                      // Bottom Video Controls Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                              Expanded(
                                child: VideoProgressIndicator(
                                  _videoController!,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: Color(0xFFEA580C),
                                    bufferedColor: Colors.white30,
                                    backgroundColor: Colors.white12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: _videoController!,
                                builder: (context, VideoPlayerValue value, child) {
                                  return Text(
                                    '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: _toggleMute,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _isVideoError
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              'ভিডিও লোড হতে সমস্যা হয়েছে',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isVideoError = false;
                                  _initVideoPlayer();
                                });
                              },
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                              label: const Text('পুনরায় চেষ্টা করুন', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEA580C),
                          strokeWidth: 2.5,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // --- 3. Header & Status Card ---
  Widget _buildHeaderCard(ProductListing product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.category.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ক্যাটাগরি: ${product.category.labelBn}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                label: product.qualityGrade.labelBn,
                bgColor: const Color(0xFFFEF3C7),
                textColor: const Color(0xFF92400E),
                icon: Icons.verified_outlined,
              ),
              _buildBadge(
                label: product.status.labelBn,
                bgColor: const Color(0xFFDCFCE7),
                textColor: const Color(0xFF166534),
                icon: Icons.check_circle_outline,
              ),
              _buildBadge(
                label: product.unit.labelBn,
                bgColor: const Color(0xFFEFF6FF),
                textColor: const Color(0xFF1E40AF),
                icon: Icons.scale_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. Pricing & Stock Card ---
  Widget _buildPricingCard(ProductListing product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'মূল্য ও মজুত বিবরণী:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'কাঙ্ক্ষিত দর',
                        style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${_toBnDigits(product.expectedPrice.toInt())}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                      Text(
                        'প্রতি ${product.unit.labelBn}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'সর্বনিম্ন দর',
                        style: TextStyle(fontSize: 11, color: Color(0xFF9A3412)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${_toBnDigits(product.minPrice.toInt())}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      Text(
                        'প্রতি ${product.unit.labelBn}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFC2410C)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট মজুত:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text(
                      '${_toBnDigits(product.quantity.toInt())} ${product.unit.labelBn}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('অবশিষ্ট মজুত:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text(
                      '${_toBnDigits(product.remainingQuantity.toInt())} ${product.unit.labelBn}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Timeline & Location Card ---
  Widget _buildTimelineAndLocationCard(ProductListing product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'লোকেশন ও সময়সূচী:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.location_on,
            iconColor: const Color(0xFFEA580C),
            title: 'খামারের অবস্থান / ডেলিভারি পয়েন্ট:',
            value: product.location.isNotEmpty ? product.location : 'নির্দিষ্ট করা হয়নি',
          ),
          const Divider(height: 18),
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: const Color(0xFF166534),
            title: 'ফসল তোলার তারিখ:',
            value: product.harvestDate.isNotEmpty ? product.harvestDate : 'সরাসরি ক্ষেত থেকে',
          ),
          const Divider(height: 18),
          _buildInfoRow(
            icon: Icons.local_shipping_outlined,
            iconColor: const Color(0xFF2563EB),
            title: 'ডেলিভারির তারিখ:',
            value: product.availableDate.isNotEmpty ? product.availableDate : 'তাত্ক্ষণিক',
          ),
        ],
      ),
    );
  }

  // --- 6. Farmer Information Card ---
  Widget _buildFarmerCard(ProductListing product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কৃষক প্রোফাইল তথ্য:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFDCFCE7),
                child: const Icon(Icons.person, color: Color(0xFF166534), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.farmerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (product.farmerVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Color(0xFF166534), size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'জেলা: ${product.farmerDistrict}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 2),
                    Text(
                      '৫.০',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 7. Product Description Card ---
  Widget _buildDescriptionCard(ProductListing product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'পণ্যের বিস্তারিত বিবরণ:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'এই পণ্যের জন্য অতিরিক্ত কোনো বিবরণ দেওয়া হয়নি। সরাসরি ক্ষেতের তাজা ফসল।',
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. Bottom Action Buttons ---
  Widget _buildActionButtons(
    BuildContext context,
    KrishiRepository repo,
    bool isFarmer,
    ProductListing product,
  ) {
    if (isFarmer) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, repo, product),
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              label: const Text(
                'মুছে ফেলুন',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductOffersScreen(product: product)),
                );
              },
              icon: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
              label: Text(
                'প্রাপ্ত ক্রয় প্রস্তাব (${product.offersCount > 0 ? _toBnDigits(product.offersCount) : "০"}টি)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }

    // Buyer (Paikar) Actions
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("কল করা হচ্ছে: ${product.farmerName}"),
                  backgroundColor: const Color(0xFF166534),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.call, color: Color(0xFF166534)),
            label: const Text(
              'কল করুন',
              style: TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFF166534), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildBuyerOfferButton(context, repo, product),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imgUrl, String emoji) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: AppMediaImage(
                  url: imgUrl,
                  fit: BoxFit.contain,
                  fallbackEmoji: emoji,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfferBottomSheet(BuildContext context, ProductListing product) {
    final repo = context.read<KrishiRepository>();
    final offerPriceController = TextEditingController(text: product.expectedPrice.toStringAsFixed(0));
    final offerQtyController = TextEditingController(
      text: (product.remainingQuantity > 0 ? product.remainingQuantity : product.quantity).toStringAsFixed(0),
    );
    final locationController = TextEditingController(
      text: repo.currentBuyer.district.isNotEmpty ? repo.currentBuyer.district : 'ঢাকা',
    );
    final noteController = TextEditingController();
    DateTime? selectedDate = DateTime.now().add(const Duration(days: 2));
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final qty = double.tryParse(offerQtyController.text.trim()) ?? 0.0;
            final price = double.tryParse(offerPriceController.text.trim()) ?? 0.0;
            final totalAmount = qty * price;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ক্রয় প্রস্তাব পাঠান (Purchase Offer)',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  product.title,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Expected Price & Stock Reference Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('কাঙ্ক্ষিত দর', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(
                                  '৳${_toBnDigits(product.expectedPrice.toStringAsFixed(0))}/${product.unit.labelBn}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                            Column(
                              children: [
                                const Text('সর্বনিম্ন দর', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(
                                  '৳${_toBnDigits(product.minPrice.toStringAsFixed(0))}/${product.unit.labelBn}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                            Column(
                              children: [
                                const Text('অবশিষ্ট মজুত', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(
                                  '${_toBnDigits((product.remainingQuantity > 0 ? product.remainingQuantity : product.quantity).toStringAsFixed(0))} ${product.unit.labelBn}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quantity Input
                      TextField(
                        controller: offerQtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'প্রস্তাবিত পরিমাণ (${product.unit.labelBn}) *',
                          hintText: 'যেমন: ৫০০',
                          prefixIcon: const Icon(Icons.scale_rounded, color: Color(0xFF166534), size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price Input
                      TextField(
                        controller: offerPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'আপনার প্রস্তাবিত দর (৳ প্রতি ${product.unit.labelBn}) *',
                          hintText: 'যেমন: ৪২',
                          prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFFEA580C), size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Quick Suggestion Chips for Price
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: Text('কাঙ্ক্ষিত: ৳${product.expectedPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5)),
                            backgroundColor: const Color(0xFFF1F8F3),
                            onPressed: () {
                              offerPriceController.text = product.expectedPrice.toStringAsFixed(0);
                              setModalState(() {});
                            },
                          ),
                          ActionChip(
                            label: Text('সর্বনিম্ন: ৳${product.minPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5)),
                            backgroundColor: const Color(0xFFFFF7ED),
                            onPressed: () {
                              offerPriceController.text = product.minPrice.toStringAsFixed(0);
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Total Calculation Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8F3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'সর্বমোট সম্ভাব্য মূল্য:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                            ),
                            Text(
                              '৳${_toBnDigits(totalAmount.toStringAsFixed(0))}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Delivery Date Picker
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 2)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF166534)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedDate != null
                                      ? 'ডেলিভারি তারিখ: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                      : 'ডেলিভারি গ্রহণের তারিখ নির্ধারণ করুন',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Delivery Location Input
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'ডেলিভারির স্থান / আরত / বাজার',
                          hintText: 'যেমন: কারওয়ান বাজার, ঢাকা',
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Note Input
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'অতিরিক্ত নোট (ঐচ্ছিক)',
                          hintText: 'গ্রেড ও পরিবহন সম্পর্কিত বিশেষ কোনো শর্ত থাকলে লিখুন...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final q = double.tryParse(offerQtyController.text.trim()) ?? 0.0;
                                  final p = double.tryParse(offerPriceController.text.trim()) ?? 0.0;

                                  if (q <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('অনুগ্রহ করে সঠিক পরিমাণ দিন।')),
                                    );
                                    return;
                                  }
                                  if (p <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('অনুগ্রহ করে সঠিক প্রস্তাবিত দর দিন।')),
                                    );
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);

                                  final dateStr = selectedDate != null
                                      ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                      : "";

                                  final ok = await repo.submitProductOffer(
                                    productId: product.id,
                                    qty: q,
                                    unit: product.unit,
                                    price: p,
                                    deliveryLocation: locationController.text.trim(),
                                    expectedDeliveryDate: dateStr,
                                    note: noteController.text.trim(),
                                  );

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }

                                  if (context.mounted) {
                                    if (ok) {
                                      _fetchMyOffer();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('✓ আপনার ক্রয় প্রস্তাব সফলভাবে কৃষকের নিকট পাঠানো হয়েছে!'),
                                          backgroundColor: Color(0xFF166534),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('❌ প্রস্তাব পাঠাতে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'প্রস্তাব নিশ্চিত করুন',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBuyerOfferButton(
    BuildContext context,
    KrishiRepository repo,
    ProductListing product,
  ) {
    final myOffer = _myOffer ?? repo.getCachedOfferForProduct(product.id);

    if (_isLoadingMyOffer && myOffer == null) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF64748B)),
        ),
      );
    }

    if (myOffer != null) {
      if (myOffer.status == OfferStatus.accepted) {
        return ElevatedButton.icon(
          onPressed: () => _showMyOfferDetailsSheet(context, myOffer, product),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          label: const Text(
            'গৃহীত প্রস্তাব (Accepted ✅)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF166534),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (myOffer.status == OfferStatus.rejected) {
        return ElevatedButton.icon(
          onPressed: () => _showMyOfferDetailsSheet(context, myOffer, product),
          icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 18),
          label: const Text(
            'প্রস্তাব বাতিল (Rejected ❌)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        // Pending
        return ElevatedButton.icon(
          onPressed: () => _showMyOfferDetailsSheet(context, myOffer, product),
          icon: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 18),
          label: const Text(
            'প্রস্তাব দেওয়া হয়েছে (বিবেচনায়)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    // No offer yet
    return ElevatedButton.icon(
      onPressed: () => _showOfferBottomSheet(context, product),
      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
      label: const Text(
        'ক্রয় প্রস্তাব দিন',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA580C),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMyOfferDetailsSheet(
    BuildContext context,
    ProductOffer offer,
    ProductListing product,
  ) {
    final totalAmount = offer.offeredQuantity * offer.pricePerUnit;
    final isAccepted = offer.status == OfferStatus.accepted;
    final isRejected = offer.status == OfferStatus.rejected;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'আপনার প্রেরিত ক্রয় প্রস্তাব',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Highlight Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? const Color(0xFFDCFCE7)
                        : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAccepted
                          ? const Color(0xFF86EFAC)
                          : (isRejected ? const Color(0xFFFCA5A5) : const Color(0xFFFCD34D)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isAccepted
                            ? Icons.check_circle_rounded
                            : (isRejected ? Icons.cancel_rounded : Icons.hourglass_top_rounded),
                        color: isAccepted
                            ? const Color(0xFF15803D)
                            : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFB45309)),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAccepted
                                  ? 'প্রস্তাব গৃহীত হয়েছে! (Accepted ✅)'
                                  : (isRejected
                                      ? 'প্রস্তাবটি বাতিল করা হয়েছে (Rejected ❌)'
                                      : 'কৃষকের বিবেচনার অপেক্ষায় রয়েছে ⏳'),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isAccepted
                                    ? const Color(0xFF15803D)
                                    : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFB45309)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAccepted
                                  ? 'কৃষক ${product.farmerName} আপনার ক্রয় প্রস্তাবটি গ্রহণ করেছেন। অবিলম্বে ডেলিভারি ও লেনদেনের বিষয় চূড়ান্ত করতে কৃষকের সাথে কথা বলুন।'
                                  : (isRejected
                                      ? 'কৃষক ${product.farmerName} এই মুহূর্তে আপনার প্রস্তাবটি গ্রহণ করতে পারছেন না।'
                                      : 'আপনার ক্রয় প্রস্তাবটি কৃষক ${product.farmerName}-এর নিকট পৌঁছেছে। কৃষক অনুমোদন দিলে সাথে সাথে আপডেট পেয়ে যাবেন।'),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isAccepted
                                    ? const Color(0xFF166534)
                                    : (isRejected ? const Color(0xFF991B1B) : const Color(0xFF92400E)),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3-Column Metrics Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // 1. Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'প্রস্তাবিত পরিমাণ',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_toBnDigits(offer.offeredQuantity.toStringAsFixed(0))} ${offer.unit.labelBn}',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                      // 2. Unit Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'আপনার প্রস্তাবিত দর',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${_toBnDigits(offer.pricePerUnit.toStringAsFixed(0))} /${offer.unit.labelBn}',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                            ),
                          ],
                        ),
                      ),
                      // 3. Total
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'সর্বমোট মূল্য',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${_toBnDigits(totalAmount.toStringAsFixed(0))}',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details List
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('পণ্য', product.title),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildDetailRow('কৃষক', '${product.farmerName} (${product.farmerDistrict})'),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildDetailRow('কৃষকের কাঙ্ক্ষিত দর', '৳${_toBnDigits(product.expectedPrice.toStringAsFixed(0))} /${product.unit.labelBn}'),
                      if (offer.expectedDeliveryDate.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildDetailRow('ডেলিভারির তারিখ', _toBnDigits(offer.expectedDeliveryDate)),
                      ],
                      if (offer.deliveryLocation.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildDetailRow('ডেলিভারি স্থান', offer.deliveryLocation),
                      ],
                      if (offer.note.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildDetailRow('আপনার নোট', offer.note),
                      ],
                      if (offer.createdAt.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildDetailRow('প্রস্তাব প্রেরণের সময়', _toBnDigits(offer.createdAt)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('বন্ধ করুন', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('কল করা হচ্ছে: ${product.farmerName}'),
                              backgroundColor: const Color(0xFF166534),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.call, color: Colors.white, size: 18),
                        label: const Text(
                          'কৃষককে কল করুন',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, KrishiRepository repo, ProductListing product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('লিস্টিং মুছে ফেলতে চান?'),
        content: Text("'${product.title}' পণ্যটি বাজার থেকে সরিয়ে নেওয়া হবে।"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close details page
              repo.deleteProduct(product.id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
