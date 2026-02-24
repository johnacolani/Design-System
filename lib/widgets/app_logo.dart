import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  @override
  Widget build(BuildContext context) {
    // For web, use the web icon directly
    if (kIsWeb) {
      return Image.network(
        '/icons/icon-512.png',
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Fallback: Use Material icon
          return _buildFallbackIcon(context);
        },
      );
    }
    
    // For mobile/desktop, try assets first
    return Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: Use Material icon
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
