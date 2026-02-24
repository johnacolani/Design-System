import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

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
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditBorderRadiusDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Border Radius Values',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define corner radius values for consistent rounded corners',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          _buildBorderRadiusCard(context, 'None', borderRadius.none, 'No rounding'),
          _buildBorderRadiusCard(context, 'Small', borderRadius.sm, 'Small rounded corners'),
          _buildBorderRadiusCard(context, 'Base', borderRadius.base, 'Default rounded corners'),
          _buildBorderRadiusCard(context, 'Medium', borderRadius.md, 'Medium rounded corners'),
          _buildBorderRadiusCard(context, 'Large', borderRadius.lg, 'Large rounded corners'),
          _buildBorderRadiusCard(context, 'Extra Large', borderRadius.xl, 'Extra large rounded corners'),
          _buildBorderRadiusCard(context, 'Full', borderRadius.full, 'Fully rounded (circle)'),
        ],
      ),
    );
  }

  Widget _buildBorderRadiusCard(
    BuildContext context,
    String name,
    String value,
    String description,
  ) {
    final radiusValue = _parseRadius(value);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(radiusValue),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
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
    final provider = Provider.of<DesignSystemProvider>(context);
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
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedBorderRadius = models.BorderRadius(
                none: noneController.text,
                sm: smController.text,
                base: baseController.text,
                md: mdController.text,
                lg: lgController.text,
                xl: xlController.text,
                full: fullController.text,
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
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Border radius updated!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
