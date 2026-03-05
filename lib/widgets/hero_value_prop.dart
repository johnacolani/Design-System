import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Asset paths for platform icons (fallback to FontAwesome if image fails to load).
const String _assetFlutter = 'assets/images/flutter.png';
const String _assetApple = 'assets/images/apple.png';
const String _assetAndroid = 'assets/images/android.png';
const String _assetReact = 'assets/images/react-native.png';
const String _assetWeb = 'assets/images/web-png.png';

/// Three-line hero: line 1 text, line 2 framework icons, line 3 text.
class HeroValueProp extends StatelessWidget {
  final Color? textColor;
  final double? fontSize;
  final bool isMobile;
  final bool showAccentBar;

  const HeroValueProp({
    super.key,
    this.textColor,
    this.fontSize,
    this.isMobile = false,
    this.showAccentBar = true,
  });

  static const double _iconSize = 28;
  static const double _iconSpacing = 20;

  Widget _buildFrameworkIcons(BuildContext context, Color color) {
    final icons = <Widget>[
      _PlatformImage(assetPath: _assetFlutter, fallbackIcon: FontAwesomeIcons.flutter, fallbackColor: const Color(0xFF02539A), size: _iconSize),
      _PlatformImage(assetPath: _assetApple, fallbackIcon: FontAwesomeIcons.apple, fallbackColor: Colors.black87, size: _iconSize),
      _PlatformImage(assetPath: _assetAndroid, fallbackIcon: FontAwesomeIcons.android, fallbackColor: const Color(0xFF3DDC84), size: _iconSize),
      _PlatformImage(assetPath: _assetReact, fallbackIcon: FontAwesomeIcons.react, fallbackColor: const Color(0xFF61DAFB), size: _iconSize),
      _PlatformImage(assetPath: _assetWeb, fallbackIcon: FontAwesomeIcons.globe, fallbackColor: color, size: _iconSize),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: _iconSpacing,
      runSpacing: 12,
      children: icons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? Colors.grey[900]!;
    final primary = Theme.of(context).colorScheme.primary;
    final size = fontSize ?? (isMobile ? 18.0 : 22.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Build and manage cross-platform design systems for',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.3,
                fontSize: size,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildFrameworkIcons(context, color),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          'from one source of truth.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.3,
                fontSize: size,
              ),
          textAlign: TextAlign.center,
        ),
        if (showAccentBar) ...[
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}

/// Shows platform image from assets; on load error or missing asset, shows FontAwesome icon so no placeholder appears.
class _PlatformImage extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double size;

  const _PlatformImage({
    required this.assetPath,
    required this.fallbackIcon,
    required this.fallbackColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    const double elevation = 3;
    const double padding = 6;

    return Material(
      elevation: elevation,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => FaIcon(fallbackIcon, size: size, color: fallbackColor),
          ),
        ),
      ),
    );
  }
}
