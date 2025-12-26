import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/data/data.dart';
import '../../../core/network/rag_api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  ProjectModel? _project;
  String? _storyHeadline;
  String? _storyMarkdown;
  bool _isLoading = true;
  bool _isLoadingStory = false;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    try {
      final project = await context
          .read<ResumeRepository>()
          .getProjectById(widget.projectId);
      setState(() {
        _project = project;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAIStory() async {
    if (_isLoadingStory || _storyMarkdown != null) return;
    if (_project == null) return;

    setState(() => _isLoadingStory = true);
    try {
      final ragClient = context.read<RagApiClient>();

      // Build a query for the project story
      final queryText =
          'Tell me the story behind the ${_project!.title} project. '
          'What was the problem it solved, what technologies were used, '
          'and what was Seshasai\'s role and contribution?';

      final response = await ragClient.query(RagQueryRequest(
        question: queryText,
        persona:
            'tech_lead', // Use tech_lead persona for detailed technical story
      ));

      setState(() {
        _storyHeadline = 'The Story of ${_project!.title}';
        _storyMarkdown = response.answer;
        _isLoadingStory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStory = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Unable to generate story. Please try again later.')),
        );
      }
    }
  }

  /// Extracts YouTube video ID from various URL formats
  String? _getYouTubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // Handle youtu.be short URLs
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    // Handle youtube.com URLs
    if (uri.host.contains('youtube.com')) {
      // Handle YouTube Shorts: youtube.com/shorts/VIDEO_ID
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'shorts') {
        return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      }
      // Handle regular youtube.com/watch?v=VIDEO_ID
      return uri.queryParameters['v'];
    }

    return null;
  }

  /// Netflix-style media section with video + screenshots in horizontal layout
  Widget _buildMediaSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    final hasVideo =
        _project!.videoDemoUrl != null && _project!.videoDemoUrl!.isNotEmpty;
    final hasScreenshots = _project!.demoScreenshots.isNotEmpty;

    // Card dimensions for Netflix style - increased sizes
    final cardHeight = isMobile ? 180.0 : 280.0;
    final cardWidth = cardHeight * 16 / 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: Row(
            children: [
              Icon(Icons.movie_outlined,
                  color: AppTheme.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text('Media',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        // Horizontal scrollable row with video + screenshots
        SizedBox(
          height: cardHeight + 32, // Extra padding for hover effects
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Video Thumbnail (first item)
              if (hasVideo) ...[
                _buildVideoThumbnail(cardWidth, cardHeight),
                const SizedBox(width: AppTheme.spacingMd),
              ],

              // Screenshots (following items)
              if (hasScreenshots)
                ...List.generate(_project!.demoScreenshots.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _project!.demoScreenshots.length - 1
                          ? AppTheme.spacingMd
                          : 0,
                    ),
                    child: _ScreenshotCard(
                      imageUrl: _project!.demoScreenshots[index],
                      width: cardWidth,
                      height: cardHeight,
                      onTap: () => _showFullScreenImage(
                          _project!.demoScreenshots[index]),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  /// Video thumbnail card for Netflix-style carousel
  Widget _buildVideoThumbnail(double width, double height) {
    final videoId = _getYouTubeVideoId(_project!.videoDemoUrl!);
    final thumbnailUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return _VideoThumbnailCard(
      thumbnailUrl: thumbnailUrl,
      width: width,
      height: height,
      onTap: () => launchUrl(Uri.parse(_project!.videoDemoUrl!)),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 400,
                    height: 300,
                    color: AppTheme.bgCard,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 400,
                  height: 300,
                  color: AppTheme.bgCard,
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 64, color: AppTheme.textMuted),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    if (_project == null)
      return Center(
          child: Text('Project not found',
              style: TextStyle(color: AppTheme.textMuted)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          TextButton.icon(
            onPressed: () => context.go(AppRouter.projects),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to Projects'),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Project header
          Text(_project!.title,
              style: Theme.of(context).textTheme.displaySmall),
          if (_project!.category != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(_project!.category!,
                  style: const TextStyle(
                      color: AppTheme.primaryPurple, fontSize: 12)),
            ),
          ],
          const SizedBox(height: AppTheme.spacingMd),
          Text(_project!.description,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppTheme.spacingLg),

          // Tech stack
          if (_project!.technologies.isNotEmpty) ...[
            const Text('Tech Stack',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _project!.technologies
                  .map((t) =>
                      Chip(label: Text(t), backgroundColor: AppTheme.bgSurface))
                  .toList(),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],

          // Links
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (_project!.githubUrl != null)
                ElevatedButton.icon(
                    icon: const Icon(Icons.code),
                    label: const Text('GitHub'),
                    onPressed: () =>
                        launchUrl(Uri.parse(_project!.githubUrl!))),
              if (_project!.demoUrl != null)
                OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Demo'),
                    onPressed: () => launchUrl(Uri.parse(_project!.demoUrl!))),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXl),
          // Media Section - Netflix style horizontal layout
          if ((_project!.videoDemoUrl != null &&
                  _project!.videoDemoUrl!.isNotEmpty) ||
              _project!.demoScreenshots.isNotEmpty) ...[
            _buildMediaSection(),
            const SizedBox(height: AppTheme.spacingXl),
          ],

          // const SizedBox(height: AppTheme.spacingXl),

          // AI Story section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - responsive layout
                Builder(
                  builder: (context) {
                    final isMobile = MediaQuery.of(context).size.width < 500;
                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              const Text('AI Story',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (_storyMarkdown == null && !_isLoadingStory) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: _loadAIStory,
                                  child: const Text('Generate Story')),
                            ),
                          ],
                        ],
                      );
                    }
                    return Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        const Text('AI Story',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        if (_storyMarkdown == null && !_isLoadingStory)
                          ElevatedButton(
                              onPressed: _loadAIStory,
                              child: const Text('Generate Story')),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingMd),
                if (_isLoadingStory)
                  const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue)),
                if (_storyMarkdown != null) ...[
                  Text(_storyHeadline ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue)),
                  const SizedBox(height: AppTheme.spacingSm),
                  MarkdownBody(
                      data: _storyMarkdown!,
                      styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: AppTheme.textSecondary))),
                ],
                if (_storyMarkdown == null && !_isLoadingStory)
                  const Text(
                      'Click "Generate Story" to get an AI-powered analysis of this project',
                      style: TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Netflix-style screenshot card with hover effects
class _ScreenshotCard extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _ScreenshotCard({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  State<_ScreenshotCard> createState() => _ScreenshotCardState();
}

class _ScreenshotCardState extends State<_ScreenshotCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Image.network(
              widget.imageUrl,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: widget.width,
                  height: widget.height,
                  color: AppTheme.bgElevated,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: widget.width,
                height: widget.height,
                color: AppTheme.bgElevated,
                child: const Center(
                  child: Icon(Icons.broken_image,
                      size: 40, color: AppTheme.textMuted),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Netflix-style video thumbnail card with play button overlay
class _VideoThumbnailCard extends StatefulWidget {
  final String? thumbnailUrl;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _VideoThumbnailCard({
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  State<_VideoThumbnailCard> createState() => _VideoThumbnailCardState();
}

class _VideoThumbnailCardState extends State<_VideoThumbnailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Thumbnail image
                widget.thumbnailUrl != null
                    ? Image.network(
                        widget.thumbnailUrl!,
                        width: widget.width,
                        height: widget.height,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: widget.width,
                            height: widget.height,
                            color: AppTheme.bgElevated,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryPurple,
                                  strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: widget.width,
                          height: widget.height,
                          color: AppTheme.bgElevated,
                          child: const Icon(Icons.video_library,
                              size: 40, color: AppTheme.textMuted),
                        ),
                      )
                    : Container(
                        width: widget.width,
                        height: widget.height,
                        color: AppTheme.bgElevated,
                        child: const Icon(Icons.video_library,
                            size: 40, color: AppTheme.textMuted),
                      ),
                // Play button overlay
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isHovered ? 48 : 40,
                  height: _isHovered ? 48 : 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow,
                      color: Colors.white, size: _isHovered ? 32 : 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
