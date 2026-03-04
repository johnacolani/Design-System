import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../providers/billing_provider.dart';
import '../services/feature_gate_service.dart';
import '../utils/screen_body_padding.dart';
import '../widgets/billing/locked_badge.dart';
import '../widgets/billing/upgrade_modal.dart';
import 'upgrade_screen.dart';

class VersionHistoryScreen extends StatelessWidget {
  const VersionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final billingProvider = Provider.of<BillingProvider>(context);
    final gate = const FeatureGateService();
    final canUseTeam = gate.canUseTeamFeatures(billingProvider.plan);
    final designSystem = provider.designSystem;
    final versionHistory = designSystem.versionHistory ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Version History'),
        actions: [
          if (!canUseTeam)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: LockedBadge(
                requiredPlan: 'Team',
                onTap: () => _showTeamUpgradeModal(context),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: canUseTeam
                ? () => _showAddVersionDialog(context, provider)
                : () => _showTeamUpgradeModal(context),
            tooltip: canUseTeam ? 'Add Version' : 'Team feature — Upgrade',
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: versionHistory.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No version history',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddVersionDialog(context, provider);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Version'),
                  ),
                ],
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: versionHistory.length,
              itemBuilder: (context, index) {
                final version = versionHistory[index];
                final isCurrent = version.version == designSystem.version;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isCurrent ? Colors.blue.shade50 : null,
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.blue : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'v${version.version}',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'Version ${version.version}',
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      _formatDate(version.date),
                      style: TextStyle(
                        color: isCurrent ? Colors.blue[700] : Colors.grey[600],
                      ),
                    ),
                    trailing: isCurrent
                        ? Chip(
                            label: const Text('Current', style: TextStyle(fontSize: 11)),
                            backgroundColor: Colors.blue,
                            labelStyle: const TextStyle(color: Colors.white),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (version.description != null && version.description!.isNotEmpty) ...[
                              Text(
                                'Description',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(version.description!),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              'Changes',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...version.changes.map((change) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(change)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showAddVersionDialog(BuildContext context, DesignSystemProvider provider) {
    final versionController = TextEditingController(text: _incrementVersion(provider.designSystem.version));
    final descriptionController = TextEditingController();
    final changesController = TextEditingController();
    final changes = <String>[];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Version'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: versionController,
                  decoration: const InputDecoration(
                    labelText: 'Version (e.g., 1.1.0)',
                    border: OutlineInputBorder(),
                    helperText: 'Use semantic versioning (major.minor.patch)',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Brief description of this version',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Changes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: changesController,
                  decoration: const InputDecoration(
                    labelText: 'Add change',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Added new color palette',
                    suffixIcon: Icon(Icons.add),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setDialogState(() {
                        changes.add(value);
                        changesController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (changes.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: changes.map((change) {
                      return Chip(
                        label: Text(change),
                        onDeleted: () {
                          setDialogState(() {
                            changes.remove(change);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    if (changesController.text.isNotEmpty) {
                      setDialogState(() {
                        changes.add(changesController.text);
                        changesController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Change'),
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
                if (versionController.text.isNotEmpty && changes.isNotEmpty) {
                  provider.addVersionHistory(
                    versionController.text,
                    changes,
                    description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Version ${versionController.text} added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add Version'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamUpgradeModal(BuildContext context) {
    UpgradeModal.show(
      context,
      featureName: 'Team collaboration & versioning',
      requiredPlan: 'Team',
      description: 'Add and manage version history is available on the Team plan.',
      onUpgrade: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen(selectedPlan: 'team')),
        );
      },
    );
  }

  String _incrementVersion(String currentVersion) {
    try {
      final parts = currentVersion.split('.');
      if (parts.length == 3) {
        final patch = int.parse(parts[2]);
        return '${parts[0]}.${parts[1]}.${patch + 1}';
      }
    } catch (e) {
      // Invalid version format
    }
    return '1.0.1';
  }
}
