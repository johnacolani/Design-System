import 'package:flutter/material.dart';

/// Tutorials page with sample entries and link placeholders (no external URLs).
class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  static const List<_TutorialEntry> _tutorials = [
    _TutorialEntry(
      title: 'Design tokens in 5 minutes',
      description: 'Set up colors, spacing, and typography as tokens and use them across your system.',
      duration: '5 min',
      icon: Icons.palette_outlined,
    ),
    _TutorialEntry(
      title: 'Building your first component',
      description: 'Create a reusable button and card, then preview them in the UI Lab.',
      duration: '10 min',
      icon: Icons.widgets_outlined,
    ),
    _TutorialEntry(
      title: 'Export to Flutter and React',
      description: 'Export your design system as code and plug it into your app.',
      duration: '7 min',
      icon: Icons.code,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _tutorials.length,
        itemBuilder: (context, index) {
          final t = _tutorials[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(t.icon, color: theme.colorScheme.onPrimaryContainer),
              ),
              title: Text(
                t.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    t.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        t.duration,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tutorial: ${t.title} (link placeholder)'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TutorialEntry {
  const _TutorialEntry({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
  });
  final String title;
  final String description;
  final String duration;
  final IconData icon;
}
