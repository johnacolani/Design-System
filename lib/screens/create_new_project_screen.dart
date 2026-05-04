import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/design_system.dart' as models;
import '../providers/design_system_provider.dart';
import '../providers/user_provider.dart';
import '../services/project_service.dart';
import '../services/color_psychology_service.dart';
import '../models/user.dart';
import '../utils/responsive.dart';
import 'onboarding_screen.dart';
import 'projects_screen.dart';

/// Screen shown when user taps "Create New Project": ask for project name and
/// choose save location (folder on desktop/mobile), then save and go to onboarding.
class CreateNewProjectScreen extends StatefulWidget {
  const CreateNewProjectScreen({super.key});

  @override
  State<CreateNewProjectScreen> createState() => _CreateNewProjectScreenState();
}

class _CreateNewProjectScreenState extends State<CreateNewProjectScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _chosenDirectoryPath;
  bool _isCreating = false;
  /// 'ios' | 'android' | 'web' | 'all'
  String _platformChoice = 'web';

  /// Brand feel (Delve-style quadrants).
  UserAttitude _brandAttitude = UserAttitude.matureUnderstated;
  /// Optional hue family from [ColorPsychologyService.getColorMeanings] keys; null = seed primary later in Colors.
  String? _psychologyHueKey;

  static const Map<String, Color> _hueSeedColors = {
    'blue': Color(0xFF1565C0),
    'green': Color(0xFF2E7D32),
    'red': Color(0xFFC62828),
    'orange': Color(0xFFEF6C00),
    'purple': Color(0xFF6A1B9A),
    'yellow': Color(0xFFF9A825),
    'grey': Color(0xFF616161),
    'black': Color(0xFF212121),
    'white': Color(0xFFECEFF1),
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _chooseSaveLocation() async {
    if (kIsWeb) return;
    try {
      final String? path = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose folder to save project',
      );
      if (path != null && mounted) {
        setState(() => _chosenDirectoryPath = path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open folder picker: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _buildColorPsychologyDescription() {
    final parts = <String>[];
    parts.add(
      'Brand attitude: ${ColorPsychologyService.getAttitudeName(_brandAttitude)}. '
      '${ColorPsychologyService.getAttitudeDescription(_brandAttitude)}',
    );
    if (_psychologyHueKey != null) {
      final m = ColorPsychologyService.getColorMeanings()[_psychologyHueKey!];
      if (m != null) {
        parts.add(
          'Initial color psychology direction: ${m.name} (${m.meanings.join(', ')}). '
          'Suggested traits: ${m.brandAttributes.join(', ')}.',
        );
      }
    } else {
      parts.add(
        'Primary brand chroma: to be chosen in Colors — use Browse schemes (Monochromatic, Triadic, Tetradic, …) when you add your palette.',
      );
    }
    return parts.join('\n\n');
  }

  Color? _seedPrimaryFromPsychology() {
    if (_psychologyHueKey == null) return null;
    return _hueSeedColors[_psychologyHueKey!];
  }

  static String _hueLabel(String key) {
    return key.isEmpty ? key : '${key[0].toUpperCase()}${key.substring(1)}';
  }

  Future<void> _createAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);

    final designSystemProvider = Provider.of<DesignSystemProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseUid = userProvider.isLoggedIn ? userProvider.currentUser!.id : null;

    try {
      final targetPlatforms = _platformChoice == 'all'
          ? List<String>.from(models.kTargetPlatforms)
          : [_platformChoice];
      final isAdmin = userProvider.userRole == UserRole.admin;
      designSystemProvider.createNewProject(
        name: name,
        description: isAdmin ? _buildColorPsychologyDescription() : '',
        targetPlatforms: targetPlatforms,
        primaryColor: isAdmin ? _seedPrimaryFromPsychology() : null,
      );

      if (!kIsWeb && _chosenDirectoryPath != null && _chosenDirectoryPath!.isNotEmpty) {
        final fileName = '${ProjectService.sanitizeFileName(name)}.ds.json';
        final fullPath = '$_chosenDirectoryPath/$fileName';
        await ProjectService.saveProjectToFile(designSystemProvider.designSystem, fullPath);
        designSystemProvider.setCurrentProjectPath(fullPath);
        if (firebaseUid != null) {
          try {
            await designSystemProvider.syncToCloud(firebaseUid);
          } catch (_) {
            // Optional cloud backup; local file is primary.
          }
        }
      } else {
        // Web or user didn't pick a folder: save to default location.
        await designSystemProvider.saveProject(firebaseUid: firebaseUid);
      }

      if (!mounted) return;
      setState(() => _isCreating = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create project: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProjectsScreen()),
          ),
        ),
        title: const Text('New Project'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive.isMobile ? 16 : 24,
            vertical: 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Create a new design system project',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name your project, set color psychology, then continue to onboarding.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Which platform(s) are you designing for?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('iOS only'),
                      selected: _platformChoice == 'ios',
                      onSelected: (_) => setState(() => _platformChoice = 'ios'),
                    ),
                    ChoiceChip(
                      label: const Text('Android only'),
                      selected: _platformChoice == 'android',
                      onSelected: (_) => setState(() => _platformChoice = 'android'),
                    ),
                    ChoiceChip(
                      label: const Text('Web only'),
                      selected: _platformChoice == 'web',
                      onSelected: (_) => setState(() => _platformChoice = 'web'),
                    ),
                    ChoiceChip(
                      label: const Text('All (iOS + Android + Web)'),
                      selected: _platformChoice == 'all',
                      onSelected: (_) => setState(() => _platformChoice = 'all'),
                    ),
                  ],
                ),
                if (_platformChoice == 'all')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'You’ll get a separate section per platform so each can have its own tokens.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project name *',
                    hintText: 'e.g. My Design System',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    if (userProvider.userRole != UserRole.admin) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 28),
                        Text(
                          'Color psychology & brand feel',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'How should this system feel? Optional: pick a dominant hue to seed your primary color.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...UserAttitude.values.map(
                          (a) => RadioListTile<UserAttitude>(
                            value: a,
                            groupValue: _brandAttitude,
                            onChanged: _isCreating
                                ? null
                                : (v) {
                                    if (v != null) setState(() => _brandAttitude = v);
                                  },
                            title: Text(
                              ColorPsychologyService.getAttitudeName(a),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Primary emotional color (optional)',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Decide later in Colors'),
                              selected: _psychologyHueKey == null,
                              onSelected: _isCreating
                                  ? null
                                  : (_) => setState(() => _psychologyHueKey = null),
                            ),
                            for (final entry in _hueSeedColors.entries)
                              ChoiceChip(
                                label: Text(_hueLabel(entry.key)),
                                selected: _psychologyHueKey == entry.key,
                                onSelected: _isCreating
                                    ? null
                                    : (sel) => setState(() => _psychologyHueKey = sel ? entry.key : null),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
                if (kIsWeb) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'On web, the project is saved in your browser storage.',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: _isCreating ? null : _chooseSaveLocation,
                    icon: const Icon(Icons.folder_open),
                    label: Text(_chosenDirectoryPath == null
                        ? 'Choose save location (folder)'
                        : 'Change folder'),
                  ),
                  if (_chosenDirectoryPath != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.folder, color: Colors.grey.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _chosenDirectoryPath!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade800,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createAndContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create and continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
