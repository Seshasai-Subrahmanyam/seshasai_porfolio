import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import 'glass_container.dart';
import 'profile_image.dart';
import '../router/app_router.dart';
import '../../features/landing/bloc/resume_bloc.dart';

/// App shell with navigation bar
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isOnChatPage = currentPath == '/chat';
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded,
                      color: AppTheme.textPrimary),
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        actions: [
          // JUNNU AI button (always visible, hide when on chat page)
          if (!isOnChatPage)
            _JunnuAiButton(onTap: () => context.go(AppRouter.chat)),
          // Contact icons only on desktop
          if (!isMobile)
            BlocBuilder<ResumeBloc, ResumeState>(
              builder: (context, state) {
                final info = state.personalInfo;
                if (info == null) return const SizedBox.shrink();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (info.email.isNotEmpty)
                      _ContactAction(
                        icon: Icons.email_rounded,
                        tooltip: 'Email',
                        onTap: () => _launchUrl('mailto:${info.email}'),
                      ),
                    if (info.phone != null)
                      _ContactAction(
                        icon: Icons.phone_rounded,
                        tooltip: 'Phone',
                        onTap: () => _launchUrl('tel:${info.phone}'),
                      ),
                    if (info.linkedIn != null)
                      _ContactAction(
                        assetPath: 'assets/icons/linkedin.svg',
                        tooltip: 'LinkedIn',
                        onTap: () => _launchUrl(info.linkedIn!),
                      ),
                    if (info.github != null)
                      _ContactAction(
                        assetPath: "assets/icons/github.svg",
                        tooltip: 'GitHub',
                        onTap: () => _launchUrl(info.github!),
                      ),
                    if (info.medium != null)
                      _ContactAction(
                        assetPath: "assets/icons/medium.svg",
                        tooltip: 'Medium',
                        onTap: () => _launchUrl(info.medium!),
                      ),
                    const SizedBox(width: AppTheme.spacingMd),
                  ],
                );
              },
            ),
        ],
      ),
      drawer: isMobile ? _MobileDrawer() : null,
      body: Row(
        children: [
          // Navigation rail for desktop
          if (!isMobile) _NavigationRail(),
          // Main content with footer
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                    horizontal: AppTheme.spacingLg,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard.withValues(alpha: 0.5),
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Made with ',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 16,
                      ),
                      const Text(
                        ' in Flutter and GenAI',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  final url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}

/// Mobile navigation drawer with navigation items and contact info
class _MobileDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: AppTheme.bgDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            BlocBuilder<ResumeBloc, ResumeState>(
              builder: (context, state) {
                final info = state.personalInfo;
                return Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Row(
                    children: [
                      // Profile image with loading/error handling
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: info?.profileImageUrl != null
                            ? Image.network(
                                info!.profileImageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    color: AppTheme.bgElevated,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.bgElevated,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person,
                                        color: AppTheme.textMuted),
                                  );
                                },
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppTheme.bgElevated,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    color: AppTheme.textMuted),
                              ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info?.name.split(' ').first ?? 'Seshasai',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Portfolio',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Divider(color: AppTheme.textMuted.withValues(alpha: 0.1)),

            // Navigation items
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                children: [
                  _DrawerNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentPath == '/',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.landing);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.route_rounded,
                    label: 'Journey',
                    isSelected: currentPath == '/journey',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.journey);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.folder_rounded,
                    label: 'Projects',
                    isSelected: currentPath.startsWith('/projects'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.projects);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.code_rounded,
                    label: 'Skills',
                    isSelected: currentPath == '/skills',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.skills);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.verified_rounded,
                    label: 'Certificates',
                    isSelected: currentPath == '/certificates',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.certificates);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.apps_rounded,
                    label: 'Published Apps',
                    isSelected: currentPath == '/apps',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.apps);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.school_rounded,
                    label: 'Education',
                    isSelected: currentPath == '/education',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.education);
                    },
                  ),
                  _DrawerNavItemSvg(
                    assetPath: 'assets/icons/junnu_ai.svg',
                    label: 'Chat with JUNNU AI',
                    isSelected: currentPath == '/chat',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRouter.chat);
                    },
                  ),
                ],
              ),
            ),

            Divider(color: AppTheme.textMuted.withValues(alpha: 0.1)),

            // Contact section
            BlocBuilder<ResumeBloc, ResumeState>(
              builder: (context, state) {
                final info = state.personalInfo;
                if (info == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Wrap(
                        spacing: AppTheme.spacingSm,
                        runSpacing: AppTheme.spacingSm,
                        children: [
                          if (info.email.isNotEmpty)
                            _DrawerContactChip(
                              icon: Icons.email_rounded,
                              label: 'Email',
                              onTap: () => _launchUrl('mailto:${info.email}'),
                            ),
                          if (info.phone != null)
                            _DrawerContactChip(
                              icon: Icons.phone_rounded,
                              label: 'Phone',
                              onTap: () => _launchUrl('tel:${info.phone}'),
                            ),
                          if (info.linkedIn != null)
                            _DrawerContactChipSvg(
                              assetPath: 'assets/icons/linkedin.svg',
                              label: 'LinkedIn',
                              onTap: () => _launchUrl(info.linkedIn!),
                            ),
                          if (info.github != null)
                            _DrawerContactChipSvg(
                              assetPath: 'assets/icons/github.svg',
                              label: 'GitHub',
                              onTap: () => _launchUrl(info.github!),
                            ),
                          if (info.medium != null)
                            _DrawerContactChipSvg(
                              assetPath: 'assets/icons/medium.svg',
                              label: 'Medium',
                              onTap: () => _launchUrl(info.medium!),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      onTap: onTap,
    );
  }
}

class _DrawerNavItemSvg extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNavItemSvg({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      onTap: onTap,
    );
  }
}

class _DrawerContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerContactChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryBlue),
            const SizedBox(width: 4),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerContactChipSvg extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _DrawerContactChipSvg({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(assetPath, width: 16, height: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactAction extends StatefulWidget {
  final IconData? icon;
  final String? assetPath;
  final String tooltip;
  final VoidCallback onTap;

  const _ContactAction({
    this.icon,
    this.assetPath,
    required this.tooltip,
    required this.onTap,
  }) : assert(icon != null || assetPath != null);

  @override
  State<_ContactAction> createState() => _ContactActionState();
}

class _ContactActionState extends State<_ContactAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: IconButton(
        icon: widget.assetPath != null
            ? SvgPicture.asset(
                widget.assetPath!,
                width: 24,
                height: 24,
                // colorFilter: ColorFilter.mode(
                // colorFilter: ColorFilter.mode(
                //   _isHovered ? AppTheme.primaryBlue : AppTheme.textSecondary,
                //   BlendMode.srcIn,
                // ),
              )
            : Icon(
                widget.icon,
                color: _isHovered ? AppTheme.primaryBlue : Colors.white,
              ),
        tooltip: widget.tooltip,
        onPressed: widget.onTap,
      ),
    );
  }
}

/// Network profile image widget for CDN images with loading and error states
class _NetworkProfileImage extends StatefulWidget {
  final String imageUrl;
  const _NetworkProfileImage({required this.imageUrl});

  @override
  State<_NetworkProfileImage> createState() => _NetworkProfileImageState();
}

class _NetworkProfileImageState extends State<_NetworkProfileImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 500, maxHeight: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image,
                            color: AppTheme.textMuted, size: 64),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(_isHovered ? 32 : AppTheme.radiusMedium),
            boxShadow: _isHovered ? AppTheme.smoothShadow : [],
            border: _isHovered
                ? Border.all(color: AppTheme.primaryBlue, width: 2)
                : null,
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(_isHovered ? 32 : AppTheme.radiusMedium),
            child: Image.network(
              widget.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 64,
                  height: 64,
                  color: AppTheme.bgElevated,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryBlue,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: AppTheme.bgElevated,
                  child: const Center(
                    child:
                        Icon(Icons.person, color: AppTheme.textMuted, size: 32),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 768) {
      return const SizedBox.shrink();
    }

    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(currentPath);

    return GlassContainer(
      width: 80,
      blur: 20,
      opacity: 0.8,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(AppTheme.radiusLarge),
        bottomRight: Radius.circular(AppTheme.radiusLarge),
      ),
      border: Border(
        right: BorderSide(
          color: AppTheme.textMuted.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingLg),
          // Logo - Profile Image from CDN
          BlocBuilder<ResumeBloc, ResumeState>(
            builder: (context, state) {
              final imageUrl = state.personalInfo?.profileImageUrl;
              if (imageUrl != null) {
                return _NetworkProfileImage(imageUrl: imageUrl);
              }
              return const ProfileImage(
                  imagePath: 'assets/images/my_face.jpeg');
            },
          ),
          const SizedBox(height: AppTheme.spacingXl),
          // Navigation items - scrollable to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: selectedIndex == 0,
                    onTap: () => context.go(AppRouter.landing),
                  ),
                  _NavItem(
                    icon: Icons.route_rounded,
                    label: 'Journey',
                    isSelected: selectedIndex == 1,
                    onTap: () => context.go(AppRouter.journey),
                  ),
                  _NavItem(
                    icon: Icons.folder_rounded,
                    label: 'Projects',
                    isSelected: selectedIndex == 2,
                    onTap: () => context.go(AppRouter.projects),
                  ),
                  _NavItemSvg(
                    assetPath: 'assets/icons/junnu_ai.svg',
                    label: 'JUNNU',
                    isSelected: selectedIndex == 3,
                    onTap: () => context.go(AppRouter.chat),
                  ),
                  _NavItem(
                    icon: Icons.code_rounded,
                    label: 'Skills',
                    isSelected: selectedIndex == 4,
                    onTap: () => context.go(AppRouter.skills),
                  ),
                  _NavItem(
                    icon: Icons.verified_rounded,
                    label: 'Certs',
                    isSelected: selectedIndex == 5,
                    onTap: () => context.go(AppRouter.certificates),
                  ),
                  _NavItem(
                    icon: Icons.apps_rounded,
                    label: 'Apps',
                    isSelected: selectedIndex == 6,
                    onTap: () => context.go(AppRouter.apps),
                  ),
                  _NavItem(
                    icon: Icons.school_rounded,
                    label: 'Education',
                    isSelected: selectedIndex == 7,
                    onTap: () => context.go(AppRouter.education),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String path) {
    if (path == '/') return 0;
    if (path == '/journey') return 1;
    if (path.startsWith('/projects')) return 2;
    if (path == '/chat') return 3;
    if (path == '/skills') return 4;
    if (path == '/certificates') return 5;
    if (path == '/apps') return 6;
    if (path == '/education') return 7;
    return 0;
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : _isHovered
                    ? AppTheme.bgSurface
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: widget.isSelected
                ? Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : _isHovered
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.isSelected
                      ? AppTheme.primaryBlue
                      : _isHovered
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item that uses an SVG asset for the icon
class _NavItemSvg extends StatefulWidget {
  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemSvg({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItemSvg> createState() => _NavItemSvgState();
}

class _NavItemSvgState extends State<_NavItemSvg> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppTheme.primaryBlue
        : _isHovered
            ? AppTheme.textPrimary
            : AppTheme.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : _isHovered
                    ? AppTheme.bgSurface
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: widget.isSelected
                ? Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                widget.assetPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.isSelected
                      ? AppTheme.primaryBlue
                      : _isHovered
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(currentPath);

    return GlassContainer(
      blur: 20,
      opacity: 0.8,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppTheme.radiusLarge),
        topRight: Radius.circular(AppTheme.radiusLarge),
      ),
      border: Border(
        top: BorderSide(
          color: AppTheme.textMuted.withValues(alpha: 0.1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXs,
            vertical: AppTheme.spacingXs,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go(AppRouter.landing),
                ),
                _BottomNavItem(
                  icon: Icons.route_rounded,
                  label: 'Journey',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go(AppRouter.journey),
                ),
                _BottomNavItem(
                  icon: Icons.folder_rounded,
                  label: 'Projects',
                  isSelected: selectedIndex == 2,
                  onTap: () => context.go(AppRouter.projects),
                ),
                _BottomNavItemSvg(
                  assetPath: 'assets/icons/junnu_ai.svg',
                  label: 'JUNNU',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go(AppRouter.chat),
                ),
                _BottomNavItem(
                  icon: Icons.code_rounded,
                  label: 'Skills',
                  isSelected: selectedIndex == 4,
                  onTap: () => context.go(AppRouter.skills),
                ),
                _BottomNavItem(
                  icon: Icons.verified_rounded,
                  label: 'Certs',
                  isSelected: selectedIndex == 5,
                  onTap: () => context.go(AppRouter.certificates),
                ),
                _BottomNavItem(
                  icon: Icons.apps_rounded,
                  label: 'Apps',
                  isSelected: selectedIndex == 6,
                  onTap: () => context.go(AppRouter.apps),
                ),
                _BottomNavItem(
                  icon: Icons.school_rounded,
                  label: 'Edu',
                  isSelected: selectedIndex == 7,
                  onTap: () => context.go(AppRouter.education),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String path) {
    if (path == '/') return 0;
    if (path == '/journey') return 1;
    if (path.startsWith('/projects')) return 2;
    if (path == '/chat') return 3;
    if (path == '/skills') return 4;
    if (path == '/certificates') return 5;
    if (path == '/apps') return 6;
    if (path == '/education') return 7;
    return 0;
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom nav item using SVG asset
class _BottomNavItemSvg extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItemSvg({
    required this.assetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// JUNNU AI button for app bar
class _JunnuAiButton extends StatefulWidget {
  final VoidCallback onTap;

  const _JunnuAiButton({required this.onTap});

  @override
  State<_JunnuAiButton> createState() => _JunnuAiButtonState();
}

class _JunnuAiButtonState extends State<_JunnuAiButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: 'Chat with JUNNU AI',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.primaryGradient.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/junnu_ai.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'JUNNU AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
