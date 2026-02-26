import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 80,
    this.color,
    this.fit = BoxFit.contain,
  });

  /// App icon used as logo (same as macOS app icon).
  static const String appIconAsset =
      'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      appIconAsset,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackIcon(context);
      },
    );
  }
  
  Widget _buildFallbackIcon(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.palette,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
