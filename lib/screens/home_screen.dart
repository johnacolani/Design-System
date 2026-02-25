import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/design_system_provider.dart';
import '../models/user.dart';
import '../models/design_system.dart' as models;
import '../utils/responsive.dart';
import '../widgets/app_logo.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';
import 'projects_screen.dart';
import 'profile_screen.dart';
import 'auth_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final designSystemProvider = Provider.of<DesignSystemProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
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
                      // Hero Section with Project Previews
                      _buildHeroSection(context, designSystemProvider, userProvider),
                      
                      // Tagline
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsive.isMobile ? 16 : 24,
                          vertical: context.responsive.isMobile ? 24 : 32,
                        ),
                        child: Text(
                          'Design System Builder lets you turn big ideas into real products. Create, customize, and export design systems for Flutter, Kotlin, and Swift.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[700],
                                height: 1.6,
                                fontSize: context.responsive.isMobile ? 14 : null,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
          
          // Navigation Actions
          if (userProvider.isLoggedIn) ...[
            if (!responsive.isMobile)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                  );
                },
                child: const Text('My Projects'),
              ),
            if (!responsive.isMobile) const SizedBox(width: 8),
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
            if (!responsive.isMobile) const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.isMobile ? 16 : 20,
                  vertical: responsive.isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
    
    return Stack(
      children: [
        // Background with project previews
        Container(
          height: responsive.isMobile ? 400 : responsive.isTablet ? 500 : 600,
          margin: responsive.margin,
          child: _buildProjectPreviewsGrid(context, designSystemProvider),
        ),
        
        // Floating Call-to-Action Card (Figma-style)
        Positioned(
          top: responsive.isMobile ? 120 : responsive.isTablet ? 150 : 200,
          left: 0,
          right: 0,
          child: Center(
            child: _buildFloatingCTACard(context, designSystemProvider, userProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectPreviewsGrid(BuildContext context, DesignSystemProvider designSystemProvider) {
    if (!designSystemProvider.hasProject) {
      // Show placeholder previews when no project exists
      return Stack(
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
    
    // Show actual project preview
    final designSystem = designSystemProvider.designSystem;
    Color? primaryColor;
    if (designSystem.colors.primary.isNotEmpty) {
      final firstColor = designSystem.colors.primary.values.first;
      final colorValue = firstColor is Map
          ? (firstColor as Map)['value']?.toString() ?? '#000000'
          : firstColor.toString();
      primaryColor = _parseColor(colorValue);
    }
    primaryColor ??= Theme.of(context).colorScheme.primary;
    
    return Center(
      child: _buildPreviewCard(
        context,
        title: designSystem.name,
        description: designSystem.description,
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.7),
          primaryColor.withOpacity(0.4),
        ],
        rotation: 0,
        isActive: true,
      ),
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
    
    if (designSystemProvider.hasProject) {
      final designSystem = designSystemProvider.designSystem;
      Color? primaryColor;
      if (designSystem.colors.primary.isNotEmpty) {
        final firstColor = designSystem.colors.primary.values.first;
        final colorValue = firstColor is Map
            ? (firstColor as Map)['value']?.toString() ?? '#000000'
            : firstColor.toString();
        primaryColor = _parseColor(colorValue);
      }
      primaryColor ??= Theme.of(context).colorScheme.primary;
      
      return Container(
        width: responsive.isMobile ? double.infinity : responsive.isTablet ? 350 : 400,
        margin: responsive.margin,
        padding: EdgeInsets.all(responsive.isMobile ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continue working on "${designSystem.name}"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue Editing',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // No project - show create CTA
    return Container(
      width: responsive.isMobile ? double.infinity : responsive.isTablet ? 350 : 400,
      margin: responsive.margin,
      padding: EdgeInsets.all(responsive.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
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
                // If logged in, go directly to onboarding. Otherwise, go to welcome screen
                if (userProvider.isLoggedIn) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
          ? (firstColor as Map)['value']?.toString() ?? '#000000'
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
                          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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
