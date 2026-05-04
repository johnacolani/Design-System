import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/design_system_provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../services/project_service.dart';
import 'create_new_project_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import '../utils/screen_body_padding.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectInfo> _projects = [];
  bool _isLoading = true;
  UserProvider? _userProvider;
  String? _lastListUidKey;

  String _uidKeyForProjectList(UserProvider userProvider) {
    if (!userProvider.isLoggedIn) return 'guest';
    return userProvider.currentUser!.id;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProvider!.addListener(_onUserIdentityChangedForProjects);
      ScaffoldMessenger.of(context).clearSnackBars();
      _loadProjects();
    });
  }

  void _onUserIdentityChangedForProjects() {
    if (!mounted) return;
    final userProvider = _userProvider;
    if (userProvider == null) return;
    final key = _uidKeyForProjectList(userProvider);
    if (key == _lastListUidKey) return;
    _loadProjects();
  }

  @override
  void dispose() {
    _userProvider?.removeListener(_onUserIdentityChangedForProjects);
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final key = _uidKeyForProjectList(userProvider);
      final uid = userProvider.isLoggedIn ? userProvider.currentUser!.id : null;
      final projects = await provider.getProjectList(firebaseUid: uid);
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
          _lastListUidKey = key;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CreateNewProjectScreen()),
              );
            },
            tooltip: 'New Project',
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _projects.isEmpty
                ? _buildEmptyState()
                : _buildProjectsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first design system project',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CreateNewProjectScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Project'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return _buildProjectCard(project);
        },
      ),
    );
  }

  Widget _buildProjectCard(ProjectInfo project) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.palette, color: Colors.blue),
              if (project.fromCloud)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.cloud_done, size: 18, color: Colors.blue.shade800),
                ),
            ],
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'v${project.version}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Modified ${dateFormat.format(project.modified)} at ${timeFormat.format(project.modified)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: 'Duplicate',
              onPressed: () => _duplicateProject(project),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'open') {
                  await _openProject(project);
                } else if (value == 'duplicate') {
                  await _duplicateProject(project);
                } else if (value == 'delete') {
                  await _deleteProject(project);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 18),
                      SizedBox(width: 8),
                      Text('Open'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_all_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Duplicate…'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _openProject(project),
      ),
    );
  }

  Future<void> _duplicateProject(ProjectInfo project) async {
    final suggested = '${project.name} Copy';
    final controller = TextEditingController(text: suggested);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicate project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New project name',
            border: OutlineInputBorder(),
            helperText: 'Creates a full copy you can edit (colors, typography, etc.).',
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (confirmed != true || !mounted) return;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a project name.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.isLoggedIn ? userProvider.currentUser!.id : null;
    final isAdmin = userProvider.userRole == UserRole.admin;
    final adminSnapshot = isAdmin && uid != null && !uid.startsWith('guest_');

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    Object? cloudErr;
    late final String newPath;
    try {
      newPath = await provider.duplicateProjectFromPath(
        project.filePath,
        name,
        firebaseUid: uid,
        onCloudSyncCompleted: (e) => cloudErr = e,
        snapshotToAdminDesignSystems: adminSnapshot,
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicate failed: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();

    await _loadProjects();

    if (!mounted) return;

    Future<void> openDuplicate() async {
      try {
        final p = Provider.of<DesignSystemProvider>(context, listen: false);
        final u = Provider.of<UserProvider>(context, listen: false).isLoggedIn
            ? Provider.of<UserProvider>(context, listen: false).currentUser!.id
            : null;
        await p.loadProjectFromPath(newPath, firebaseUid: u);
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open duplicate: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    final snack = SnackBar(
      content: Text(
        cloudErr != null
            ? 'Duplicate saved on device; cloud sync failed: $cloudErr'
            : adminSnapshot
                ? 'Duplicate created: "$name". Synced to Firebase (projects + admin snapshot).\n'
                    'In Colors → Add, use Browse schemes (Monochromatic, Triadic, Tetradic…).'
                : 'Duplicate created: "$name".\n'
                    'In Colors → Add, use Browse schemes (Monochromatic, Triadic, Tetradic…).',
      ),
      backgroundColor: cloudErr != null ? Colors.orange : Colors.green,
      action: SnackBarAction(
        label: 'Open',
        textColor: Colors.white,
        onPressed: () => openDuplicate(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<void> _openProject(ProjectInfo project) async {
    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final uid = userProvider.isLoggedIn ? userProvider.currentUser!.id : null;
      await provider.loadProjectFromPath(project.filePath, firebaseUid: uid);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(ProjectInfo project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<DesignSystemProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final uid = userProvider.isLoggedIn ? userProvider.currentUser!.id : null;
        await provider.deleteProject(project.filePath, firebaseUid: uid);
        await _loadProjects();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
