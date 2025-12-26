import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/app_router.dart';
import '../../../core/data/data.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/availability_bloc.dart';
import '../bloc/availability_event.dart';
import '../bloc/availability_state.dart';
import '../bloc/resume_bloc.dart';
import '../widgets/availability_pill.dart';
import '../../../core/models/models.dart';
import '../../../app/widgets/space_background.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AvailabilityBloc(
        resumeRepository: context.read<ResumeRepository>(),
      )..add(const LoadAvailability()),
      child: const _LandingContent(),
    );
  }
}

class _LandingContent extends StatelessWidget {
  const _LandingContent();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SpaceBackground(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            const _HeroSection(),
            const SizedBox(height: AppTheme.spacingXxl),
            const _TopSkillsSection(),
            const SizedBox(height: AppTheme.spacingXxl),
            const _QuickLinksSection(),
            const SizedBox(height: AppTheme.spacingXxl),
            const _ContactSection(),
            const SizedBox(height: AppTheme.spacingXxl),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Availability pill with last updated time
          BlocBuilder<AvailabilityBloc, AvailabilityState>(
            builder: (context, state) {
              final lastUpdated = state.availability?.lastUpdated;
              return Column(
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  AvailabilityPill(
                    status: state.availability?.status ??
                        AvailabilityStatus.openForWork,
                    isLoading: state.status == AvailabilityStateStatus.loading,
                  ),
                  if (lastUpdated != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Updated: ${_formatDate(lastUpdated)}',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: isMobile ? 10 : 11,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Name with gradient
          BlocBuilder<ResumeBloc, ResumeState>(
            builder: (context, state) {
              if (state.status == ResumeStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  // Name with gradient - responsive sizing
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        state.personalInfo?.name ?? 'Seshasai Subrahmanyam',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 32 : null,
                                ),
                        textAlign:
                            isMobile ? TextAlign.center : TextAlign.start,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),

                  // Title - also responsive
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      state.personalInfo?.title ??
                          'Senior Flutter Developer & Generative AI Engineer',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: isMobile ? 16 : null,
                              ),
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      maxLines: isMobile ? 2 : 1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Summary
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Text(
                      state.personalInfo?.summary ??
                          'Building high-performance mobile and web applications with Flutter and cutting-edge AI technologies. Passionate about creating exceptional user experiences and scalable solutions.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingXl),

          // CTA Buttons
          Wrap(
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            spacing: AppTheme.spacingMd,
            runSpacing: AppTheme.spacingMd,
            children: [
              _GradientButton(
                label: 'Chat with JUNNU AI',
                svgPath: 'assets/icons/junnu_ai.svg',
                onTap: () => context.go(AppRouter.chat),
              ),
              _OutlineButton(
                label: 'View Projects',
                icon: Icons.folder_rounded,
                onTap: () => context.go(AppRouter.projects),
              ),
              _OutlineButton(
                label: 'Download Resume',
                icon: Icons.download_rounded,
                onTap: () => _downloadResume(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _downloadResume(BuildContext context) async {
    const resumeUrl =
        'https://res.cloudinary.com/dh07ur7yz/image/upload/v1766655596/Seshasai_nagadevara_resume_2025_2_sqe06o.pdf';
    try {
      final url = Uri.parse(resumeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open resume'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _QuickLinksSection extends StatelessWidget {
  const _QuickLinksSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg,
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Links',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Wrap(
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            spacing: AppTheme.spacingMd,
            runSpacing: AppTheme.spacingMd,
            children: [
              _QuickLinkCard(
                icon: Icons.route_rounded,
                title: 'Journey',
                description: 'Explore my career path',
                color: AppTheme.primaryBlue,
                onTap: () => context.go(AppRouter.journey),
              ),
              _QuickLinkCard(
                icon: Icons.code_rounded,
                title: 'Skills',
                description: 'Technical expertise',
                color: AppTheme.primaryPurple,
                onTap: () => context.go(AppRouter.skills),
              ),
              _QuickLinkCard(
                icon: Icons.verified_rounded,
                title: 'Certificates',
                description: 'Professional credentials',
                color: AppTheme.primaryPurple,
                onTap: () => context.go(AppRouter.certificates),
              ),
              _QuickLinkCard(
                icon: Icons.apps_rounded,
                title: 'Published Apps',
                description: 'Apps on app stores',
                color: AppTheme.primaryGreen,
                onTap: () => context.go(AppRouter.apps),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickLinkCard> createState() => _QuickLinkCardState();
}

class _QuickLinkCardState extends State<_QuickLinkCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.animNormal,
          width: isMobile ? (MediaQuery.of(context).size.width - 48) / 2 : 200,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.1)
                : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.5)
                  : AppTheme.textMuted.withValues(alpha: 0.1),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: AppTheme.animNormal,
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                widget.title,
                style: TextStyle(
                  color: _isHovered ? widget.color : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: isMobile ? 11 : 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopSkillsSection extends StatelessWidget {
  const _TopSkillsSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg,
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            'Top Skills',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Wrap(
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            spacing: AppTheme.spacingLg,
            runSpacing: AppTheme.spacingLg,
            children: [
              _SkillItem(
                label: 'Flutter',
                iconPath: 'assets/icons/flutter.svg',
                color: Color(0xFF02569B),
              ),
              _SkillItem(
                label: 'Langchain',
                iconPath: 'assets/icons/langchain.svg',
                color: AppTheme.primaryPurple,
              ),
              _SkillItem(
                label: 'MCP',
                iconPath: 'assets/icons/mcp.svg',
                color: AppTheme.primaryGreen,
              ),
              _SkillItem(
                label: 'Context Eng.',
                iconPath: 'assets/icons/context_eng.svg',
                color: AppTheme.primaryPurple,
              ),
              _SkillItem(
                label: 'A2A Protocol',
                iconPath: 'assets/icons/a2a.svg',
                color: AppTheme.primaryOrange,
              ),
              _SkillItem(
                label: 'Google ADK',
                iconPath: 'assets/icons/google_adk.svg',
                color: Colors.blue,
              ),
              _SkillItem(
                label: 'n8n',
                iconPath: 'assets/icons/n8n.svg',
                color: Color(0xFFFF6B6B),
              ),
              _SkillItem(
                label: 'Make.com',
                iconPath: 'assets/icons/make.svg',
                color: Color(0xFF6B35FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillItem extends StatefulWidget {
  final String label;
  final String iconPath;
  final Color color;

  const _SkillItem({
    required this.label,
    required this.iconPath,
    this.color = AppTheme.primaryBlue,
  });

  @override
  State<_SkillItem> createState() => _SkillItemState();
}

class _SkillItemState extends State<_SkillItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final itemWidth =
        isMobile ? (MediaQuery.of(context).size.width - 64) / 2 : 160.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        width: itemWidth,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.bgElevated : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.5)
                : AppTheme.textMuted.withValues(alpha: 0.1),
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.iconPath.endsWith('.svg')
                ? SvgPicture.asset(
                    widget.iconPath,
                    width: isMobile ? 24 : 28,
                    height: isMobile ? 24 : 28,
                  )
                : Image.asset(
                    widget.iconPath,
                    width: isMobile ? 24 : 28,
                    height: isMobile ? 24 : 28,
                  ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final String? svgPath;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    this.icon,
    this.svgPath,
    required this.onTap,
  }) : assert(icon != null || svgPath != null);

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: _isHovered ? AppTheme.smoothShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.svgPath != null)
                SvgPicture.asset(
                  widget.svgPath!,
                  width: 20,
                  height: 20,
                  // colorFilter: const ColorFilter.mode(
                  //   AppTheme.bgDark,
                  //   BlendMode.srcIn,
                  // ),
                )
              else
                Icon(widget.icon, color: AppTheme.bgDark, size: 20),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: _isHovered ? AppTheme.primaryBlue : AppTheme.textMuted,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color:
                    _isHovered ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg,
      ),
      child: BlocBuilder<ResumeBloc, ResumeState>(
        builder: (context, state) {
          final info = state.personalInfo;
          if (info == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment:
                isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Wrap(
                alignment:
                    isMobile ? WrapAlignment.center : WrapAlignment.start,
                spacing: AppTheme.spacingLg,
                runSpacing: AppTheme.spacingLg,
                children: [
                  if (info.email.isNotEmpty)
                    _ContactItem(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: info.email,
                      onTap: () => _launchUrl('mailto:${info.email}'),
                    ),
                  if (info.phone != null && info.phone!.isNotEmpty)
                    _ContactItem(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: info.phone!,
                      onTap: () => _launchUrl('tel:${info.phone}'),
                    ),
                  if (info.location != null)
                    _ContactItem(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: info.location!,
                      onTap: null, // Location usually not clickable unless map
                    ),
                  if (info.linkedIn != null)
                    _ContactItem(
                      assetPath: 'assets/icons/linkedin.svg',
                      label: 'LinkedIn',
                      value: 'Connect on LinkedIn',
                      onTap: () => _launchUrl(info.linkedIn!),
                    ),
                  if (info.github != null)
                    _ContactItem(
                      assetPath: "assets/icons/github.svg",
                      label: 'GitHub',
                      value: 'View GitHub Profile',
                      onTap: () => _launchUrl(info.github!),
                    ),
                  if (info.medium != null)
                    _ContactItem(
                      assetPath: "assets/icons/medium.svg",
                      label: 'Medium',
                      value: 'Read Articles on Medium',
                      onTap: () => _launchUrl(info.medium!),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

class _ContactItem extends StatefulWidget {
  final IconData? icon;
  final String? assetPath;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactItem({
    this.icon,
    this.assetPath,
    required this.label,
    required this.value,
    this.onTap,
  }) : assert(icon != null || assetPath != null);

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: isClickable && _isHovered
                  ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                  : AppTheme.textMuted.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: widget.assetPath != null
                    ? SvgPicture.asset(
                        widget.assetPath!,
                        width: 20,
                        height: 20,
                      )
                    : Icon(widget.icon, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                    Text(
                      widget.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isClickable && _isHovered
                                ? AppTheme.primaryBlue
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
