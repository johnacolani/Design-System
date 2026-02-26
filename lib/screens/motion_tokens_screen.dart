import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class MotionTokensScreen extends StatefulWidget {
  const MotionTokensScreen({super.key});

  @override
  State<MotionTokensScreen> createState() => _MotionTokensScreenState();
}

class _MotionTokensScreenState extends State<MotionTokensScreen> {
  String _selectedCategory = 'duration';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final motionTokens = provider.designSystem.motionTokens;

    final currentMap = _selectedCategory == 'duration' ? motionTokens.duration : motionTokens.easing;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Motion Tokens'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Duration'),
                  selected: _selectedCategory == 'duration',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = 'duration');
                    }
                  },
                ),
              ),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Easing'),
                  selected: _selectedCategory == 'easing',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = 'easing');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddMotionTokenDialog(context, _selectedCategory);
            },
            tooltip: 'Add ${_selectedCategory == 'duration' ? 'Duration' : 'Easing'}',
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: Column(
          children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.purple.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedCategory == 'duration'
                        ? 'Duration tokens define animation timing (e.g., fast: 150ms, slow: 500ms)'
                        : 'Easing tokens define animation curves (e.g., ease-in, ease-out, cubic-bezier)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.purple.shade900,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: currentMap.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedCategory == 'duration' ? Icons.timer : Icons.trending_up,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedCategory} tokens defined',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddMotionTokenDialog(context, _selectedCategory);
                          },
                          icon: const Icon(Icons.add),
                          label: Text('Add ${_selectedCategory == 'duration' ? 'Duration' : 'Easing'} Token'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentMap.length,
                    itemBuilder: (context, index) {
                      final entry = currentMap.entries.elementAt(index);
                      return _buildMotionTokenCard(context, _selectedCategory, entry.key, entry.value);
                    },
                  ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildMotionTokenCard(
    BuildContext context,
    String category,
    String name,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category == 'duration' ? Colors.blue.shade100 : Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category == 'duration' ? Icons.timer : Icons.trending_up,
            color: category == 'duration' ? Colors.blue.shade700 : Colors.purple.shade700,
          ),
        ),
        title: Text(name),
        subtitle: Text(
          value,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () {
                _showEditMotionTokenDialog(context, category, name, value);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () {
                _deleteMotionToken(context, category, name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMotionTokenDialog(BuildContext context, String category) {
    _showMotionTokenDialog(context, category, null, null);
  }

  void _showMotionTokenDialog(
    BuildContext context,
    String category,
    String? existingName,
    String? existingValue,
  ) {
    final nameController = TextEditingController(text: existingName ?? '');
    final valueController = TextEditingController(text: existingValue ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${existingName != null ? 'Edit' : 'Add'} ${category == 'duration' ? 'Duration' : 'Easing'} Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Token Name',
                hintText: category == 'duration' ? 'e.g., fast, medium, slow' : 'e.g., ease-in, ease-out',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: InputDecoration(
                labelText: 'Value',
                hintText: category == 'duration' ? 'e.g., 150ms, 300ms' : 'e.g., cubic-bezier(0.4, 0, 1, 1)',
                border: const OutlineInputBorder(),
                helperText: category == 'duration'
                    ? 'Duration in milliseconds (e.g., 150ms)'
                    : 'Easing function (e.g., ease-in, cubic-bezier(0.4, 0, 1, 1))',
              ),
            ),
            if (category == 'easing') ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'ease-in',
                  'ease-out',
                  'ease-in-out',
                  'linear',
                  'cubic-bezier(0.4, 0, 1, 1)',
                  'cubic-bezier(0, 0, 0.2, 1)',
                ].map((preset) {
                  return ActionChip(
                    label: Text(preset, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      valueController.text = preset;
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final motionTokens = provider.designSystem.motionTokens;

                final updatedDuration = Map<String, String>.from(motionTokens.duration);
                final updatedEasing = Map<String, String>.from(motionTokens.easing);

                if (category == 'duration') {
                  if (existingName != null && existingName != nameController.text) {
                    updatedDuration.remove(existingName);
                  }
                  updatedDuration[nameController.text] = valueController.text;
                } else {
                  if (existingName != null && existingName != nameController.text) {
                    updatedEasing.remove(existingName);
                  }
                  updatedEasing[nameController.text] = valueController.text;
                }

                provider.updateMotionTokens(models.MotionTokens(
                  duration: updatedDuration,
                  easing: updatedEasing,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category == 'duration' ? 'Duration' : 'Easing'} token "${nameController.text}" ${existingName != null ? 'updated' : 'added'}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(existingName != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showEditMotionTokenDialog(
    BuildContext context,
    String category,
    String name,
    String value,
  ) {
    _showMotionTokenDialog(context, category, name, value);
  }

  void _deleteMotionToken(BuildContext context, String category, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Motion Token'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final motionTokens = provider.designSystem.motionTokens;

              final updatedDuration = Map<String, String>.from(motionTokens.duration);
              final updatedEasing = Map<String, String>.from(motionTokens.easing);

              if (category == 'duration') {
                updatedDuration.remove(name);
              } else {
                updatedEasing.remove(name);
              }

              provider.updateMotionTokens(models.MotionTokens(
                duration: updatedDuration,
                easing: updatedEasing,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Motion token "$name" deleted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
