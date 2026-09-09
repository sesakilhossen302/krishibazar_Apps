import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/app_media_image.dart';
import '../../ProductDetailScreen/product_detail_screen.dart';
import 'farmer_products_controller.dart';

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

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
    return ChangeNotifierProvider(
      create: (_) => FarmerProductsController(repo),
      child: Consumer<FarmerProductsController>(
        builder: (context, controller, child) {
          final displayProducts = controller.filteredProducts;

          return Scaffold(
            backgroundColor: const Color(0xFFF4F7F4),
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'আমার লিস্টিং করা পণ্য (${_toBnDigits(controller.allMyProducts.length)} টি)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Color(0xFF166534)),
                                tooltip: 'রিফ্রেশ করুন',
                                onPressed: controller.refreshFromBackend,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Horizontal Filter Tabs
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                controller.filterOptions.length,
                                (index) {
                                  final isSelected = controller.selectedFilterIndex == index;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(controller.filterOptions[index]),
                                      selected: isSelected,
                                      onSelected: (_) => controller.setFilterIndex(index),
                                      selectedColor: const Color(0xFFDCFCE7),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFF166534)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF166534)
                                            : const Color(0xFF475569),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products List Area with Pull to Refresh
                    Expanded(
                      child: displayProducts.isEmpty
                          ? RefreshIndicator(
                              color: const Color(0xFF166534),
                              onRefresh: controller.refreshFromBackend,
                              child: ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('🌾', style: TextStyle(fontSize: 48)),
                                        SizedBox(height: 12),
                                        Text(
                                          'কোনো লিস্টিং করা পণ্য পাওয়া যায়নি',
                                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: const Color(0xFF166534),
                              onRefresh: controller.refreshFromBackend,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                itemCount: displayProducts.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final product = displayProducts[index];
                                  return _buildProductCard(context, controller, product);
                                },
                              ),
                            ),
                    ),
                  ],
                ),

                // Floating Action Button at Bottom Right / Center
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: controller.openAddProduct,
                    elevation: 4,
                    backgroundColor: const Color(0xFFEA580C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 22),
                    label: const Text(
                      'নতুন পণ্য যোগ করুন',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    FarmerProductsController controller,
    ProductListing product,
  ) {
    final isPending = product.status == ProductStatus.pending;
    final isSold = product.status == ProductStatus.sold;
    final hasImages = product.imageUrls.isNotEmpty;
    final hasVideo = product.videoUrl != null && product.videoUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
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
            // Header Row inside Card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji / Icon
                Text(
                  product.category.icon,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 10),
                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ক্যাটাগরি: ${product.category.labelBn} • ${product.location}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFFFFF7ED)
                        : (isSold ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPending
                        ? 'পর্যালোচনায় (Pending)'
                        : (isSold ? 'বিক্রিত (Sold)' : 'সক্রিয় (Active)'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPending
                          ? const Color(0xFFEA580C)
                          : (isSold ? const Color(0xFF475569) : const Color(0xFF166534)),
                    ),
                  ),
                ),
              ],
            ),

            // Media Row (Image + Video Thumbnails)
            if (hasImages || hasVideo) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    // Image Thumbnail
                    if (hasImages)
                      Expanded(
                        flex: hasVideo ? 1 : 2,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: AppMediaImage(
                                url: product.imageUrls.first,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(12),
                                fallbackEmoji: product.category.icon,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.photo_camera, color: Colors.white, size: 10),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.imageUrls.length > 1
                                          ? '${_toBnDigits(product.imageUrls.length)}টি ছবি'
                                          : 'ছবি',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (hasImages && hasVideo) const SizedBox(width: 10),

                    // Video Thumbnail Card
                    if (hasVideo)
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEA580C),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'ক্ষেতের ভিডিও 🎬',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'প্লে করতে ট্যাপ করুন',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Quantities & Pricing Line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'মোট: ${_toBnDigits(product.quantity.toInt())} ${product.unit.labelBn} (অবশিষ্ট: ${_toBnDigits(product.remainingQuantity.toInt())})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'প্রত্যাশিত: ৳${_toBnDigits(product.expectedPrice.toInt())}/${product.unit.labelBn}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA580C),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Quality Grade & Harvest Date Line
            Text(
              'মান: ${product.qualityGrade.labelBn} • ফসল তোলার তারিখ: ${product.harvestDate}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Action Row inside Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Media / Details View Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_outlined, color: Color(0xFF166534), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'বিস্তারিত দেখুন',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete Button
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('পণ্যটি মুছবেন?'),
                        content: Text("'${product.title}' লিস্টিংটি স্থায়ীভাবে মুছে ফেলা হবে।"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('বাতিল'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(ctx);
                              controller.deleteProduct(product.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('পণ্যটি সফলভাবে মুছে ফেলা হয়েছে'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text(
                    'মুছুন',
                    style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
