import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import 'colors_screen.dart';
import 'typography_screen.dart';
import 'design_library_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final designSystem = provider.designSystem;

    return Scaffold(
      appBar: AppBar(
        title: Text(designSystem.name.isEmpty ? 'Design System' : designSystem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Design Library',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DesignLibraryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Design Library',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Browse Material Design and Cupertino (iOS) components, colors, icons, and typography',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.blue.shade700,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DesignLibraryScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (designSystem.description.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    designSystem.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Design Tokens',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: _getCrossAxisCount(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.palette,
                  title: 'Colors',
                  description: 'Manage color palette',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ColorsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.text_fields,
                  title: 'Typography',
                  description: 'Fonts and text styles',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TypographyScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.space_bar,
                  title: 'Spacing',
                  description: 'Spacing scale',
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to spacing screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.rounded_corner,
                  title: 'Border Radius',
                  description: 'Corner radius values',
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Navigate to border radius screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.shadow,
                  title: 'Shadows',
                  description: 'Elevation and shadows',
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigate to shadows screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.auto_awesome,
                  title: 'Effects',
                  description: 'Glass morphism, overlays',
                  color: Colors.pink,
                  onTap: () {
                    // TODO: Navigate to effects screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.widgets,
                  title: 'Components',
                  description: 'Buttons, cards, inputs',
                  color: Colors.teal,
                  onTap: () {
                    // TODO: Navigate to components screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.grid_view,
                  title: 'Grid',
                  description: 'Layout grid system',
                  color: Colors.indigo,
                  onTap: () {
                    // TODO: Navigate to grid screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.image,
                  title: 'Icons',
                  description: 'Icon sizes',
                  color: Colors.amber,
                  onTap: () {
                    // TODO: Navigate to icons screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.gradient,
                  title: 'Gradients',
                  description: 'Gradient definitions',
                  color: Colors.cyan,
                  onTap: () {
                    // TODO: Navigate to gradients screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.people,
                  title: 'Roles',
                  description: 'Role-based theming',
                  color: Colors.red,
                  onTap: () {
                    // TODO: Navigate to roles screen
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.code,
                  title: 'Export',
                  description: 'Export to Flutter/Kotlin/Swift',
                  color: Colors.brown,
                  onTap: () {
                    // TODO: Navigate to export screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
