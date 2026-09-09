import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../../Widgegt/Cards/product_card.dart';
import '../../ProductDetailScreen/product_detail_screen.dart';
import 'buyer_search_controller.dart';

class BuyerSearchScreen extends StatelessWidget {
  const BuyerSearchScreen({super.key});

  static const List<String> districtList = [
    'সকল জেলা',
    'রাজশাহী',
    'বগুড়া',
    'পাবনা',
    'যশোর',
    'দিনাজপুর',
    'ময়মনসিংহ',
    'রংপুর',
    'নাটোর',
    'চুয়াডাঙ্গা',
    'টাঙ্গাইল',
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final controller = BuyerSearchController(repo);
    final products = controller.filteredProducts;

    return Column(
      children: [
        // Top Filter & Search Container
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search Input
              TextField(
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'ফসলের নাম বা জেলা দিয়ে খুঁজুন...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF165228)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              const SizedBox(height: 10),

              // Filter Row 1: District Dropdown Pill & Verified Farmer Filter Pill
              Row(
                children: [
                  // 1. District Selector Popup Menu Button
                  PopupMenuButton<String>(
                    onSelected: (dist) => controller.setSelectedDistrict(dist),
                    color: const Color(0xFFF5F3FF),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    itemBuilder: (context) {
                      return districtList.map((dist) {
                        final isSelected = (controller.selectedDistrict == dist) ||
                            (controller.selectedDistrict == null && dist == 'সকল জেলা');
                        return PopupMenuItem<String>(
                          value: dist,
                          child: Text(
                            dist,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF165228) : const Color(0xFF1E293B),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF165228), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            controller.selectedDistrict ?? 'সকল জেলা',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF165228), size: 20),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 2. Verified Farmer Filter Chip Pill
                  InkWell(
                    onTap: controller.toggleOnlyVerifiedFarmers,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: controller.onlyVerifiedFarmers
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF4F7F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.onlyVerifiedFarmers
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFCBD5E1),
                          width: controller.onlyVerifiedFarmers ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'ভেরিফাইড কৃষক',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            controller.onlyVerifiedFarmers
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: controller.onlyVerifiedFarmers
                                ? const Color(0xFF165228)
                                : const Color(0xFF94A3B8),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Filter Row 2: Crop Categories Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('সকল ক্যাটাগরি'),
                      selected: controller.selectedCategory == null,
                      onSelected: (_) => controller.setSelectedCategory(null),
                      selectedColor: const Color(0xFFDCFCE7),
                      checkmarkColor: const Color(0xFF165228),
                    ),
                    const SizedBox(width: 8),
                    ...ProductCategory.values.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text('${cat.icon} ${cat.labelBn}'),
                          selected: controller.selectedCategory == cat,
                          onSelected: (_) => controller.setSelectedCategory(cat),
                          selectedColor: const Color(0xFFDCFCE7),
                          checkmarkColor: const Color(0xFF165228),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text(
                    'কোনো ফসল খুঁজে পাওয়া যায়নি',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
