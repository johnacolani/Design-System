import 'package:flutter/material.dart';

/// Demo projects gallery: Mobile UI kit, Admin dashboard, Landing page.
class DemoGalleryScreen extends StatelessWidget {
  const DemoGalleryScreen({super.key});

  static const List<_DemoProject> _demos = [
    _DemoProject(
      title: 'Mobile UI kit',
      description: 'Components and tokens for a mobile app: buttons, cards, inputs, navigation.',
      icon: Icons.phone_android,
      color: Colors.blue,
    ),
    _DemoProject(
      title: 'Admin dashboard',
      description: 'Data tables, charts, sidebars, and forms for internal tools.',
      icon: Icons.dashboard,
      color: Colors.indigo,
    ),
    _DemoProject(
      title: 'Landing page',
      description: 'Hero, features, pricing, and footer sections for marketing pages.',
      icon: Icons.language,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo projects'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 48,
          vertical: 24,
        ),
        children: [
          Text(
            'Explore example design systems. Duplicate and customize for your product.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ..._demos.map((d) => _DemoCard(demo: d, theme: theme)),
        ],
      ),
    );
  }
}

class _DemoProject {
  const _DemoProject({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo, required this.theme});

  final _DemoProject demo;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening "${demo.title}" (demo placeholder)'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: demo.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(demo.icon, color: demo.color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demo.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
