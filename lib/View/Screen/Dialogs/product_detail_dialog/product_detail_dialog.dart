import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/krishi_models.dart';
import '../../../../global/controller/krishi_repository.dart';
import '../../ProductDetailScreen/product_detail_screen.dart';

/// Legacy wrapper redirecting to the full-page [ProductDetailScreen].
/// This ensures backward compatibility if any controller sets `activeProductForDetail`.
class ProductDetailDialog extends StatelessWidget {
  final ProductListing product;

  const ProductDetailDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<KrishiRepository>();
    final currentProduct = repo.products.firstWhere(
      (p) => p.id == product.id,
      orElse: () => product,
    );

    return Material(
      color: Colors.transparent,
      child: ProductDetailScreen(
        product: currentProduct,
        onBack: () => repo.closeProductDetail(),
      ),
    );
  }
}
