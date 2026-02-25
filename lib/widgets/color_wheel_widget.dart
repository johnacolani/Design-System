import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/color_theory_service.dart';

/// Interactive color wheel widget for color selection
class ColorWheelWidget extends StatefulWidget {
  final Color? initialColor;
  final Function(Color)? onColorChanged;
  final double size;

  const ColorWheelWidget({
    super.key,
    this.initialColor,
    this.onColorChanged,
    this.size = 300,
  });

  @override
  State<ColorWheelWidget> createState() => _ColorWheelWidgetState();
}

class _ColorWheelWidgetState extends State<ColorWheelWidget> {
  late Color _selectedColor;
  late double _hue;
  late double _saturation;
  late double _lightness;

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      _selectedColor = widget.initialColor!;
      final hsl = ColorTheoryService.colorToHSL(_selectedColor);
      _hue = hsl['hue']!;
      _saturation = hsl['saturation']!;
      _lightness = hsl['lightness']!;
    } else {
      _hue = 0;
      _saturation = 1.0;
      _lightness = 0.5;
      _selectedColor = ColorTheoryService.colorFromHSL(_hue, _saturation, _lightness);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Color wheel
        GestureDetector(
          onPanUpdate: _handlePanUpdate,
          onTapDown: _handleTapDown,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ColorWheelPainter(
              selectedHue: _hue,
              selectedSaturation: _saturation,
              selectedLightness: _lightness,
              onColorSelected: (hue, saturation, lightness) {
                setState(() {
                  _hue = hue;
                  _saturation = saturation;
                  _lightness = lightness;
                  _selectedColor = ColorTheoryService.colorFromHSL(hue, saturation, lightness);
                });
                widget.onColorChanged?.call(_selectedColor);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Lightness slider
        Row(
          children: [
            const Text('Lightness:', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: _lightness,
                onChanged: (value) {
                  setState(() {
                    _lightness = value;
                    _selectedColor = ColorTheoryService.colorFromHSL(_hue, _saturation, _lightness);
                  });
                  widget.onColorChanged?.call(_selectedColor);
                },
              ),
            ),
          ],
        ),
        // Selected color display
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _selectedColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ColorTheoryService.colorToHex(_selectedColor),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      ],
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _updateColorFromPosition(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _updateColorFromPosition(details.localPosition);
  }

  void _updateColorFromPosition(Offset position) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final distance = (position - center).distance;
    final radius = widget.size / 2 - 20; // Account for padding

    if (distance > radius) return;

    final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    var hue = (angle * 180 / math.pi + 180) % 360;
    final saturation = math.min(distance / radius, 1.0);

    setState(() {
      _hue = hue;
      _saturation = saturation;
      _selectedColor = ColorTheoryService.colorFromHSL(hue, saturation, _lightness);
    });
    widget.onColorChanged?.call(_selectedColor);
  }
}

class ColorWheelPainter extends CustomPainter {
  final double selectedHue;
  final double selectedSaturation;
  final double selectedLightness;
  final Function(double hue, double saturation, double lightness) onColorSelected;

  ColorWheelPainter({
    required this.selectedHue,
    required this.selectedSaturation,
    required this.selectedLightness,
    required this.onColorSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw color wheel
    for (double angle = 0; angle < 360; angle += 1) {
      final hue = angle;
      final path = Path();
      final startRadius = radius * 0.7; // Inner radius for saturation variation
      final endRadius = radius;

      for (double r = startRadius; r <= endRadius; r += 2) {
        final saturation = (r - startRadius) / (endRadius - startRadius);
        final color = ColorTheoryService.colorFromHSL(hue, saturation, selectedLightness);
        final paint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        final x1 = center.dx + r * math.cos(angle * math.pi / 180);
        final y1 = center.dy + r * math.sin(angle * math.pi / 180);
        final x2 = center.dx + (r + 2) * math.cos(angle * math.pi / 180);
        final y2 = center.dy + (r + 2) * math.sin(angle * math.pi / 180);

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }

    // Draw selected color indicator
    final selectedAngle = selectedHue * math.pi / 180;
    final selectedRadius = radius * 0.7 + (radius * 0.3 * selectedSaturation);
    final selectedX = center.dx + selectedRadius * math.cos(selectedAngle);
    final selectedY = center.dy + selectedRadius * math.sin(selectedAngle);

    // Outer ring
    canvas.drawCircle(
      Offset(selectedX, selectedY),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(selectedX, selectedY),
      8,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Inner dot
    canvas.drawCircle(
      Offset(selectedX, selectedY),
      4,
      Paint()
        ..color = ColorTheoryService.colorFromHSL(selectedHue, selectedSaturation, selectedLightness)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) {
    return oldDelegate.selectedHue != selectedHue ||
        oldDelegate.selectedSaturation != selectedSaturation ||
        oldDelegate.selectedLightness != selectedLightness;
  }
}
