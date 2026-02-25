import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class GridScreen extends StatefulWidget {
  const GridScreen({super.key});

  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final grid = provider.designSystem.grid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditGridDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Grid Configuration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define columns, gutters, margins, and breakpoints',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          _buildGridCard(
            context,
            'Columns',
            grid.columns.toString(),
            'Number of columns in the grid',
            Icons.view_column,
          ),
          _buildGridCard(
            context,
            'Gutter',
            grid.gutter,
            'Spacing between columns',
            Icons.space_bar,
          ),
          _buildGridCard(
            context,
            'Margin',
            grid.margin,
            'Outer margin of the grid',
            Icons.margin,
          ),
          const SizedBox(height: 16),
          Text(
            'Breakpoints',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...grid.breakpoints.entries.map((entry) {
            return _buildBreakpointCard(context, entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    String name,
    String value,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
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

  Widget _buildBreakpointCard(BuildContext context, String name, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.aspect_ratio, color: Colors.orange),
        title: Text(
          name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  void _showEditGridDialog(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final grid = provider.designSystem.grid;

    final columnsController = TextEditingController(text: grid.columns.toString());
    final gutterController = TextEditingController(text: grid.gutter);
    final marginController = TextEditingController(text: grid.margin);
    final mobileController = TextEditingController(text: grid.breakpoints['mobile'] ?? '');
    final tabletController = TextEditingController(text: grid.breakpoints['tablet'] ?? '');
    final desktopController = TextEditingController(text: grid.breakpoints['desktop'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Grid System'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: columnsController,
                decoration: const InputDecoration(
                  labelText: 'Columns',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gutterController,
                decoration: const InputDecoration(
                  labelText: 'Gutter (e.g., 16px)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: marginController,
                decoration: const InputDecoration(
                  labelText: 'Margin (e.g., 16px)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Breakpoints', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile (e.g., 360px)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tabletController,
                decoration: const InputDecoration(
                  labelText: 'Tablet (e.g., 768px)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: desktopController,
                decoration: const InputDecoration(
                  labelText: 'Desktop (e.g., 1200px)',
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
              final columns = int.tryParse(columnsController.text) ?? 12;
              final updatedGrid = models.Grid(
                columns: columns,
                gutter: gutterController.text,
                margin: marginController.text,
                breakpoints: {
                  'mobile': mobileController.text,
                  'tablet': tabletController.text,
                  'desktop': desktopController.text,
                },
              );

              provider.updateDesignSystem(models.DesignSystem(
                name: provider.designSystem.name,
                version: provider.designSystem.version,
                description: provider.designSystem.description,
                created: provider.designSystem.created,
                colors: provider.designSystem.colors,
                typography: provider.designSystem.typography,
                spacing: provider.designSystem.spacing,
                borderRadius: provider.designSystem.borderRadius,
                shadows: provider.designSystem.shadows,
                effects: provider.designSystem.effects,
                components: provider.designSystem.components,
                grid: updatedGrid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
                semanticTokens: provider.designSystem.semanticTokens,
                motionTokens: provider.designSystem.motionTokens,
                lastModified: provider.designSystem.lastModified,
                versionHistory: provider.designSystem.versionHistory,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grid system updated!'),
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
