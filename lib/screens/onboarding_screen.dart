import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/app_logo.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _selectedColor = Colors.deepPurple;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createProject() {
    if (_formKey.currentState!.validate()) {
      final designSystemProvider = Provider.of<DesignSystemProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      designSystemProvider.createNewProject(
        name: _nameController.text,
        description: _descriptionController.text,
        primaryColor: _selectedColor,
      );

      // Increment user's project count
      userProvider.incrementProjectsCreated();

      // Navigate back to home screen to show the preview
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Create Design System'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _selectedColor.withOpacity(0.1),
              _selectedColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppLogo(
                      size: 80,
                    ),
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
                      'Start building a comprehensive design system for your project',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Project Name',
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
                    const SizedBox(height: 32),
                    Text(
                      'Primary Color',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final color = await showDialog<Color>(
                                context: context,
                                builder: (context) => _ColorPickerDialog(
                                  initialColor: _selectedColor,
                                ),
                              );
                              if (color != null) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final color = await showDialog<Color>(
                                context: context,
                                builder: (context) => _ColorPickerDialog(
                                  initialColor: _selectedColor,
                                ),
                              );
                              if (color != null) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              }
                            },
                            icon: const Icon(Icons.colorize),
                            label: const Text('Pick Color'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _createProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Create Design System',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Primary Color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),
            _buildColorGrid(),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Hex Color',
                hintText: '#FF5722',
                prefixText: '#',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                try {
                  final color = Color(
                    int.parse('FF$value', radix: 16),
                  );
                  setState(() {
                    _selectedColor = color;
                  });
                } catch (e) {
                  // Invalid color
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildColorGrid() {
    final presetColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetColors.map((color) {
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
