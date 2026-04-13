import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/design_system_provider.dart';
import '../utils/download_helper.dart';
import '../providers/user_provider.dart';
import '../utils/responsive.dart';
import '../services/project_service.dart';
import '../models/design_system.dart' as models;
import 'colors_screen.dart';
import 'profile_screen.dart';
import 'typography_screen.dart';
import 'spacing_screen.dart';
import 'border_radius_screen.dart';
import 'shadows_screen.dart';
import 'effects_screen.dart';
import 'components_screen.dart';
import 'ui_lab_screen.dart';
import 'grid_screen.dart';
import 'icons_screen.dart';
import 'gradients_screen.dart';
import 'roles_screen.dart';
import 'export_screen.dart';
import 'preview_screen.dart';
import 'design_library_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';
import 'semantic_tokens_screen.dart';
import 'version_history_screen.dart';
import 'motion_tokens_screen.dart';
import 'docs_screen.dart';
import 'component_gallery_screen.dart';
import 'platform_pickers_dialogs_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleSaveToComputer(BuildContext context, models.DesignSystem ds) async {
    try {
      if (kIsWeb) {
        // file_picker saveFile() is not implemented on web; trigger browser download
        final jsonString = await ProjectService.exportProject(ds, '');
        final fileName = '${ds.name.replaceAll(' ', '_')}.ds.json';
        downloadFile(jsonString, fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design System saved to computer!'), backgroundColor: Colors.green),
          );
        }
        return;
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Design System',
        fileName: '${ds.name.replaceAll(' ', '_')}.ds.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        await ProjectService.exportProject(ds, outputFile);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Design System saved to computer!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving to computer: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final designSystem = provider.designSystem;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
            );
          },
          tooltip: 'Home',
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(designSystem.name.isEmpty ? 'Design System' : designSystem.name),
            if (provider.isMultiPlatform)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SegmentedButton<String>(
                  segments: provider.targetPlatforms
                      .map((p) => ButtonSegment<String>(
                            value: p,
                            label: Text(p == 'ios' ? 'iOS' : p == 'android' ? 'Android' : 'Web'),
                          ))
                      .toList(),
                  selected: {provider.currentPlatform ?? provider.targetPlatforms.first},
                  onSelectionChanged: (Set<String> sel) {
                    provider.setCurrentPlatform(sel.first);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.currentUser;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'G',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.computer),
            tooltip: 'Save to Computer',
            onPressed: () => _handleSaveToComputer(context, designSystem),
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Progress',
            onPressed: () async {
              try {
                await provider.saveProject();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress saved successfully!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
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
            icon: const Icon(Icons.history),
            tooltip: 'Version History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VersionHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'My Projects',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProjectsScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = (width * 0.15).clamp(24.0, 80.0);
          final verticalPadding = context.responsive.isMobile ? 16.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
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
              crossAxisCount: context.responsive.gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: context.responsive.isMobile ? 12 : 16,
              mainAxisSpacing: context.responsive.isMobile ? 12 : 16,
              childAspectRatio: context.responsive.isMobile ? 1.1 : 1.2,
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SpacingScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.rounded_corner,
                  title: 'Border Radius',
                  description: 'Corner radius values',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BorderRadiusScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.auto_awesome,
                  title: 'Shadows',
                  description: 'Elevation and shadows',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ShadowsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.auto_awesome,
                  title: 'Effects',
                  description: 'Glass morphism, overlays',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EffectsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.widgets,
                  title: 'Components',
                  description: 'Buttons, cards, inputs',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ComponentsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.science_outlined,
                  title: 'UI Lab',
                  description: 'Experiment with components (Storybook-style)',
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UILabScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.grid_view,
                  title: 'Grid',
                  description: 'Layout grid system',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GridScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.image,
                  title: 'Icons',
                  description: 'Icon sizes',
                  color: Colors.amber,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const IconsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.gradient,
                  title: 'Gradients',
                  description: 'Gradient definitions',
                  color: Colors.cyan,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GradientsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.people,
                  title: 'Roles',
                  description: 'Role-based theming',
                  color: Colors.red,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RolesScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.label_important,
                  title: 'Semantic Tokens',
                  description: 'Purpose-driven tokens',
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SemanticTokensScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.animation,
                  title: 'Motion Tokens',
                  description: 'Animation duration & easing',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MotionTokensScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.preview,
                  title: 'Preview',
                  description: 'Visual preview of design system',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PreviewScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.date_range,
                  title: 'Pickers & dialogs',
                  description: 'Material & Cupertino date/time + alerts',
                  color: Colors.lightBlue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlatformPickersDialogsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.code,
                  title: 'Export',
                  description: 'Export to Flutter/Kotlin/Swift',
                  color: Colors.brown,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExportScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.menu_book,
                  title: 'Documentation',
                  description: 'Docs from assets or Firestore (cached)',
                  color: Colors.blueGrey,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DocsScreen()),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.view_carousel,
                  title: 'Component Gallery',
                  description: 'Lazy-loaded components by category',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ComponentGalleryScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _HoverableFeatureCard(
      icon: icon,
      title: title,
      description: description,
      color: color,
      onTap: onTap,
    );
  }
}

class _HoverableFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _HoverableFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverableFeatureCard> createState() => _HoverableFeatureCardState();
}

class _HoverableFeatureCardState extends State<_HoverableFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Card(
            elevation: _isHovered ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}
