import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/design_system_provider.dart';
import '../providers/user_provider.dart';
import '../services/color_theory_service.dart';
import '../services/color_palette_service.dart';
import '../models/design_system.dart' as models;
import '../utils/platform_icons.dart';
import 'color_picker_screen.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1: Basic Info
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Step 2: App Information
  String? _appType;
  String? _targetAudience;
  String? _brandPersonality;
  
  // Step 3: Color Scheme Preference
  String? _colorSchemeType;
  
  // Step 4: Base Color
  Color _baseColor = Colors.blue; // Will be updated when step 4 loads
  final _hexColorController = TextEditingController();
  
  // Step 5: Generated Colors
  List<Color> _generatedColors = [];
  Color? _selectedPrimaryColor;

  @override
  void initState() {
    super.initState();
    _updateHexColorController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hexColorController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateHexColorController() {
    _hexColorController.text = _baseColor.value.toRadixString(16).substring(2).toUpperCase();
  }

  void _updateColorFromHex(String hexValue) {
    try {
      String cleanHex = hexValue.replaceAll('#', '').replaceAll(' ', '').toUpperCase();
      if (cleanHex.length == 3) {
        cleanHex = cleanHex.split('').map((char) => char + char).join();
      }
      if (cleanHex.length == 6) {
        final colorValue = int.parse(cleanHex, radix: 16);
        final newColor = Color((0xFF << 24) | colorValue);
        if (mounted) {
          setState(() {
            _baseColor = newColor;
            _generateColorScheme();
          });
        }
      }
    } catch (e) {
      // Invalid hex, ignore
    }
  }

  void _generateColorScheme() {
    if (_colorSchemeType == null) return;
    
    setState(() {
      switch (_colorSchemeType) {
        case 'Monochromatic':
          _generatedColors = ColorTheoryService.generateMonochromatic(_baseColor);
          break;
        case 'Analogous':
          _generatedColors = ColorTheoryService.generateAnalogous(_baseColor);
          break;
        case 'Complementary':
          _generatedColors = ColorTheoryService.generateComplementary(_baseColor);
          break;
        case 'Triadic':
          _generatedColors = ColorTheoryService.generateTriadic(_baseColor);
          break;
        case 'Split Complementary':
          _generatedColors = ColorTheoryService.generateSplitComplementary(_baseColor);
          break;
        case 'Tetradic':
          _generatedColors = ColorTheoryService.generateTetradic(_baseColor);
          break;
        default:
          _generatedColors = [_baseColor];
      }
      _selectedPrimaryColor = _generatedColors.isNotEmpty ? _generatedColors[_generatedColors.length ~/ 2] : _baseColor;
    });
  }

  Color? _getRecommendedBaseColor() {
    // Recommend colors based on app type and brand personality
    // Priority: Brand personality first, then app type, then audience
    
    // Brand personality takes priority
    if (_brandPersonality == 'Professional') {
      return Colors.blue;
    } else if (_brandPersonality == 'Creative') {
      return Colors.purple;
    } else if (_brandPersonality == 'Energetic') {
      return Colors.orange;
    } else if (_brandPersonality == 'Calm') {
      return Colors.green;
    } else if (_brandPersonality == 'Luxury') {
      return Colors.indigo;
    } else if (_brandPersonality == 'Friendly') {
      return Colors.teal;
    } else if (_brandPersonality == 'Modern') {
      return Colors.blue;
    } else if (_brandPersonality == 'Classic') {
      return Colors.grey[800]!;
    }
    
    // Then check app type
    if (_appType == 'Business') {
      return Colors.blue;
    } else if (_appType == 'Creative') {
      return Colors.purple;
    } else if (_appType == 'E-commerce') {
      return Colors.orange;
    } else if (_appType == 'Health') {
      return Colors.green;
    } else if (_appType == 'Education') {
      return Colors.blue;
    } else if (_appType == 'Social') {
      return Colors.pink;
    } else if (_appType == 'Entertainment') {
      return Colors.purple;
    }
    
    // Then check target audience
    if (_targetAudience == 'Young (18-25)') {
      return Colors.pink;
    } else if (_targetAudience == 'Adult (26-40)') {
      return Colors.blue;
    } else if (_targetAudience == 'Mature (40+)') {
      return Colors.grey[700]!;
    }
    
    // Default fallback
    return Colors.blue;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_appType != null && _targetAudience != null && _brandPersonality != null) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please answer all questions')),
        );
      }
    } else if (_currentStep == 2) {
      if (_colorSchemeType != null) {
        // Suggest base color based on answers
        final recommended = _getRecommendedBaseColor();
        if (recommended != null) {
          setState(() {
            _baseColor = recommended;
            _updateHexColorController();
            _generateColorScheme();
          });
        }
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() {
          _currentStep++;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a color scheme type')),
        );
      }
    } else if (_currentStep == 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  Future<void> _createProject() async {
    final designSystemProvider = Provider.of<DesignSystemProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Create project with primary color
    designSystemProvider.createNewProject(
      name: _nameController.text,
      description: _descriptionController.text,
      primaryColor: _selectedPrimaryColor ?? _baseColor,
    );

    // Add all generated colors from the color scheme to the design system
    if (_generatedColors.isNotEmpty && _colorSchemeType != null) {
      final colors = designSystemProvider.designSystem.colors;
      final updatedPrimary = Map<String, dynamic>.from(colors.primary);
      
      // Add each generated color with appropriate naming
      for (int i = 0; i < _generatedColors.length; i++) {
        final color = _generatedColors[i];
        final colorHex = ColorTheoryService.colorToHex(color);
        
        // Generate scales for each color
        final primaryToDark = ColorPaletteService.generatePrimaryToDark(color, steps: 10);
        final primaryToLight = ColorPaletteService.generatePrimaryToLight(color, steps: 10);
        
        // Determine color name based on position and scheme type
        String colorName;
        if (i == _generatedColors.length ~/ 2) {
          colorName = 'primary'; // Middle color is primary
        } else if (_colorSchemeType == 'Monochromatic') {
          colorName = i < _generatedColors.length ~/ 2 
              ? 'primary_light${_generatedColors.length ~/ 2 - i}'
              : 'primary_dark${i - _generatedColors.length ~/ 2}';
        } else {
          colorName = '${_colorSchemeType?.toLowerCase()}_${i + 1}';
        }
        
        // Add main color
        updatedPrimary[colorName] = {
          'value': colorHex,
          'type': 'color',
          'description': '$_colorSchemeType color ${i + 1}',
        };
        
        // Add dark scale variations
        primaryToDark.forEach((key, value) {
          if (key != 'primary') {
            updatedPrimary['${colorName}_$key'] = {
              'value': value,
              'type': 'color',
              'description': 'Dark variation $key of $colorName',
            };
          }
        });
        
        // Add light scale variations
        primaryToLight.forEach((key, value) {
          if (key != 'primary') {
            updatedPrimary['${colorName}_$key'] = {
              'value': value,
              'type': 'color',
              'description': 'Light variation $key of $colorName',
            };
          }
        });
      }
      
      // Update colors with all generated colors
      designSystemProvider.updateColors(models.Colors(
        primary: updatedPrimary,
        semantic: colors.semantic,
        blue: colors.blue,
        green: colors.green,
        orange: colors.orange,
        purple: colors.purple,
        red: colors.red,
        grey: colors.grey,
        white: colors.white,
        text: colors.text,
        input: colors.input,
        roleSpecific: colors.roleSpecific,
      ));
    }

    userProvider.incrementProjectsCreated();
    
    // Auto-save the project
    try {
      await designSystemProvider.saveProject();
    } catch (e) {
      // Show error but don't block navigation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project created but save failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
    
    // Navigate to Dashboard instead of popping back
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design system created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = firebase_auth.FirebaseAuth.instance;
    final userProvider = Provider.of<UserProvider>(context);
    
    // Check authentication - allow guest users but show a message
    if (firebaseAuth.currentUser == null || !userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Show info message but allow guest users to proceed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are using guest mode. Sign in to save projects to the cloud.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(platformBackIcon),
          onPressed: _currentStep > 0 ? _previousStep : () => Navigator.of(context).pop(),
        ),
        title: Text('Step ${_currentStep + 1} of 5'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1BasicInfo(),
          _buildStep2AppInfo(),
          _buildStep3ColorScheme(),
          _buildStep4BaseColor(),
          _buildStep5Preview(),
        ],
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (width * 0.20).clamp(24.0, double.infinity);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              40,
              horizontalPadding,
              32 + 140, // Extra bottom padding: space below buttons + room for SnackBar
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.palette, size: 56, color: Colors.blue.shade700),
                  const SizedBox(height: 24),
                  Text(
                    'Create Your Design System',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s start with some basic information',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Project Name *',
                      hintText: 'e.g., My Awesome Design System',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Describe your design system',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Next: Tell us about your app', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2AppInfo() {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (width * 0.20).clamp(24.0, double.infinity);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            40,
            horizontalPadding,
            // Extra bottom padding: distance below buttons + room for SnackBar
            32 + 140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.apps, size: 56, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 24),
              Text(
                'Tell us about your app',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us recommend the perfect colors for your design system',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              // App Type
              Text(
                'What type of app are you building? *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Business', 'Creative', 'E-commerce', 'Health', 'Education', 'Social', 'Entertainment', 'Other'].map((type) {
                  final isSelected = _appType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _appType = selected ? type : null);
                    },
                    selectedColor: Colors.blue[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue[900] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Target Audience
              Text(
                'Who is your target audience? *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Young (18-25)', 'Adult (26-40)', 'Mature (40+)', 'All Ages'].map((audience) {
                  final isSelected = _targetAudience == audience;
                  return ChoiceChip(
                    label: Text(audience),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _targetAudience = selected ? audience : null);
                    },
                    selectedColor: Colors.blue[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue[900] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Brand Personality
              Text(
                'What best describes your brand personality? *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Professional', 'Creative', 'Energetic', 'Calm', 'Luxury', 'Friendly', 'Modern', 'Classic'].map((personality) {
                  final isSelected = _brandPersonality == personality;
                  return ChoiceChip(
                    label: Text(personality),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _brandPersonality = selected ? personality : null);
                    },
                    selectedColor: Colors.blue[100],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue[900] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Next: Choose Color Scheme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3ColorScheme() {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (width * 0.20).clamp(24.0, double.infinity);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            40,
            horizontalPadding,
            // Extra bottom padding: distance below buttons + room for SnackBar
            32 + 140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.color_lens, size: 56, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 24),
              Text(
                'Choose your color scheme',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the type of color palette you want to use',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              _buildSchemeOption(
                'Monochromatic',
                'Single color with different shades and tints. Clean and minimalist.',
                Icons.gradient,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildSchemeOption(
                'Analogous',
                'Colors next to each other on the color wheel. Harmonious and soothing.',
                Icons.linear_scale,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildSchemeOption(
                'Complementary',
                'Opposite colors on the color wheel. Bold and eye-catching.',
                Icons.compare_arrows,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildSchemeOption(
                'Triadic',
                'Three evenly spaced colors. Vibrant and energetic.',
                Icons.change_circle,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildSchemeOption(
                'Split Complementary',
                'Base color with two adjacent to its complement. Balanced contrast.',
                Icons.splitscreen,
                Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildSchemeOption(
                'Tetradic',
                'Four colors forming a rectangle. Rich and diverse palette.',
                Icons.grid_4x4,
                Colors.pink,
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Next: Pick Base Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeOption(String title, String description, IconData icon, Color color) {
    final isSelected = _colorSchemeType == title;
    return InkWell(
      onTap: () {
        setState(() => _colorSchemeType = title);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4BaseColor() {
    final recommendedColor = _getRecommendedBaseColor();
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (width * 0.20).clamp(24.0, double.infinity);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (_baseColor).withValues(alpha: 0.1),
            (_baseColor).withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            40,
            horizontalPadding,
            32 + 140, // Extra bottom padding: space below buttons + room for SnackBar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.colorize, size: 56, color: _baseColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Pick your base color',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This color will be used to generate your ${_colorSchemeType?.toLowerCase() ?? 'color'} palette',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              // Always show recommendation if we have app info, even if color matches
              if (recommendedColor != null && _appType != null && _brandPersonality != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: recommendedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: recommendedColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: recommendedColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended for you',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: recommendedColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Based on your ${_appType ?? 'app type'} and ${_brandPersonality ?? 'brand personality'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: recommendedColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _baseColor = recommendedColor;
                            _updateHexColorController();
                            _generateColorScheme();
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: recommendedColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: recommendedColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: _baseColor == recommendedColor
                              ? const Icon(Icons.check, color: Colors.white, size: 24)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () => _showColorPickerDialog(context),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _baseColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _baseColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.colorize,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '#',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _hexColorController,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'FFFFFF',
                        ),
                        maxLength: 6,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                        onChanged: (value) {
                          _updateColorFromHex(value);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  Colors.blue,
                  Colors.purple,
                  Colors.green,
                  Colors.orange,
                  Colors.red,
                  Colors.pink,
                  Colors.teal,
                  Colors.indigo,
                ].map((color) {
                  final isSelected = color == _baseColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _baseColor = color;
                        _updateHexColorController();
                        _generateColorScheme();
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) => const ColorPickerScreen(),
                      ),
                    );
                    if (result != null && result['color'] != null && mounted) {
                      setState(() {
                        _baseColor = result['color'] as Color;
                        _updateHexColorController();
                        _generateColorScheme();
                      });
                    }
                  },
                  icon: const Icon(Icons.palette),
                  label: const Text('Browse Color Palettes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _baseColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Preview Palette', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep5Preview() {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = (width * 0.20).clamp(24.0, double.infinity);
    final accentColor = _selectedPrimaryColor ?? _baseColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.1),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            40,
            horizontalPadding,
            32 + 140, // Extra bottom padding: space below buttons + room for SnackBar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.preview, size: 56, color: accentColor),
              ),
              const SizedBox(height: 24),
              Text(
                'Preview your color palette',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review your ${_colorSchemeType?.toLowerCase() ?? 'color'} palette and select the primary color',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              // Generated colors display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generated Colors (${_generatedColors.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _generatedColors.map((color) {
                        final isSelected = _selectedPrimaryColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedPrimaryColor = color);
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.grey[300]!,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.star, color: Colors.white, size: 30)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ColorTheoryService.colorToHex(color),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (isSelected)
                                Text(
                                  'Primary',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Project summary
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Name', _nameController.text),
                    if (_descriptionController.text.isNotEmpty)
                      _buildSummaryRow('Description', _descriptionController.text),
                    _buildSummaryRow('App Type', _appType ?? 'Not specified'),
                    _buildSummaryRow('Target Audience', _targetAudience ?? 'Not specified'),
                    _buildSummaryRow('Brand Personality', _brandPersonality ?? 'Not specified'),
                    _buildSummaryRow('Color Scheme', _colorSchemeType ?? 'Not specified'),
                    _buildSummaryRow('Primary Color', ColorTheoryService.colorToHex(_selectedPrimaryColor ?? _baseColor)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedPrimaryColor ?? _baseColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Create Design System', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[900]),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Base Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _baseColor,
            onColorChanged: (color) {
              setState(() {
                _baseColor = color;
                _updateHexColorController();
                _generateColorScheme();
              });
            },
            displayThumbColor: true,
            enableAlpha: false,
            pickerAreaHeightPercent: 0.8,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
