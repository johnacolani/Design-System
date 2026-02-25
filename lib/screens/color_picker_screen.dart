import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/color_palette_service.dart';
import '../services/color_theory_service.dart';
import '../services/contrast_checker_service.dart';
import '../services/color_psychology_service.dart';
import '../widgets/color_wheel_widget.dart';
import 'material_picker_screen.dart';
import 'cupertino_picker_screen.dart';

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

class _ColorPickerScreenState extends State<ColorPickerScreen> with SingleTickerProviderStateMixin {
  List<ColorPalette> _palettes = [];
  bool _isLoading = true;
  Color? _selectedColor;
  final Set<Color> _selectedColors = {}; // Track multiple selected colors
  Map<String, String> _primaryToDark = {};
  Map<String, String> _primaryToLight = {};
  Map<String, Map<String, String>>? _secondaryScales;
  List<ColorSuggestion> _suggestions = [];
  String _selectedPalette = '';
  late TabController _tabController;
  
  // New features
  Color? _schemeBaseColor;
  String? _selectedSchemeType;
  List<Color> _generatedScheme = [];
  Color? _contrastForeground;
  Color? _contrastBackground;
  ContrastInfo? _contrastInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPalettes();
    _contrastForeground = Colors.black;
    _contrastBackground = Colors.white;
    _updateContrastInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateContrastInfo() {
    if (_contrastForeground != null && _contrastBackground != null) {
      setState(() {
        _contrastInfo = ContrastCheckerService.getContrastInfo(
          _contrastForeground!,
          _contrastBackground!,
        );
      });
    }
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Palettes'),
            Tab(icon: Icon(Icons.color_lens), text: 'Color Wheel'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Schemes'),
            Tab(icon: Icon(Icons.contrast), text: 'Contrast'),
            Tab(icon: Icon(Icons.psychology), text: 'Analysis'),
          ],
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPalettesTab(),
          _buildColorWheelTab(),
          _buildColorSchemesTab(),
          _buildContrastTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildPalettesTab() {
    return _isLoading
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
            : _buildPaletteContent();
  }

  Widget _buildPaletteContent() {
    return Column(
      children: [
        // Browse other color libraries
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.palette, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Browse Design Libraries',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<Color?>(
                    MaterialPageRoute(
                      builder: (_) => const MaterialPickerScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    _onColorTap(result);
                  }
                },
                icon: const Icon(Icons.design_services, size: 16),
                label: const Text('Material'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push<Color?>(
                    MaterialPageRoute(
                      builder: (_) => const CupertinoPickerScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    _onColorTap(result);
                  }
                },
                icon: const Icon(Icons.phone_iphone, size: 16),
                label: const Text('iOS'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
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
                                        color: color.withValues(alpha: 0.5),
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
    );
  }

  Widget _buildColorWheelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ColorWheelWidget(
            initialColor: _selectedColor,
            size: 300,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
                if (!_selectedColors.contains(color)) {
                  _selectedColors.add(color);
                }
                _onColorTap(color);
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _selectedColor != null
                ? () {
                    _onColorTap(_selectedColor!);
                  }
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add Selected Color'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Scheme Generator',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Base color selector
          Row(
            children: [
              const Text('Base Color:'),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (_) => const ColorPickerScreen(),
                    ),
                  );
                  if (result != null && result['color'] != null) {
                    setState(() {
                      _schemeBaseColor = result['color'] as Color;
                      _generateScheme();
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _schemeBaseColor ?? Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Scheme type selector
          Wrap(
            spacing: 8,
            children: [
              _buildSchemeTypeButton('Monochromatic', Icons.gradient),
              _buildSchemeTypeButton('Analogous', Icons.linear_scale),
              _buildSchemeTypeButton('Complementary', Icons.compare_arrows),
              _buildSchemeTypeButton('Triadic', Icons.change_circle),
              _buildSchemeTypeButton('Split Complementary', Icons.splitscreen),
              _buildSchemeTypeButton('Tetradic', Icons.grid_4x4),
            ],
          ),
          const SizedBox(height: 24),
          // Generated scheme display
          if (_generatedScheme.isNotEmpty) ...[
            Text(
              'Generated Scheme: ${_selectedSchemeType ?? ""}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _generatedScheme.map((color) {
                return GestureDetector(
                  onTap: () => _onColorTap(color),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ColorTheoryService.colorToHex(color),
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                for (final color in _generatedScheme) {
                  _onColorTap(color);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add All Colors'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchemeTypeButton(String type, IconData icon) {
    final isSelected = _selectedSchemeType == type;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _selectedSchemeType = type;
          _generateScheme();
        });
      },
      icon: Icon(icon, size: 18),
      label: Text(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  void _generateScheme() {
    if (_schemeBaseColor == null || _selectedSchemeType == null) return;

    setState(() {
      switch (_selectedSchemeType) {
        case 'Monochromatic':
          _generatedScheme = ColorTheoryService.generateMonochromatic(_schemeBaseColor!);
          break;
        case 'Analogous':
          _generatedScheme = ColorTheoryService.generateAnalogous(_schemeBaseColor!);
          break;
        case 'Complementary':
          _generatedScheme = ColorTheoryService.generateComplementary(_schemeBaseColor!);
          break;
        case 'Triadic':
          _generatedScheme = ColorTheoryService.generateTriadic(_schemeBaseColor!);
          break;
        case 'Split Complementary':
          _generatedScheme = ColorTheoryService.generateSplitComplementary(_schemeBaseColor!);
          break;
        case 'Tetradic':
          _generatedScheme = ColorTheoryService.generateTetradic(_schemeBaseColor!);
          break;
        default:
          _generatedScheme = [];
      }
    });
  }

  Widget _buildContrastTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contrast Checker',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          // Foreground color
          Row(
            children: [
              const Text('Foreground:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (_) => const ColorPickerScreen(),
                    ),
                  );
                  if (result != null && result['color'] != null) {
                    setState(() {
                      _contrastForeground = result['color'] as Color;
                      _updateContrastInfo();
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _contrastForeground ?? Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Background color
          Row(
            children: [
              const Text('Background:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (_) => const ColorPickerScreen(),
                    ),
                  );
                  if (result != null && result['color'] != null) {
                    setState(() {
                      _contrastBackground = result['color'] as Color;
                      _updateContrastInfo();
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _contrastBackground ?? Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _contrastBackground ?? Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              'Sample Text',
              style: TextStyle(
                color: _contrastForeground ?? Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Contrast info
          if (_contrastInfo != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contrast Ratio: ${_contrastInfo!.ratio.toStringAsFixed(2)}:1',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildWCAGRow('WCAG AA (Normal)', _contrastInfo!.wcagAA),
                    _buildWCAGRow('WCAG AA (Large)', _contrastInfo!.wcagAA_Large),
                    _buildWCAGRow('WCAG AAA (Normal)', _contrastInfo!.wcagAAA),
                    _buildWCAGRow('WCAG AAA (Large)', _contrastInfo!.wcagAAA_Large),
                    const SizedBox(height: 16),
                    Text(
                      'Level: ${_contrastInfo!.level}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _contrastInfo!.level == 'Fail' ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _contrastInfo!.score,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _contrastInfo!.score > 0.7 ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      'Accessibility Score: ${(_contrastInfo!.score * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_contrastInfo!.readable)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _contrastForeground = ContrastCheckerService.suggestForegroundColor(
                      _contrastBackground!,
                    );
                    _updateContrastInfo();
                  });
                },
                icon: const Icon(Icons.lightbulb),
                label: const Text('Suggest Better Foreground Color'),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildWCAGRow(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    if (_selectedColor == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.color_lens, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select a color to see analysis',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final meaning = ColorPsychologyService.getColorMeaning(_selectedColor!);
    final colorName = ColorPsychologyService.getColorName(_selectedColor!);
    final culturalWarnings = colorName != null
        ? ColorPsychologyService.getCulturalWarnings(colorName)
        : <String>[];
    final harmonyScore = _selectedColors.length > 1
        ? ColorTheoryService.calculateHarmonyScore(_selectedColors.toList())
        : null;
    final schemeType = _selectedColors.length > 1
        ? ColorTheoryService.detectColorScheme(_selectedColors.toList())
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color Psychology
          if (meaning != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Psychology: ${meaning.name}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Meanings: ${meaning.meanings.join(", ")}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Brand Attributes: ${meaning.brandAttributes.join(", ")}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Cultural Warnings
          if (culturalWarnings.isNotEmpty) ...[
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Cultural Considerations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...culturalWarnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('• $warning', style: TextStyle(color: Colors.orange[800])),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Color Harmony
          if (harmonyScore != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Harmony Analysis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text('Harmony Score: ${(harmonyScore * 100).toStringAsFixed(0)}%'),
                    LinearProgressIndicator(
                      value: harmonyScore,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        harmonyScore > 0.7 ? Colors.green : Colors.orange,
                      ),
                    ),
                    if (schemeType != null) ...[
                      const SizedBox(height: 8),
                      Text('Detected Scheme: $schemeType'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Selected Colors Display
          if (_selectedColors.isNotEmpty) ...[
            Text(
              'Selected Colors (${_selectedColors.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _selectedColors.map((color) {
                return Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ColorTheoryService.colorToHex(color),
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
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
            color: Colors.black.withValues(alpha: 0.1),
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
