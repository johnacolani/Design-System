import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/design_system_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/admin_design_system_service.dart';

class AdminDesignSystemScreen extends StatefulWidget {
  const AdminDesignSystemScreen({super.key});

  @override
  State<AdminDesignSystemScreen> createState() => _AdminDesignSystemScreenState();
}

class _AdminDesignSystemScreenState extends State<AdminDesignSystemScreen> {
  bool _isSaving = false;

  Future<void> _saveCurrentDesignSystem() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final designSystemProvider =
        Provider.of<DesignSystemProvider>(context, listen: false);

    final user = userProvider.currentUser;
    if (user == null || user.role != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only admins can save to Firebase from this section.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await AdminDesignSystemService.saveDesignSystemForAdmin(
        adminUserId: user.id,
        designSystem: designSystemProvider.rawDesignSystem,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design system saved to Firebase.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to Firebase: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Firebase Save'),
      ),
      body: !isAdmin
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'This section is restricted to admin users.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin actions',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Save the current design system snapshot to Firebase under your admin account.',
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveCurrentDesignSystem,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                _isSaving
                                    ? 'Saving...'
                                    : 'Save Current Design System to Firebase',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<AdminSavedDesignSystemItem>>(
                    stream: AdminDesignSystemService.watchSavedDesignSystems(
                      adminUserId: user!.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('Failed to load saved entries: ${snapshot.error}'),
                          ),
                        );
                      }
                      final items = snapshot.data ?? const [];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('No saved design systems yet.'),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final dateText = item.savedAt == null
                              ? 'Pending timestamp...'
                              : DateFormat('MMM d, yyyy • HH:mm')
                                  .format(item.savedAt!.toLocal());
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.description_outlined),
                              title: Text(item.name),
                              subtitle: Text(
                                'v${item.version}\n$dateText'
                                '${item.description.isNotEmpty ? '\n${item.description}' : ''}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
