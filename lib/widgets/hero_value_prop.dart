import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      _PlatformIcon(icon: FontAwesomeIcons.flutter, color: const Color(0xFF02539A), size: _iconSize),
      _PlatformIcon(icon: FontAwesomeIcons.apple, color: Colors.black87, size: _iconSize),
      _PlatformIcon(icon: FontAwesomeIcons.android, color: const Color(0xFF3DDC84), size: _iconSize),
      _PlatformIcon(icon: FontAwesomeIcons.react, color: const Color(0xFF61DAFB), size: _iconSize),
      _PlatformIcon(icon: FontAwesomeIcons.globe, color: color, size: _iconSize),
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

class _PlatformIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _PlatformIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FaIcon(icon, size: size, color: color);
  }
}
