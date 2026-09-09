import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../service/api_url.dart';

/// Reusable, reliable image loader that handles:
/// - Backend relative URLs (e.g. `/uploads/image.jpg`)
/// - Full network URLs (e.g. `http://...`, `https://...`)
/// - Local device file paths (e.g. `/data/user/0/...` or `C:\...`)
/// - Graceful fallback with placeholder emoji/icon when offline or broken
class AppMediaImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String fallbackEmoji;
  final String? categoryIcon;
  final Widget? placeholderWidget;

  const AppMediaImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackEmoji = '🌾',
    this.categoryIcon,
    this.placeholderWidget,
  });

  @override
  Widget build(BuildContext context) {
    final raw = (url ?? '').trim();

    Widget imageContent;

    if (raw.isEmpty) {
      imageContent = _buildFallback();
    } else if (!kIsWeb && _isLocalFilePath(raw)) {
      final file = File(raw);
      if (file.existsSync()) {
        imageContent = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } else {
        imageContent = _buildFallback();
      }
    } else {
      final fullUrl = ApiUrl.formatMediaUrl(raw);
      imageContent = Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF166534),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('⚠️ [AppMediaImage Error]: $fullUrl -> $error');
          return _buildFallback();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  bool _isLocalFilePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('/uploads/')) {
      return false;
    }
    return path.startsWith('/') || path.contains(':\\') || path.contains(':/');
  }

  Widget _buildFallback() {
    if (placeholderWidget != null) return placeholderWidget!;

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              categoryIcon ?? fallbackEmoji,
              style: TextStyle(fontSize: (height != null && height! < 70) ? 22 : 32),
            ),
            if (height == null || height! >= 80) ...[
              const SizedBox(height: 4),
              const Text(
                'তাজা ফসল',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
