import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../providers/user_provider.dart';
import '../providers/design_system_provider.dart';
import '../services/project_service.dart';
import '../models/user.dart';
import '../models/design_system.dart' as models;
import '../utils/responsive.dart';
import '../widgets/app_logo.dart';
import '../widgets/hero_value_prop.dart';
import '../widgets/hero_lottie_background.dart';
import 'create_new_project_screen.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'auth_screen.dart';
import 'welcome_screen.dart';
import 'pricing_screen.dart';
import 'onboarding_checklist_screen.dart';
import 'tutorials_screen.dart';
import 'demo_gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProjectInfo> _projects = [];
  bool _isLoadingProjects = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        _loadProjects();
      }
    });
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    try {
      final list = await provider.getProjectList();
      if (mounted) setState(() {
        _projects = list;
        _isLoadingProjects = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _projects = [];
        _isLoadingProjects = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also clear snackbars when dependencies change (e.g., when navigating back)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final designSystemProvider = Provider.of<DesignSystemProvider>(context);

    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary.withOpacity(0.04),
              Colors.grey[50]!,
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar (Figma-style)
              _buildTopNavigation(context, userProvider),
              
              // Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 5-second value proposition — 3 lines + framework icons
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.responsive.isMobile ? 20 : 32,
                          context.responsive.isMobile ? 24 : 32,
                          context.responsive.isMobile ? 20 : 32,
                          8,
                        ),
                        child: HeroValueProp(
                          textColor: Colors.grey[900],
                          isMobile: context.responsive.isMobile,
                          showAccentBar: true,
                        ),
                      ),
                      // Hero Section with Project Previews
                      _buildHeroSection(context, designSystemProvider, userProvider),
                      
                      // Supporting tagline
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsive.isMobile ? 16 : 24,
                          vertical: context.responsive.isMobile ? 24 : 32,
                        ),
                        child: Text(
                          'Create, customize, and export one design system — then use it across Flutter, SwiftUI, Jetpack Compose, React, and Web.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                                height: 1.6,
                                fontSize: context.responsive.isMobile ? 14 : null,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Learn & explore
                      _buildLearnSection(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context, UserProvider userProvider) {
    final user = userProvider.currentUser;
    final responsive = Responsive(context);
    
    return Container(
      padding: responsive.padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLogo(
                  size: responsive.isMobile ? 32 : 40,
                ),
                SizedBox(width: responsive.isMobile ? 8 : 12),
                if (!responsive.isMobile)
                  Flexible(
                    child: Text(
                      'Design System Builder',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.isMobile ? 16 : null,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Right side: only Avatar and user email when logged in
          if (userProvider.isLoggedIn) ...[
            Flexible(
              child: Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontSize: responsive.isMobile ? 12 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                radius: responsive.isMobile ? 16 : 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'G',
                        style: TextStyle(
                          fontSize: responsive.isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
            // Overflow menu for Settings, My Projects, Pricing
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Menu',
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                } else if (value == 'projects') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                  );
                } else if (value == 'pricing') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PricingScreen()),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'projects', child: Row(children: [Icon(Icons.folder, size: 20), SizedBox(width: 12), Text('My Projects')])),
                const PopupMenuItem(value: 'pricing', child: Row(children: [Icon(Icons.credit_card, size: 20), SizedBox(width: 12), Text('Pricing')])),
                const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings, size: 20), SizedBox(width: 12), Text('Settings')])),
              ],
            ),
          ] else ...[
            if (!responsive.isMobile)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Text('Log in'),
              ),
            if (!responsive.isMobile) const SizedBox(width: 4),
            if (!responsive.isMobile)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PricingScreen()),
                  );
                },
                child: const Text('Pricing'),
              ),
            if (!responsive.isMobile) const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.isMobile ? 16 : 20,
                  vertical: responsive.isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                responsive.isMobile ? 'Start' : 'Get started',
                style: TextStyle(fontSize: responsive.isMobile ? 14 : null),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, DesignSystemProvider designSystemProvider, UserProvider userProvider) {
    final responsive = Responsive(context);

    // When we have projects, show Figma-style project preview grid (tap to open)
    if (_projects.isNotEmpty) {
      return _buildProjectPreviewGridSection(context, designSystemProvider, userProvider, responsive);
    }

    // No projects: show decorative previews + "Create your design system" CTA
    return SizedBox(
      height: responsive.isMobile ? 400 : responsive.isTablet ? 500 : 600,
      child: Stack(
        children: [
          HeroLottieBackground(isMobile: responsive.isMobile),
          Positioned.fill(
            child: Padding(
              padding: responsive.margin,
              child: _buildPlaceholderPreviewsGrid(context),
            ),
          ),
          Positioned(
            top: responsive.isMobile ? 120 : responsive.isTablet ? 150 : 200,
            left: 0,
            right: 0,
            child: Center(
              child: _buildFloatingCTACard(context, designSystemProvider, userProvider),
            ),
          ),
        ],
      ),
    );
  }

  /// Figma-style section: grid of project preview cards; tap to open project.
  Widget _buildProjectPreviewGridSection(
    BuildContext context,
    DesignSystemProvider designSystemProvider,
    UserProvider userProvider,
    Responsive responsive,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isMobile ? 16 : 32,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your projects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton.icon(
                onPressed: () => _navigateCreateProject(context, userProvider),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('New project'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingProjects)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: responsive.isMobile ? 320 : (responsive.isTablet ? 380 : 420),
              ),
              child: SingleChildScrollView(
                child: Builder(
                  builder: (context) {
                    final width = MediaQuery.sizeOf(context).width -
                        (responsive.isMobile ? 32.0 : 64.0);
                    final crossCount = responsive.isMobile ? 2 : (responsive.isTablet ? 3 : 4);
                    const spacing = 16.0;
                    final cardWidth = (width - spacing * (crossCount - 1)) / crossCount;
                    final w = cardWidth.clamp(140.0, 260.0);
                    final h = (w * 0.7).clamp(100.0, 180.0);
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        ..._projects.map((project) => _buildProjectPreviewCard(
                          context,
                          designSystemProvider,
                          project: project,
                          width: w,
                          height: h,
                        )),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateCreateProject(BuildContext context, UserProvider userProvider) {
    final firebaseAuth = firebase_auth.FirebaseAuth.instance;
    if (firebaseAuth.currentUser == null || !userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in or sign up to create a project'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WelcomeScreen()));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateNewProjectScreen()),
      );
    }
  }

  Future<void> _openProject(BuildContext context, DesignSystemProvider provider, ProjectInfo project) async {
    try {
      await provider.loadProjectFromPath(project.filePath);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
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

  // Muted, soft palettes so cards feel calm; pattern overlay tones them down further.
  static const List<List<Color>> _projectCardPalettes = [
    [Color(0xFF7C8DB5), Color(0xFF9BA8C9), Color(0xFFB8C1D4)],
    [Color(0xFF6B9BB5), Color(0xFF8FB0C7), Color(0xFFB3C8D9)],
    [Color(0xFF7A9E8E), Color(0xFF98B5A8), Color(0xFFB6CCC2)],
    [Color(0xFFB5A67C), Color(0xFFC9BE98), Color(0xFFDDD6B8)],
    [Color(0xFFB58A8A), Color(0xFFC7A5A5), Color(0xFFD9C0C0)],
    [Color(0xFFB58A9E), Color(0xFFC7A5B5), Color(0xFFD9C0CC)],
    [Color(0xFF7A9E9E), Color(0xFF98B5B5), Color(0xFFB6CCCC)],
    [Color(0xFF8A8AB5), Color(0xFFA5A5C7), Color(0xFFC0C0D9)],
  ];

  /// Deterministic gradient colors from project name (for card preview).
  List<Color> _colorsFromName(String name) {
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = (hash * 31 + name.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final palette = _projectCardPalettes[hash % _projectCardPalettes.length];
    return List<Color>.from(palette);
  }

  Widget _buildProjectPreviewCard(
    BuildContext context,
    DesignSystemProvider designSystemProvider, {
    required ProjectInfo project,
    required double width,
    required double height,
  }) {
    final colors = _colorsFromName(project.name);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openProject(context, designSystemProvider, project),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                  ),
                ),
                // Subtle dot pattern overlay to tone down the color
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotPatternPainter(
                      color: Colors.white.withOpacity(0.12),
                      spacing: 8,
                      radius: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.9), size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32),
                        onSelected: (value) {
                          if (value == 'open') {
                            _openProject(context, designSystemProvider, project);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'open',
                            child: Row(children: [Icon(Icons.open_in_new, size: 18), SizedBox(width: 8), Text('Open')]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (project.description.isNotEmpty)
                    Text(
                      project.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'v${project.version}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Placeholder preview cards when there are no projects (decorative only).
  Widget _buildPlaceholderPreviewsGrid(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: _buildPreviewCard(
            context,
            title: 'Material Design',
            colors: [Colors.blue, Colors.green, Colors.orange],
            rotation: -2,
          ),
        ),
        Positioned(
          top: 80,
          right: 0,
          child: _buildPreviewCard(
            context,
            title: 'Cupertino',
            colors: [Colors.purple, Colors.pink, Colors.blue],
            rotation: 2,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 100,
          child: _buildPreviewCard(
            context,
            title: 'Custom System',
            colors: [Colors.teal, Colors.cyan, Colors.indigo],
            rotation: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(
    BuildContext context, {
    required String title,
    String? description,
    required List<Color> colors,
    double rotation = 0,
    bool isActive = false,
  }) {
    final responsive = Responsive(context);
    final cardWidth = responsive.isMobile ? 200.0 : responsive.isTablet ? 240.0 : 280.0;
    final cardHeight = responsive.isMobile ? 150.0 : responsive.isTablet ? 175.0 : 200.0;
    
    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isActive
                ? BorderSide(color: colors[0], width: 2)
                : BorderSide.none,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCTACard(BuildContext context, DesignSystemProvider designSystemProvider, UserProvider userProvider) {
    final responsive = Responsive(context);
    // Shown only when there are no projects; when there are projects, hero shows project grid instead
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: responsive.isMobile ? double.infinity : responsive.isTablet ? 350 : 400,
      margin: responsive.margin,
      padding: EdgeInsets.all(responsive.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create your design system',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start building a comprehensive design system for your project',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Require authentication before creating a project
                // Check Firebase Auth directly to ensure user is actually logged in
                final firebaseAuth = firebase_auth.FirebaseAuth.instance;
                if (firebaseAuth.currentUser == null || !userProvider.isLoggedIn) {
                  // Show message and redirect to welcome screen for authentication
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please sign in or sign up to create a project'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                } else {
                  // User is logged in, allow project creation
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateNewProjectScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                userProvider.isLoggedIn ? 'Create New Project' : 'Get started',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnSection(BuildContext context) {
    final responsive = Responsive(context);
    final isMobile = responsive.isMobile;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn & explore',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _learnChip(context, 'Get started checklist', Icons.check_circle_outline, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OnboardingChecklistScreen()),
                );
              }),
              _learnChip(context, 'Tutorials', Icons.school_outlined, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TutorialsScreen()),
                );
              }),
              _learnChip(context, 'Demo projects', Icons.view_carousel_outlined, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DemoGalleryScreen()),
                );
              }),
              _learnChip(context, 'Pricing', Icons.credit_card_outlined, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PricingScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _learnChip(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildHeader(BuildContext context, UserProvider userProvider) {
    final user = userProvider.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'G',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user?.isPremium ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.role.displayName ?? 'Free Member',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Profile/Sign In button
          if (userProvider.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            )
          else
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
              icon: const Icon(Icons.login, color: Colors.white, size: 20),
              label: const Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner(BuildContext context, UserProvider userProvider) {
    if (userProvider.isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.pink.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚀 Upgrade to Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unlock unlimited projects, advanced exports, and priority support!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    userProvider.upgradeToPremium();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                  ),
                  child: const Text('Upgrade Now'),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    DesignSystemProvider designSystemProvider,
    UserProvider userProvider,
  ) {
    final user = userProvider.currentUser;
    final hasProject = designSystemProvider.hasProject;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.folder,
              label: 'Projects',
              value: '${user?.projectsCreated ?? 0}',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.palette,
              label: 'Design Systems',
              value: hasProject ? '1' : '0',
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.workspace_premium,
              label: 'Status',
              value: user?.isPremium == true ? 'Pro' : 'Free',
              color: user?.isPremium == true ? Colors.amber : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What You Can Do',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.auto_awesome,
            title: 'Browse Design Libraries',
            description: 'Import from Material Design & Cupertino',
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            icon: Icons.palette,
            title: 'Smart Color Suggestions',
            description: 'Get AI-powered color palettes and scales',
            color: Colors.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            icon: Icons.code,
            title: 'Multi-Platform Export',
            description: 'Generate code for Flutter, Kotlin & Swift',
            color: Colors.green,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectPreview(BuildContext context, DesignSystemProvider designSystemProvider) {
    final designSystem = designSystemProvider.designSystem;
    
    // Get primary color for accent
    Color? primaryColor;
    if (designSystem.colors.primary.isNotEmpty) {
      final firstColor = designSystem.colors.primary.values.first;
      final colorValue = firstColor is Map
          ? (firstColor)['value']?.toString() ?? '#000000'
          : firstColor.toString();
      primaryColor = _parseColor(colorValue);
    }
    primaryColor ??= Theme.of(context).colorScheme.primary;

    // Count items
    final colorCount = designSystem.colors.primary.length + designSystem.colors.semantic.length;
    final typographyCount = designSystem.typography.textStyles.length;
    final componentCount = designSystem.components.buttons.length +
        designSystem.components.cards.length +
        designSystem.components.inputs.length +
        designSystem.components.navigation.length +
        designSystem.components.avatars.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            designSystem.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (designSystem.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              designSystem.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Stats row
                Row(
                  children: [
                    _buildStatChip(
                      context,
                      Icons.color_lens,
                      '$colorCount Colors',
                      primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      Icons.text_fields,
                      '$typographyCount Styles',
                      primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      Icons.widgets,
                      '$componentCount Components',
                      primaryColor,
                    ),
                  ],
                ),
                
                // Color preview
                if (colorCount > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Color Palette',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildColorPreviewMini(context, designSystem),
                ],
                
                const SizedBox(height: 20),
                
                // Edit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Continue Editing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPreviewMini(BuildContext context, models.DesignSystem ds) {
    final colors = <String, dynamic>{};
    colors.addAll(ds.colors.primary);
    if (ds.colors.semantic.isNotEmpty) {
      colors.addAll(ds.colors.semantic);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.entries.take(6).map((entry) {
        final colorValue = entry.value is Map
            ? (entry.value as Map)['value']?.toString() ?? '#000000'
            : entry.value.toString();
        final color = _parseColor(colorValue) ?? Colors.grey;
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color? _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if missing
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  Widget _buildCallToAction(BuildContext context, UserProvider userProvider) {
    final designSystemProvider = Provider.of<DesignSystemProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!designSystemProvider.hasProject)
            Card(
              elevation: 3,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to Create Your Design System?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start building your design system in minutes',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateNewProjectScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Project'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (designSystemProvider.hasProject) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Go to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                      );
                    },
                    icon: const Icon(Icons.folder),
                    label: const Text('My Projects'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Paints a subtle dot grid pattern (used on project preview cards).
class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({required this.color, this.spacing = 8, this.radius = 1});

  final Color color;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
