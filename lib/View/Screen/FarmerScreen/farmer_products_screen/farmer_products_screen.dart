import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
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
          final totalCount = controller.allMyProducts.length;
          final displayProducts = controller.filteredProducts;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Title Count & Filter Chips
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'আমার লিস্টিং করা পণ্য (${_toBnDigits(totalCount)} টি)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    // Horizontal Filter Chips
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.filterOptions.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = controller.selectedFilterIndex == index;
                          final label = controller.filterOptions[index];

                          return GestureDetector(
                            onTap: () => controller.setFilterIndex(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF166534) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Product List View
                    Expanded(
                      child: displayProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🌾', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'কোনো লিস্টিং করা পণ্য পাওয়া যায়নি',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: displayProducts.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final product = displayProducts[index];
                                return _buildProductCard(context, controller, product);
                              },
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

    return GestureDetector(
      onTap: () => controller.openDetail(product),
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

          // Media Row (Image + Video Thumbnails) if present
          if (product.imageUrls.isNotEmpty || product.videoUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: Row(
                children: [
                  // Image Thumbnail
                  if (product.imageUrls.isNotEmpty)
                    Container(
                      width: 130,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrls.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white, size: 10),
                              SizedBox(width: 4),
                              Text(
                                'ছবি',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (product.imageUrls.isNotEmpty && product.videoUrl != null)
                    const SizedBox(width: 10),

                  // Video Thumbnail Card (Dark Navy with Play Icon)
                  if (product.videoUrl != null)
                    Container(
                      width: 135,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEA580C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
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
                            'যাচাই করুন',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 9,
                            ),
                          ),
                        ],
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
              // Media View Link (if media present)
              if (product.imageUrls.isNotEmpty || product.videoUrl != null)
                InkWell(
                  onTap: () => controller.openDetail(product),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_outlined, color: Color(0xFF166534), size: 16),
                      SizedBox(width: 4),
                      Text(
                        'মিডিয়া দেখুন',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),

              // Delete Button
              OutlinedButton.icon(
                onPressed: () => controller.deleteProduct(product.id),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 16),
                label: const Text(
                  'মুছুন',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
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
