import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import 'dashboard_screen.dart';
import 'colors_screen.dart';
import 'components_screen.dart';
import 'ui_lab_screen.dart';
import 'export_screen.dart';
import 'projects_screen.dart';

/// Onboarding checklist: Create tokens → First component → Preview → Export.
/// Each step links to the right screen; completion is derived from design system state.
class OnboardingChecklistScreen extends StatelessWidget {
  const OnboardingChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<DesignSystemProvider>(context);
    final ds = provider.designSystem;
    final hasProject = provider.hasProject && ds.name.isNotEmpty;

    final steps = [
      _ChecklistStep(
        title: 'Create tokens',
        subtitle: 'Define colors, spacing, typography',
        done: _hasTokens(ds),
        onTap: () => _openProjectThen(context, provider, () => const ColorsScreen()),
      ),
      _ChecklistStep(
        title: 'Create your first component',
        subtitle: 'Add a button, card, or input',
        done: _hasComponents(ds),
        onTap: () => _openProjectThen(context, provider, () => const ComponentsScreen()),
      ),
      _ChecklistStep(
        title: 'Preview in playground',
        subtitle: 'Try components in the UI Lab',
        done: hasProject,
        onTap: () => _openProjectThen(context, provider, () => const UILabScreen()),
      ),
      _ChecklistStep(
        title: 'Export code',
        subtitle: 'Get Flutter, React, Swift, or CSS',
        done: hasProject,
        onTap: () => _openProjectThen(context, provider, () => const ExportScreen()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get started'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Finish these steps to get the most out of your design system.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ...steps.map((s) => _StepCard(
                step: s,
                theme: theme,
              )),
        ],
      ),
    );
  }

  bool _hasTokens(dynamic ds) {
    if (ds == null) return false;
    try {
      return ds.colors.primary.isNotEmpty || ds.spacing.values.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _hasComponents(dynamic ds) {
    if (ds == null) return false;
    try {
      return ds.components.buttons.isNotEmpty || ds.components.cards.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _openProjectThen(
    BuildContext context,
    DesignSystemProvider provider,
    Widget Function() screen,
  ) {
    if (!provider.hasProject || provider.designSystem.name.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProjectsScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen()),
    );
  }
}

class _ChecklistStep {
  const _ChecklistStep({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.theme});

  final _ChecklistStep step;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: step.done
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: step.done
              ? Icon(Icons.check, color: theme.colorScheme.primary)
              : Text(
                  step.title[0],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        title: Text(step.title),
        subtitle: Text(step.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: step.onTap,
      ),
    );
  }
}
