import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tutorials: each entry can open an external URL (docs, video, blog).
/// Change [resourceUrl] below to your own links anytime—no other code needed.
class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  /// Edit these URLs to match your docs site, YouTube playlist, or Notion guides.
  static final List<_TutorialEntry> _tutorials = [
    _TutorialEntry(
      title: 'Design tokens in 5 minutes',
      description:
          'Set up colors, spacing, and typography as tokens and use them across your system.',
      duration: '5 min',
      icon: Icons.palette_outlined,
      resourceUrl: Uri.parse('https://m3.material.io/foundations/design-tokens/overview'),
      linkLabel: 'Material Design — Design tokens',
    ),
    _TutorialEntry(
      title: 'Building your first component',
      description:
          'Create reusable UI (buttons, cards) and preview them—similar ideas apply in Flutter & React.',
      duration: '10 min',
      icon: Icons.widgets_outlined,
      resourceUrl: Uri.parse('https://docs.flutter.dev/ui/widgets-intro'),
      linkLabel: 'Flutter — Widgets intro',
    ),
    _TutorialEntry(
      title: 'Export to Flutter and React',
      description:
          'Use this app’s Export screen for Flutter, React, CSS, and JSON. These guides help you use exported code.',
      duration: '7 min',
      icon: Icons.code,
      resourceUrl: Uri.parse('https://docs.flutter.dev/ui/design/material'),
      linkLabel: 'Flutter — Material theming',
    ),
    _TutorialEntry(
      title: 'React — styling & components',
      description: 'Pair exported CSS/tokens with React components and design systems.',
      duration: '6 min',
      icon: Icons.javascript_outlined,
      resourceUrl: Uri.parse('https://react.dev/learn'),
      linkLabel: 'React — Learn',
    ),
  ];

  static Future<void> _openTutorial(BuildContext context, _TutorialEntry t) async {
    final uri = t.resourceUrl;
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('“${t.title}” has no link yet. Add a URL in lib/screens/tutorials_screen.dart.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link. Check your browser or device settings.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Tap a tutorial to open a guide in your browser. You can point these links to your own docs by editing the list in the app code.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ..._tutorials.map((t) {
            final hasLink = t.resourceUrl != null;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _openTutorial(context, t),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(t.icon, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                            if (hasLink && t.linkLabel != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      t.linkLabel!,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
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
    this.resourceUrl,
    this.linkLabel,
  });
  final String title;
  final String description;
  final String duration;
  final IconData icon;
  /// If null, tap shows a hint to add a URL in code.
  final Uri? resourceUrl;
  /// Shown under the card (e.g. site name).
  final String? linkLabel;
}
