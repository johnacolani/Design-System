import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/design_system.dart' as models;
import '../providers/design_system_provider.dart';
import '../services/project_service.dart';
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

  Future<void> _createAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);

    final designSystemProvider = Provider.of<DesignSystemProvider>(context, listen: false);

    try {
      final targetPlatforms = _platformChoice == 'all'
          ? List<String>.from(models.kTargetPlatforms)
          : [_platformChoice];
      designSystemProvider.createNewProject(
        name: name,
        description: '',
        targetPlatforms: targetPlatforms,
      );

      if (!kIsWeb && _chosenDirectoryPath != null && _chosenDirectoryPath!.isNotEmpty) {
        final fileName = '${ProjectService.sanitizeFileName(name)}.ds.json';
        final fullPath = '$_chosenDirectoryPath/$fileName';
        await ProjectService.saveProjectToFile(designSystemProvider.designSystem, fullPath);
        designSystemProvider.setCurrentProjectPath(fullPath);
      } else {
        // Web or user didn't pick a folder: save to default location.
        await designSystemProvider.saveProject();
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                  'Choose a name and where to save it on your device.',
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
                const SizedBox(height: 24),
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
