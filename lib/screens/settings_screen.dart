import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Settings
          _buildSection(
            context,
            title: 'Account',
            children: [
              _buildListTile(
                context,
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Manage your profile information',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pop(); // Go back to profile
                },
              ),
              _buildListTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user?.email ?? 'Not set',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement email change
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email change feature coming soon'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.lock_outline,
                title: 'Password',
                subtitle: 'Change your password',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement password change
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password change feature coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),

          // App Settings
          _buildSection(
            context,
            title: 'App Settings',
            children: [
              _buildListTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                trailing: Switch(
                  value: true, // TODO: Implement notification settings
                  onChanged: (value) {},
                ),
                onTap: () {},
              ),
              _buildListTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Light mode',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement theme switching
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme switching coming soon'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement language selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Language selection coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),

          // Data & Privacy
          _buildSection(
            context,
            title: 'Data & Privacy',
            children: [
              _buildListTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Open privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Open terms of service
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms of service coming soon'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
          ),

          // Support
          _buildSection(
            context,
            title: 'Support',
            children: [
              _buildListTile(
                context,
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get help and support',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Open help center
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help center coming soon'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts with us',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback feature coming soon'),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Design System Builder',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.palette, size: 48),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'A comprehensive tool for creating, managing, and exporting design systems for Flutter, Kotlin, and Swift projects.',
          ),
        ),
      ],
    );
  }
}
