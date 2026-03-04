import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../utils/screen_body_padding.dart';
import 'settings_screen.dart';
import 'upgrade_screen.dart';
import 'pricing_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.role.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: user.role.color, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isPremium ? Icons.workspace_premium : Icons.person,
                          size: 16,
                          color: user.role.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.role.displayName,
                          style: TextStyle(
                            color: user.role.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Stats section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Projects',
                      '${user.projectsCreated}',
                      Icons.folder,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Member Since',
                      _formatDate(user.createdAt),
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ),

            // Account section
            _buildSection(
              context,
              title: 'Account',
              children: [
                _buildListTile(
                  context,
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: user.email,
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.badge,
                  title: 'Membership',
                  subtitle: user.role.displayName,
                  trailing: user.isPremium
                      ? null
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                            );
                          },
                          child: const Text('Upgrade'),
                        ),
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.credit_card,
                  title: 'Pricing',
                  subtitle: 'View plans and features',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PricingScreen()),
                    );
                  },
                ),
              ],
            ),

            // Actions section
            _buildSection(
              context,
              title: 'Actions',
              children: [
                _buildListTile(
                  context,
                  icon: Icons.workspace_premium,
                  title: 'Upgrade to Pro',
                  subtitle: 'Unlock unlimited features',
                  trailing: user.isPremium
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    if (!user.isPremium) {
                      userProvider.upgradeToPremium();
                    }
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                _buildListTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {
                  userProvider.logout();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
