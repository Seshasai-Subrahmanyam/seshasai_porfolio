import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/data/data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<ProjectModel> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await context.read<ResumeRepository>().loadProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    }

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projects', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppTheme.spacingSm),
          Text('Showcase of my work and open-source contributions',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppTheme.spacingXl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 3
                  : constraints.maxWidth > 768
                      ? 2
                      : 1;

              if (crossAxisCount == 1) {
                // Mobile: Use Column for full-content cards
                return Column(
                  children: _projects
                      .map((project) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppTheme.spacingMd),
                            child: _ProjectCard(project: project),
                          ))
                      .toList(),
                );
              }

              // Desktop/Tablet: Use Wrap for flexible grid layout
              return Wrap(
                spacing: AppTheme.spacingMd,
                runSpacing: AppTheme.spacingMd,
                children: _projects
                    .map((project) => SizedBox(
                          width: (constraints.maxWidth -
                                  (AppTheme.spacingMd * (crossAxisCount - 1))) /
                              crossAxisCount,
                          child: _ProjectCard(project: project),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    // Responsive values
    final cardPadding = isDesktop ? AppTheme.spacingMd : AppTheme.spacingSm;
    final titleFontSize = isDesktop
        ? 17.0
        : isTablet
            ? 16.0
            : 15.0;
    final descFontSize = isDesktop
        ? 14.0
        : isTablet
            ? 13.0
            : 12.0;
    final iconSize = isDesktop ? 48.0 : 40.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/projects/${widget.project.id}'),
        child: AnimatedContainer(
          duration: AppTheme.animNormal,
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                  : AppTheme.textMuted.withValues(alpha: 0.1),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                        blurRadius: 20)
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon area
              Container(
                height: isDesktop ? 120 : 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.bgSurface,
                      AppTheme.primaryBlue.withValues(alpha: 0.1)
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusLarge)),
                ),
                child: Center(
                    child: Icon(Icons.code_rounded,
                        size: iconSize,
                        color: AppTheme.primaryBlue.withValues(alpha: 0.5))),
              ),
              // Content area
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.project.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(widget.project.category!,
                            style: const TextStyle(
                                color: AppTheme.primaryPurple, fontSize: 10)),
                      ),
                    SizedBox(height: isDesktop ? 8 : 4),
                    Text(widget.project.title,
                        style: TextStyle(
                            color: _isHovered
                                ? AppTheme.primaryBlue
                                : AppTheme.textPrimary,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: isDesktop ? 6 : 4),
                    Text(widget.project.description,
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: descFontSize,
                            height: 1.4)),
                    SizedBox(height: isDesktop ? 12 : 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (widget.project.githubUrl != null)
                          _ActionBtn(
                              icon: Icons.code,
                              label: 'GitHub',
                              onTap: () =>
                                  _launchUrl(widget.project.githubUrl!)),
                        if (widget.project.demoUrl != null)
                          _ActionBtn(
                              icon: Icons.open_in_new,
                              label: 'Demo',
                              onTap: () => _launchUrl(widget.project.demoUrl!)),
                        _ActionBtn(
                            icon: Icons.auto_awesome,
                            label: 'Ask AI',
                            isPrimary: true,
                            onTap: () =>
                                context.go('/projects/${widget.project.id}')),
                      ],
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

  void _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (_) {}
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color:
                    isPrimary ? AppTheme.primaryBlue : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: isPrimary
                        ? AppTheme.primaryBlue
                        : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
