import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProfileImage extends StatefulWidget {
  final String imagePath;
  const ProfileImage({required this.imagePath});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
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
                  child: Image.asset(widget.imagePath, fit: BoxFit.contain),
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
            borderRadius: BorderRadius.circular(_isHovered
                ? 32
                : AppTheme
                    .radiusMedium), // Circle on hover, rounded rect otherwise
            boxShadow: _isHovered ? AppTheme.smoothShadow : [],
            border: _isHovered
                ? Border.all(color: AppTheme.primaryBlue, width: 2)
                : null,
          ),
          child: Center(
            child: CircleAvatar(
              radius: 28, // 56/2 approx to fit inside 64
              backgroundColor: AppTheme.bgDark,
              backgroundImage: AssetImage(widget.imagePath),
            ),
          ),
        ),
      ),
    );
  }
}
