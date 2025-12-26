import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/landing/view/landing_page.dart';
import '../../features/journey/view/journey_page.dart';
import '../../features/projects/view/projects_page.dart';
import '../../features/projects/view/project_detail_page.dart';
import '../../features/chat/view/chat_page.dart';
import '../../features/skills/view/skills_page.dart';
import '../../features/certificates/view/certificates_page.dart';
import '../../features/apps/view/apps_page.dart';
import '../../features/education/view/education_page.dart';
import '../../features/landing/bloc/resume_bloc.dart';

import '../../core/data/data.dart';
import '../widgets/app_shell.dart';

/// Application router using go_router
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  /// Route paths
  static const String landing = '/';
  static const String journey = '/journey';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String chat = '/chat';
  static const String skills = '/skills';
  static const String certificates = '/certificates';
  static const String apps = '/apps';
  static const String education = '/education';

  /// Get route configuration
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: landing,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => ResumeBloc(
              repository: context.read<ResumeRepository>(),
            )..add(const LoadResumeInfo()),
            child: AppShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: landing,
            name: 'landing',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LandingPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: journey,
            name: 'journey',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const JourneyPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: projects,
            name: 'projects',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProjectsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: projectDetail,
            name: 'projectDetail',
            pageBuilder: (context, state) {
              final projectId = state.pathParameters['id'] ?? '';
              return CustomTransitionPage(
                key: state.pageKey,
                child: ProjectDetailPage(projectId: projectId),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
          GoRoute(
            path: chat,
            name: 'chat',
            pageBuilder: (context, state) {
              // Get optional query parameter for pre-filled message
              final initialQuery = state.uri.queryParameters['query'];
              return CustomTransitionPage(
                key: state.pageKey,
                child: ChatPage(initialQuery: initialQuery),
                transitionsBuilder: _fadeTransition,
              );
            },
          ),
          GoRoute(
            path: skills,
            name: 'skills',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SkillsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: certificates,
            name: 'certificates',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CertificatesPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: apps,
            name: 'apps',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AppsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: education,
            name: 'education',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const EducationPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
  );

  /// Fade transition animation
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    );
  }

  /// Slide transition animation
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}
  // {
    //   "id": "proj_13",
    //   "title": "Foundational Large Language Model",
    //   "description": "Implemented Transformer architecture from scratch.",
    //   "technologies": [
    //     "Python",
    //     "Deep Learning"
    //   ],
    //   "category": "AI / ML",
    //   "featured": false
    // }
    //   {
    //   "id": "skill_5",
    //   "name": "Security",
    //   "category": "Security & Encryption",
    //   "proficiencyLevel": 4,
    //   "yearsOfExperience": 5,
    //   "description": "ECDH Key Exchange, HMAC, AES-GCM, Secure Storage."
    // }