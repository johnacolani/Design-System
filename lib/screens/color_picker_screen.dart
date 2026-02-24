import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/color_palette_service.dart';
import '../models/design_system.dart' as models;

class ColorPickerScreen extends StatefulWidget {
  final String? category;
  final Function(Color, Map<String, String>, Map<String, String>, List<ColorSuggestion>)? onColorSelected;

  const ColorPickerScreen({
    super.key,
    this.category,
    this.onColorSelected,
  });

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  List<ColorPalette> _palettes = [];
  bool _isLoading = true;
  Color? _selectedColor;
  Set<Color> _selectedColors = {}; // Track multiple selected colors
  Map<String, String> _primaryToDark = {};
  Map<String, String> _primaryToLight = {};
  Map<String, Map<String, String>>? _secondaryScales;
  List<ColorSuggestion> _suggestions = [];
  String _selectedPalette = '';

  @override
  void initState() {
    super.initState();
    _loadPalettes();
  }

  Future<void> _loadPalettes() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/data/color_palettes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        _palettes = (jsonData['palettes'] as List)
            .map((p) => ColorPalette.fromJson(p))
            .toList();
        
        // Set default selected palette if available
        if (_palettes.isNotEmpty) {
          _selectedPalette = _palettes.first.name;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load color palettes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onColorTap(Color color) {
    setState(() {
      // Toggle color selection (allow multiple)
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
        if (_selectedColor == color) {
          _selectedColor = _selectedColors.isNotEmpty ? _selectedColors.first : null;
        }
      } else {
        _selectedColors.add(color);
        _selectedColor = color; // Set as primary selected for preview
      }
      
      // Generate primary color scales for the primary selected color
      if (_selectedColor != null) {
        _primaryToDark = ColorPaletteService.generatePrimaryToDark(_selectedColor!, steps: 10);
        _primaryToLight = ColorPaletteService.generatePrimaryToLight(_selectedColor!, steps: 10);
        
        // Generate secondary color scales if this is a secondary color
        if (widget.category == 'secondary' || widget.category == 'semantic') {
          _secondaryScales = ColorPaletteService.generateSecondaryScales(_selectedColor!, steps: 10);
        }
        
        // Generate color suggestions
        _suggestions = ColorPaletteService.suggestColors(_selectedColor!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedColors.isEmpty 
            ? 'Select Colors' 
            : '${_selectedColors.length} Selected'),
        actions: [
          if (_selectedColors.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                // Return all selected colors
                Navigator.of(context).pop({
                  'colors': _selectedColors.toList(), // Return list of colors
                  'color': _selectedColor, // Primary selected for compatibility
                  'primaryToDark': _primaryToDark,
                  'primaryToLight': _primaryToLight,
                  'suggestions': _suggestions,
                });
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Add ${_selectedColors.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _palettes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load color palettes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPalettes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Palette selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[100],
                      child: _palettes.isEmpty || _selectedPalette.isEmpty
                          ? const SizedBox.shrink()
                          : DropdownButton<String>(
                              value: _selectedPalette,
                              isExpanded: true,
                              items: _palettes.map((palette) {
                                return DropdownMenuItem(
                                  value: palette.name,
                                  child: Text(palette.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPalette = value!;
                                });
                              },
                            ),
                    ),
                
                // Color grid
                Expanded(
                  child: _palettes.isEmpty || _selectedPalette.isEmpty
                      ? const Center(child: Text('No palettes available'))
                      : Builder(
                          builder: (context) {
                            final selectedPaletteObj = _palettes.firstWhere(
                              (p) => p.name == _selectedPalette,
                              orElse: () => _palettes.isNotEmpty ? _palettes.first : ColorPalette(name: '', colors: []),
                            );
                            
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: selectedPaletteObj.colors.length,
                              itemBuilder: (context, index) {
                                if (index >= selectedPaletteObj.colors.length) {
                                  return const SizedBox.shrink();
                                }
                                
                                final colorInfo = selectedPaletteObj.colors[index];
                                final color = ColorPaletteService.hexToColor(colorInfo.hex);
                                final isSelected = _selectedColors.contains(color);
                                final isPrimarySelected = _selectedColor == color;

                                return GestureDetector(
                                  onTap: () => _onColorTap(color),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected 
                                            ? (isPrimarySelected ? Colors.black : Colors.blue)
                                            : Colors.grey.shade300,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withOpacity(0.5),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        if (isSelected)
                                          const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        if (isPrimarySelected && _selectedColors.length > 1)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                // Selected color info and scales
                if (_selectedColor != null) _buildColorInfo(),
              ],
            ),
    );
  }

  Widget _buildColorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected color display
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ColorPaletteService.colorToHex(_selectedColor!),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: ColorPaletteService.colorToHex(_selectedColor!)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Color hex copied to clipboard!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy Hex'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Primary to Dark scale
            _buildScaleSection('Primary to Dark', _primaryToDark),

            const SizedBox(height: 24),

            // Primary to Light scale
            _buildScaleSection('Primary to Light', _primaryToLight),

            // Secondary scales if applicable
            if (_secondaryScales != null) ...[
              const SizedBox(height: 24),
              _buildScaleSection('Secondary to White', _secondaryScales!['toWhite']!),
              const SizedBox(height: 24),
              _buildScaleSection('Secondary to Dark', _secondaryScales!['toDark']!),
            ],

            const SizedBox(height: 24),

            // Color suggestions
            const Text(
              'Suggested Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _suggestions.take(6).map((suggestion) {
                return GestureDetector(
                  onTap: () => _onColorTap(suggestion.color),
                  child: Tooltip(
                    message: '${suggestion.name}\n${suggestion.description}\nMatch: ${(suggestion.matchScore * 100).toStringAsFixed(0)}%',
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: suggestion.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 70,
                          child: Text(
                            suggestion.name,
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleSection(String title, Map<String, String> scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: scale.entries.map((entry) {
            final color = ColorPaletteService.hexToColor(entry.value);
            return GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: entry.value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${entry.key}: ${entry.value} copied!')),
                );
              },
              child: Tooltip(
                message: '${entry.key}: ${entry.value}',
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ColorPalette {
  final String name;
  final List<ColorInfo> colors;

  ColorPalette({required this.name, required this.colors});

  factory ColorPalette.fromJson(Map<String, dynamic> json) {
    return ColorPalette(
      name: json['name'] as String,
      colors: (json['colors'] as List)
          .map((c) => ColorInfo.fromJson(c))
          .toList(),
    );
  }
}

class ColorInfo {
  final String name;
  final String hex;

  ColorInfo({required this.name, required this.hex});

  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return ColorInfo(
      name: json['name'] as String,
      hex: json['hex'] as String,
    );
  }
}
