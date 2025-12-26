import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({super.key});

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  List<Experience> _experiences = [];
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    try {
      final resume = await context.read<ResumeRepository>().loadResume();
      setState(() {
        _experiences = resume.experiences;
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
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    return SingleChildScrollView(
      padding:
          EdgeInsets.all(isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Career Journey',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Explore my professional experience and growth',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.spacingXxl),

          // Journey map with parallax effect
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: 3D-like map
                Expanded(
                  flex: 1,
                  child: _JourneyMap(
                    experiences: _experiences,
                    selectedIndex: _selectedIndex,
                    onNodeTap: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXl),
                // Right: Details stepper
                Expanded(
                  flex: 1,
                  child: _ExperienceDetails(
                    experience: _experiences.isNotEmpty
                        ? _experiences[_selectedIndex]
                        : null,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _JourneyMap(
                  experiences: _experiences,
                  selectedIndex: _selectedIndex,
                  onNodeTap: (index) => setState(() => _selectedIndex = index),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                _ExperienceDetails(
                  experience: _experiences.isNotEmpty
                      ? _experiences[_selectedIndex]
                      : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _JourneyMap extends StatelessWidget {
  final List<Experience> experiences;
  final int selectedIndex;
  final Function(int) onNodeTap;

  const _JourneyMap({
    required this.experiences,
    required this.selectedIndex,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: List.generate(experiences.length, (index) {
          final isSelected = index == selectedIndex;
          final isLast = index == experiences.length - 1;
          final experience = experiences[index];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline
              Column(
                children: [
                  _JourneyNode(
                    isSelected: isSelected,
                    isCurrent: experience.isCurrent,
                    onTap: () => onNodeTap(index),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isSelected
                                ? AppTheme.primaryBlue
                                : AppTheme.textMuted,
                            index + 1 == selectedIndex
                                ? AppTheme.primaryBlue
                                : AppTheme.textMuted.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Content
              Expanded(
                child: GestureDetector(
                  onTap: () => onNodeTap(index),
                  child: AnimatedContainer(
                    duration: AppTheme.animNormal,
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: isSelected
                          ? Border.all(
                              color:
                                  AppTheme.primaryBlue.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                experience.company,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (experience.isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusSuccess
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    color: AppTheme.statusSuccess,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          experience.title,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          experience.duration,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _JourneyNode extends StatefulWidget {
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _JourneyNode({
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  State<_JourneyNode> createState() => _JourneyNodeState();
}

class _JourneyNodeState extends State<_JourneyNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.isCurrent) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale =
              widget.isCurrent ? 1.0 + (_controller.value * 0.1) : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.bgSurface,
                border: Border.all(
                  color: widget.isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textMuted,
                  width: 2,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Using Flutter's built-in AnimatedBuilder - no custom class needed

class _ExperienceDetails extends StatelessWidget {
  final Experience? experience;

  const _ExperienceDetails({this.experience});

  @override
  Widget build(BuildContext context) {
    if (experience == null) {
      return const Center(
        child: Text(
          'Select an experience to view details',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: AppTheme.animNormal,
      child: Container(
        key: ValueKey(experience!.id),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border:
              Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company & Title
            Text(
              experience!.company,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              experience!.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Duration & Location
            Wrap(
              spacing: AppTheme.spacingMd,
              runSpacing: AppTheme.spacingSm,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      experience!.duration,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      experience!.location,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Highlights
            const Text(
              'Key Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ...experience!.highlights.map((highlight) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ',
                          style: TextStyle(color: AppTheme.primaryBlue)),
                      Expanded(
                        child: Text(
                          highlight,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            // Technologies
            if (experience!.technologies.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMd),
              const Text(
                'Technologies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Wrap(
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingSm,
                children: experience!.technologies.map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tech,
                      style: const TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
