import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import 'product_detail_controller.dart';

class ProductDetailDialog extends StatelessWidget {
  final ProductListing product;

  const ProductDetailDialog({super.key, required this.product});

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
    // Fetch latest state of product from repository
    final currentProduct = repo.products.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );
    final controller = ProductDetailController(repo, currentProduct);
    final isFarmer = controller.currentRole == UserRole.farmer;

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: controller.close,
          ),
          title: Text(
            currentProduct.title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF166534)),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Media Section (Image Gallery + Video Preview Box)
              _buildMediaGallery(context, controller, currentProduct),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Title & Status Row
                    _buildTitleHeader(currentProduct),
                    const SizedBox(height: 14),

                    // 3. Price & Stock Card
                    _buildPriceStockCard(currentProduct),
                    const SizedBox(height: 14),

                    // 4. Product Details Specification Card
                    _buildSpecificationCard(currentProduct),
                    const SizedBox(height: 14),

                    // 5. Farmer Profile Info Card
                    _buildFarmerInfoCard(currentProduct),
                    const SizedBox(height: 14),

                    // 6. Detailed Description Card
                    _buildDescriptionCard(currentProduct),
                    const SizedBox(height: 24),

                    // 7. Bottom Action Buttons
                    if (isFarmer) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.deleteProduct,
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          label: const Text(
                            'লিস্টিং পণ্য মুছুন',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.call, color: Color(0xFF166534)),
                              label: const Text(
                                'কল করুন',
                                style: TextStyle(
                                  color: Color(0xFF166534),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFF166534)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: controller.sendOffer,
                              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                              label: const Text(
                                'ক্রয় প্রস্তাব দিন',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper 1: Media Gallery (Image Carousel & Video Player Preview) ---
  Widget _buildMediaGallery(
    BuildContext context,
    ProductDetailController controller,
    ProductListing currentProduct,
  ) {
    final hasImages = currentProduct.imageUrls.isNotEmpty;
    final hasVideo = currentProduct.videoUrl != null;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Main Display Area (Image or Video)
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Stack(
              children: [
                if (controller.isPlayingVideo && hasVideo)
                  Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_fill, color: Color(0xFFEA580C), size: 64),
                          const SizedBox(height: 12),
                          const Text(
                            'ক্ষেতের ভিডিও চালিত হচ্ছে... 🎬',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: controller.togglePlayVideo,
                            icon: const Icon(Icons.pause, color: Colors.white),
                            label: const Text('ভিডিও থামান'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (hasImages)
                  Image.network(
                    currentProduct.imageUrls[controller.selectedMediaIndex.clamp(0, currentProduct.imageUrls.length - 1)],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 240,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                      ),
                    ),
                  )
                else
                  Container(
                    color: const Color(0xFF1E293B),
                    child: Center(
                      child: Text(
                        currentProduct.category.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),

                // Top Left Category Overlay Tag
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(currentProduct.category.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          currentProduct.category.labelBn,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Media Selector Strip (Image Thumbnails & Field Video Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1E293B),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Images List
                  ...currentProduct.imageUrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    final isSelected = !controller.isPlayingVideo && controller.selectedMediaIndex == index;

                    return GestureDetector(
                      onTap: () => controller.setMediaIndex(index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 60,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFEA580C) : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            color: Colors.black54,
                            child: Text(
                              '📸 ${_toBnDigits(index + 1)}',
                              style: const TextStyle(color: Colors.white, fontSize: 9),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Field Video Thumbnail Card
                  if (hasVideo)
                    GestureDetector(
                      onTap: controller.togglePlayVideo,
                      child: Container(
                        width: 130,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: controller.isPlayingVideo ? const Color(0xFFEA580C) : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.isPlayingVideo ? Colors.white : const Color(0xFF475569),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFFEA580C),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ক্ষেতের ভিডিও 🎬',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'প্লে করতে চাপুন',
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 2: Title Header Box ---
  Widget _buildTitleHeader(ProductListing currentProduct) {
    final isPending = currentProduct.status == ProductStatus.pending;
    final isSold = currentProduct.status == ProductStatus.sold;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentProduct.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    currentProduct.location,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPending
                ? const Color(0xFFFFF7ED)
                : (isSold ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isPending
                ? 'পর্যালোচনায় (Pending)'
                : (isSold ? 'বিক্রিত (Sold)' : 'সক্রিয় (Active)'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPending
                  ? const Color(0xFFEA580C)
                  : (isSold ? const Color(0xFF475569) : const Color(0xFF166534)),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper 3: Price & Stock Card ---
  Widget _buildPriceStockCard(ProductListing currentProduct) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'প্রত্যাশিত বিক্রয় মূল্য:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '৳${_toBnDigits(currentProduct.expectedPrice.toInt())} / ${currentProduct.unit.labelBn}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5EC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'সর্বনিম্ন গ্রহণীয় দর:',
                      style: TextStyle(fontSize: 10, color: Color(0xFF166534)),
                    ),
                    Text(
                      '৳${_toBnDigits(currentProduct.minPrice.toInt())}/${currentProduct.unit.labelBn}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockColumn(
                'মোট পরিমাণ',
                '${_toBnDigits(currentProduct.quantity.toInt())} ${currentProduct.unit.labelBn}',
                const Color(0xFF0F172A),
              ),
              _buildStockColumn(
                'অবশিষ্ট মজুত',
                '${_toBnDigits(currentProduct.remainingQuantity.toInt())} ${currentProduct.unit.labelBn}',
                const Color(0xFF166534),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // --- Helper 4: Specifications Card ---
  Widget _buildSpecificationCard(ProductListing currentProduct) {
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
            'পণ্যের বিস্তারিত তথ্য 📋',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('ক্যাটাগরি:', '${currentProduct.category.icon} ${currentProduct.category.labelBn}'),
          const SizedBox(height: 6),
          _buildSpecRow('গুণমান গ্রেড:', currentProduct.qualityGrade.labelBn, isBold: true),
          const SizedBox(height: 6),
          _buildSpecRow('ফসল তোলার সময়:', currentProduct.harvestDate),
          const SizedBox(height: 6),
          _buildSpecRow('সরবরাহের তারিখ:', currentProduct.availableDate),
          const SizedBox(height: 6),
          _buildSpecRow('সংগ্রহ এলাকা:', currentProduct.location),
          const SizedBox(height: 6),
          _buildSpecRow('তালিকাভুক্তির সময়:', currentProduct.createdAt),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // --- Helper 5: Farmer Info Card ---
  Widget _buildFarmerInfoCard(ProductListing currentProduct) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currentProduct.farmerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Color(0xFF166534), size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'ভেরিফাইড কৃষক • ${currentProduct.farmerDistrict}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper 6: Description Card ---
  Widget _buildDescriptionCard(ProductListing currentProduct) {
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
            'বিবরণ ও বিশেষ দ্রষ্টব্য 📝',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentProduct.description.isNotEmpty
                ? currentProduct.description
                : 'কৃষকের নির্ধারিত এই পণ্যের সমস্ত গুণগত মান ও ছবি কালেকশন পয়েন্ট ইনস্পেক্টর দ্বারা সত্যতা যাচাইকৃত।',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
