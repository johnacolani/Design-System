import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie animation from LottieFiles shown behind the hero cards on the home screen.
/// Uses a design/abstract themed animation; falls back to empty if load fails.
class HeroLottieBackground extends StatelessWidget {
  final bool isMobile;

  const HeroLottieBackground({super.key, this.isMobile = false});

  /// Design-themed Lottie from LottieFiles CDN (abstract/creative).
  static const String _lottieUrl =
      'https://assets4.lottiefiles.com/packages/lf20_32NcN8.json';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.35,
          child: Lottie.network(
            _lottieUrl,
            fit: BoxFit.cover,
            repeat: true,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
