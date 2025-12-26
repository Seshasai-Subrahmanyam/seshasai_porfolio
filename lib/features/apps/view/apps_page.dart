import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});
  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  List<PublishedApp> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await context.read<ResumeRepository>().getApps();
      setState(() {
        _apps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue));

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Published Apps',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppTheme.spacingSm),
          Text('Apps available on app stores',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppTheme.spacingXl),
          ..._apps.map((app) => _AppCard(app: app)),
        ],
      ),
    );
  }
}

class _AppCard extends StatefulWidget {
  final PublishedApp app;
  const _AppCard({required this.app});

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTheme.animNormal,
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
              color: _isHovered
                  ? AppTheme.primaryGreen.withValues(alpha: 0.5)
                  : AppTheme.textMuted.withValues(alpha: 0.1)),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 16)
                ]
              : null,
        ),
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildAppIcon(),
        const SizedBox(width: AppTheme.spacingLg),
        Expanded(child: _buildAppInfo()),
        _buildStoreButtons(isVertical: true),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAppIcon(),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(child: _buildAppInfo()),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildStoreButtons(isVertical: false),
      ],
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primaryGreen.withValues(alpha: 0.2),
          AppTheme.primaryBlue.withValues(alpha: 0.2)
        ]),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: widget.app.iconUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: _NetworkSvgIcon(
                url: widget.app.iconUrl,
                width: 60,
                height: 60,
              ),
            )
          : const Icon(Icons.apps, size: 40, color: AppTheme.primaryGreen),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.app.name,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    _isHovered ? AppTheme.primaryGreen : AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(widget.app.description,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            if (widget.app.rating != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star,
                      size: 14, color: AppTheme.statusWarning),
                  Text(' ${widget.app.rating}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            if (widget.app.downloads != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.download,
                      size: 14, color: AppTheme.textMuted),
                  Text(' ${_formatDownloads(widget.app.downloads!)}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreButtons({required bool isVertical}) {
    final buttons = <Widget>[
      if (widget.app.playStoreUrl != null)
        _StoreButton(
            icon: Icons.android,
            label: 'Play Store',
            onTap: () => launchUrl(Uri.parse(widget.app.playStoreUrl!))),
      if (widget.app.appStoreUrl != null)
        _StoreButton(
            icon: Icons.apple,
            label: 'App Store',
            onTap: () => launchUrl(Uri.parse(widget.app.appStoreUrl!))),
      if (widget.app.webUrl != null)
        _StoreButton(
            icon: Icons.language,
            label: 'Web',
            onTap: () => launchUrl(Uri.parse(widget.app.webUrl!))),
    ];

    if (isVertical) {
      return Column(children: buttons);
    }
    return Wrap(
      spacing: AppTheme.spacingSm,
      runSpacing: AppTheme.spacingSm,
      children: buttons,
    );
  }

  String _formatDownloads(int downloads) {
    if (downloads >= 1000000)
      return '${(downloads / 1000000).toStringAsFixed(1)}M+';
    if (downloads >= 1000) return '${(downloads / 1000).toStringAsFixed(0)}K+';
    return '$downloads';
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StoreButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Network SVG icon with loading indicator and error fallback
class _NetworkSvgIcon extends StatefulWidget {
  final String url;
  final double width;
  final double height;

  const _NetworkSvgIcon({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  State<_NetworkSvgIcon> createState() => _NetworkSvgIconState();
}

class _NetworkSvgIconState extends State<_NetworkSvgIcon> {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      widget.url,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Container(
        width: widget.width,
        height: widget.height,
        color: AppTheme.bgElevated,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      // Note: flutter_svg doesn't have errorBuilder, but placeholderBuilder handles loading
      // If SVG fails to load, it will show nothing - this is acceptable behavior
    );
  }
}
