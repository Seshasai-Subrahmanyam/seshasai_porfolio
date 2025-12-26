import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/models.dart';

class AvailabilityPill extends StatefulWidget {
  final AvailabilityStatus status;
  final bool isLoading;

  const AvailabilityPill({
    super.key,
    required this.status,
    this.isLoading = false,
  });

  @override
  State<AvailabilityPill> createState() => _AvailabilityPillState();
}

class _AvailabilityPillState extends State<AvailabilityPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case AvailabilityStatus.openForWork:
        return AppTheme.availableOpenForWork;
      case AvailabilityStatus.busy:
        return AppTheme.availableBusy;
      case AvailabilityStatus.notAvailable:
        return AppTheme.availableNotAvailable;
    }
  }

  IconData get _statusIcon {
    switch (widget.status) {
      case AvailabilityStatus.openForWork:
        return Icons.check_circle_rounded;
      case AvailabilityStatus.busy:
        return Icons.schedule_rounded;
      case AvailabilityStatus.notAvailable:
        return Icons.do_not_disturb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Loading...',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: _statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            border: Border.all(
              color:
                  _statusColor.withAlpha((76 * _pulseAnimation.value).toInt()),
            ),
            boxShadow: [
              BoxShadow(
                color: _statusColor
                    .withAlpha((51 * _pulseAnimation.value).toInt()),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _statusIcon,
                color: _statusColor,
                size: 18,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                widget.status.displayText,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Removed custom AnimatedBuilder - using Flutter's built-in AnimatedBuilder
