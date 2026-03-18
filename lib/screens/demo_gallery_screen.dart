import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/demo_design_systems.dart';
import '../providers/design_system_provider.dart';
import 'dashboard_screen.dart';

/// Demo projects: tap to load a full preset into the editor (then save as your project).
class DemoGalleryScreen extends StatelessWidget {
  const DemoGalleryScreen({super.key});

  static const List<_DemoProject> _demos = [
    _DemoProject(
      id: DemoDesignSystems.mobileUiKit,
      title: 'Mobile UI Kit',
      subtitle: 'Touch targets, tab bar, cards, search — app-ready tokens.',
      icon: Icons.phone_android,
      color: Color(0xFF2563EB),
      accentColors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF93C5FD)],
    ),
    _DemoProject(
      id: DemoDesignSystems.adminDashboard,
      title: 'Admin Dashboard',
      subtitle: 'Tables, dense UI, sidebar, data-tool modals & alerts.',
      icon: Icons.dashboard_outlined,
      color: Color(0xFF4F46E5),
      accentColors: [Color(0xFF1E1B4B), Color(0xFF4F46E5), Color(0xFFE2E8F0)],
    ),
    _DemoProject(
      id: DemoDesignSystems.landingPage,
      title: 'Landing Page',
      subtitle: 'Hero gradient, bold type, pill CTAs, pricing-style cards.',
      icon: Icons.language,
      color: Color(0xFF0D9488),
      accentColors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFFF97316)],
    ),
  ];

  Future<void> _onDemoTap(BuildContext context, _DemoProject demo) async {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Load “${demo.title}”?'),
        content: Text(
          'This loads a full demo design system into the editor (colors, typography, components, and more). '
          'Save your current project from the dashboard first if you have unsaved work. '
          'Use Save to computer or create a project to keep this demo as your own.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Load demo')),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    provider.loadDemoDesignSystem(demo.id);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => const DashboardScreen()));
    messenger.showSnackBar(
      SnackBar(
        content: Text('Loaded “${demo.title}”. Save to keep it as a project.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final padH = width < 600 ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Demo projects'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padH, 20, padH, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try a full example',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Each demo is a real design system preset. Tap to load it, explore the dashboard, then save as your own project.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(padH, 16, padH, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final d = _demos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _DemoHeroCard(
                        demo: d,
                        onTap: () => _onDemoTap(context, d),
                      ),
                    );
                  },
                  childCount: _demos.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoProject {
  const _DemoProject({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accentColors,
  });
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> accentColors;
}

class _DemoHeroCard extends StatelessWidget {
  const _DemoHeroCard({required this.demo, required this.onTap});

  final _DemoProject demo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: demo.accentColors.length >= 3
                            ? demo.accentColors
                            : [demo.color, demo.color.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Icon(demo.icon, size: 56, color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: demo.color),
                              const SizedBox(width: 6),
                              Text(
                                'Full preset',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: demo.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    demo.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    demo.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Tap to load in editor',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 18, color: theme.colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
