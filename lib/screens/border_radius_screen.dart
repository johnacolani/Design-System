import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class BorderRadiusScreen extends StatefulWidget {
  const BorderRadiusScreen({super.key});

  @override
  State<BorderRadiusScreen> createState() => _BorderRadiusScreenState();
}

class _BorderRadiusScreenState extends State<BorderRadiusScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final borderRadius = provider.designSystem.borderRadius;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Border Radius'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEditBorderRadiusDialog(context),
            tooltip: 'Add / Edit radius values',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditBorderRadiusDialog(context),
            tooltip: 'Edit all values',
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Text(
              'Pick any token to edit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Define corner radius values for consistent rounded corners. Use Add or Edit to change values.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            _buildRadiusRow(context, 'None', borderRadius.none),
            _buildRadiusRow(context, 'Small', borderRadius.sm),
            _buildRadiusRow(context, 'Base', borderRadius.base),
            _buildRadiusRow(context, 'Medium', borderRadius.md),
            _buildRadiusRow(context, 'Large', borderRadius.lg),
            _buildRadiusRow(context, 'Extra Large', borderRadius.xl),
            _buildRadiusRow(context, 'Full', borderRadius.full),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusRow(BuildContext context, String name, String value) {
    final radiusValue = _parseRadius(value);
    final radius = radiusValue >= 9999 ? 9999.0 : radiusValue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.12),
            borderRadius: radius >= 9999 ? BorderRadius.circular(24) : BorderRadius.circular(radius),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Center(
            child: Text(
              name[0],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontFamily: 'monospace')),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditBorderRadiusDialog(context),
          tooltip: 'Edit all radius values',
        ),
      ),
    );
  }

  double _parseRadius(String radius) {
    try {
      if (radius == '9999px' || radius == 'full') {
        return 9999;
      }
      return double.parse(radius.replaceAll('px', ''));
    } catch (e) {
      return 0;
    }
  }

  void _showEditBorderRadiusDialog(BuildContext context) {
    final screenContext = context;
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final borderRadius = provider.designSystem.borderRadius;

    final noneController = TextEditingController(text: borderRadius.none);
    final smController = TextEditingController(text: borderRadius.sm);
    final baseController = TextEditingController(text: borderRadius.base);
    final mdController = TextEditingController(text: borderRadius.md);
    final lgController = TextEditingController(text: borderRadius.lg);
    final xlController = TextEditingController(text: borderRadius.xl);
    final fullController = TextEditingController(text: borderRadius.full);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Border Radius Values'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noneController,
                decoration: const InputDecoration(
                  labelText: 'None',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: smController,
                decoration: const InputDecoration(
                  labelText: 'Small',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: baseController,
                decoration: const InputDecoration(
                  labelText: 'Base',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mdController,
                decoration: const InputDecoration(
                  labelText: 'Medium',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lgController,
                decoration: const InputDecoration(
                  labelText: 'Large',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: xlController,
                decoration: const InputDecoration(
                  labelText: 'Extra Large',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullController,
                decoration: const InputDecoration(
                  labelText: 'Full',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedBorderRadius = models.BorderRadius(
                none: noneController.text.trim().isEmpty ? borderRadius.none : noneController.text.trim(),
                sm: smController.text.trim().isEmpty ? borderRadius.sm : smController.text.trim(),
                base: baseController.text.trim().isEmpty ? borderRadius.base : baseController.text.trim(),
                md: mdController.text.trim().isEmpty ? borderRadius.md : mdController.text.trim(),
                lg: lgController.text.trim().isEmpty ? borderRadius.lg : lgController.text.trim(),
                xl: xlController.text.trim().isEmpty ? borderRadius.xl : xlController.text.trim(),
                full: fullController.text.trim().isEmpty ? borderRadius.full : fullController.text.trim(),
              );

              provider.updateDesignSystem(models.DesignSystem(
                name: provider.designSystem.name,
                version: provider.designSystem.version,
                description: provider.designSystem.description,
                created: provider.designSystem.created,
                colors: provider.designSystem.colors,
                typography: provider.designSystem.typography,
                spacing: provider.designSystem.spacing,
                borderRadius: updatedBorderRadius,
                shadows: provider.designSystem.shadows,
                effects: provider.designSystem.effects,
                components: provider.designSystem.components,
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
                semanticTokens: provider.designSystem.semanticTokens,
                motionTokens: provider.designSystem.motionTokens,
                lastModified: provider.designSystem.lastModified,
                versionHistory: provider.designSystem.versionHistory,
              ));

              Navigator.of(screenContext).pop();
              if (screenContext.mounted) {
                ScaffoldMessenger.of(screenContext).showSnackBar(
                  const SnackBar(
                    content: Text('Border radius updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
