import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../core/data/data.dart';
import '../core/network/make_api_client.dart';
import '../core/network/rag_api_client.dart';
import '../core/storage/local_prefs.dart';
import '../core/models/models.dart';
import 'router/app_router.dart';

/// Main application widget
class PortfolioApp extends StatelessWidget {
  final LocalPrefs localPrefs;
  final ResumeRepository resumeRepository;
  // final AvailabilityRepository availabilityRepository;
  final MakeApiClient apiClient;
  final RagApiClient ragApiClient;

  const PortfolioApp({
    super.key,
    required this.localPrefs,
    required this.resumeRepository,
    // required this.availabilityRepository,
    required this.apiClient,
    required this.ragApiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: localPrefs),
        RepositoryProvider.value(value: resumeRepository),
        // RepositoryProvider.value(value: availabilityRepository),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: ragApiClient),
      ],
      child: MaterialApp.router(
        title: 'Seshasai Subrahmanyam - Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return _SplashScreenWrapper(
            resumeRepository: resumeRepository,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

/// Splash screen wrapper that loads resume data before showing app content
class _SplashScreenWrapper extends StatefulWidget {
  final ResumeRepository resumeRepository;
  final Widget child;

  const _SplashScreenWrapper({
    required this.resumeRepository,
    required this.child,
  });

  @override
  State<_SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<_SplashScreenWrapper>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  PersonalInfo? _personalInfo;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // First get personal info for splash screen
      final info = await widget.resumeRepository.getPersonalInfo();
      if (mounted) {
        setState(() => _personalInfo = info);
      }

      // Preload all resume data
      await widget.resumeRepository.loadResume();
      await widget.resumeRepository.loadProjects();

      // Add minimum splash duration for UX
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _fadeController.forward().then((_) {
          setState(() => _isLoading = false);
        });
      }
    } catch (e) {
      // On error, still show the app
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _SplashScreen(
        personalInfo: _personalInfo,
        fadeAnimation: _fadeAnimation,
      );
    }
    return widget.child;
  }
}

/// Beautiful splash screen with gradient background
class _SplashScreen extends StatelessWidget {
  final PersonalInfo? personalInfo;
  final Animation<double> fadeAnimation;

  const _SplashScreen({
    this.personalInfo,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: personalInfo?.profileImageUrl != null
                      ? Image.network(
                          personalInfo!.profileImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppTheme.bgElevated,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryPurple,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppTheme.bgElevated,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.bgElevated,
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.textMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              Text(
                personalInfo?.name ?? 'Seshasai Subrahmanyam',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Portfolio text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 119, 119),
                    Color.fromARGB(255, 255, 185, 123),
                    Colors.white60,
                    AppTheme.primaryGreen,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'PORTFOLIO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryPurple.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
