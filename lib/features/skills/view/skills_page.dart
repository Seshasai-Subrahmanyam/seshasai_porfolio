import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../core/data/data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});
  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  Map<String, List<Skill>> _skillsByCategory = {};
  Skill? _selectedSkill;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final grouped =
          await context.read<ResumeRepository>().getSkillsByCategory();
      setState(() {
        _skillsByCategory = grouped;
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

    void showSkillDetails(Skill skill) {
      if (isDesktop) {
        setState(() => _selectedSkill = skill);
      } else {
        // Show bottom sheet on mobile
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.bgCard,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLarge)),
          ),
          builder: (sheetContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: _SkillDetails(
                isBottomSheet: true,
                skill: skill,
                onClose: () => Navigator.pop(sheetContext),
              ),
            ),
          ),
        );
      }
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
                isDesktop ? AppTheme.spacingXxl : AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skills', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: AppTheme.spacingSm),
                Text('Technical expertise and proficiencies',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppTheme.spacingXl),

                // All categories with their skills
                ..._skillsByCategory.entries.map((entry) => _CategorySection(
                      category: entry.key,
                      skills: entry.value,
                      selectedSkill: _selectedSkill,
                      onSkillTap: showSkillDetails,
                    )),
              ],
            ),
          ),
        ),

        // Details drawer (desktop only)
        if (isDesktop && _selectedSkill != null)
          Container(
            width: 350,
            decoration: BoxDecoration(
                color: AppTheme.bgCard,
                border: Border(
                    left: BorderSide(
                        color: AppTheme.textMuted.withValues(alpha: 0.1)))),
            child: _SkillDetails(
                skill: _selectedSkill!,
                onClose: () => setState(() => _selectedSkill = null)),
          ),
      ],
    );
  }
}

/// Section widget for each category with its skills
class _CategorySection extends StatelessWidget {
  final String category;
  final List<Skill> skills;
  final Skill? selectedSkill;
  final Function(Skill) onSkillTap;

  const _CategorySection({
    required this.category,
    required this.skills,
    required this.selectedSkill,
    required this.onSkillTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // Skills in this category
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: skills
              .map((skill) => _SkillChip(
                    skill: skill,
                    isSelected: selectedSkill?.id == skill.id,
                    onTap: () => onSkillTap(skill),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppTheme.spacingLg),
      ],
    );
  }
}

class _SkillChip extends StatefulWidget {
  final Skill skill;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkillChip(
      {required this.skill, required this.isSelected, required this.onTap});

  @override
  State<_SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<_SkillChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : _isHovered
                    ? AppTheme.bgSurface
                    : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.textMuted.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.skill.name,
                  style: TextStyle(
                      color: widget.isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              _ProficiencyDots(level: widget.skill.proficiencyLevel),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProficiencyDots extends StatelessWidget {
  final int level;
  const _ProficiencyDots({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
          5,
          (i) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < level
                      ? AppTheme.primaryBlue
                      : AppTheme.textMuted.withValues(alpha: 0.3),
                ),
              )),
    );
  }
}

class _SkillDetails extends StatelessWidget {
  final Skill skill;
  final VoidCallback onClose;
  final bool isBottomSheet;

  const _SkillDetails({
    required this.skill,
    required this.onClose,
    this.isBottomSheet = false,
  });

  void _askJunnuAi(BuildContext context) {
    // Close the bottom sheet first if we're in one
    if (isBottomSheet) {
      Navigator.of(context).pop();
    }
    final query = 'Tell me about Seshasai\'s experience with ${skill.name}';
    context.go('${AppRouter.chat}?query=${Uri.encodeComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isBottomSheet ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(skill.name,
                      style: Theme.of(context).textTheme.headlineSmall)),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(skill.category,
              style:
                  const TextStyle(color: AppTheme.primaryPurple, fontSize: 12)),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              const Text('Proficiency: ',
                  style: TextStyle(color: AppTheme.textMuted)),
              _ProficiencyDots(level: skill.proficiencyLevel),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text('${skill.yearsOfExperience}+ years experience',
              style: const TextStyle(color: AppTheme.textSecondary)),
          if (skill.description != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(skill.description!,
                style: const TextStyle(
                    color: AppTheme.textSecondary, height: 1.5)),
          ],
          if (isBottomSheet)
            const SizedBox(height: AppTheme.spacingXl)
          else
            const Spacer(),
          // Ask JUNNU AI Button
          GestureDetector(
            onTap: () => _askJunnuAi(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/junnu_ai.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Ask JUNNU AI',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }
}
