import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter/services.dart';
import '../config/env.dart';
import '../models/models.dart';

/// Repository for loading resume data from backend API
class ResumeRepository {
  ResumeModel? _cachedResume;
  List<ProjectModel>? _cachedProjects;
  late final Dio _dio;

  ResumeRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.ragServerUrl,
        connectTimeout: Duration(seconds: Env.apiTimeoutSeconds),
        receiveTimeout: Duration(seconds: Env.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Load resume from backend API with local fallback
  Future<ResumeModel> loadResume() async {
    if (_cachedResume != null) {
      return _cachedResume!;
    }

    try {
      // Try to fetch from backend API
      final response = await _dio.get('/api/resume');

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        _cachedResume = ResumeModel.fromJson(jsonData as Map<String, dynamic>);
        debugPrint('✅ Resume loaded from backend API');
        return _cachedResume!;
      }
      throw Exception('Invalid response from API');
    } catch (e) {
      debugPrint('⚠️ Failed to fetch from API, falling back to local: $e');
      // Fallback to local assets
      return _loadResumeFromAssets();
    }
  }

  /// Load resume from local assets (fallback)
  Future<ResumeModel> _loadResumeFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/resume.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedResume = ResumeModel.fromJson(jsonData);
      debugPrint('📁 Resume loaded from local assets');
      return _cachedResume!;
    } catch (e) {
      throw Exception('Failed to load resume: $e');
    }
  }

  /// Load projects from resume
  Future<List<ProjectModel>> loadProjects() async {
    if (_cachedProjects != null) {
      return _cachedProjects!;
    }

    try {
      // Try to fetch from backend API
      final response = await _dio.get('/api/resume');

      if (response.statusCode == 200 && response.data != null) {
        final jsonData = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        final projectsList =
            (jsonData as Map<String, dynamic>)['projects'] as List<dynamic>? ??
                [];
        _cachedProjects = projectsList
            .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return _cachedProjects!;
      }
      throw Exception('Invalid response from API');
    } catch (e) {
      // Fallback to local assets
      return _loadProjectsFromAssets();
    }
  }

  /// Load projects from local assets (fallback)
  Future<List<ProjectModel>> _loadProjectsFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/resume.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final projectsList = jsonData['projects'] as List<dynamic>? ?? [];
      _cachedProjects = projectsList
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedProjects!;
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  /// Clear cache to force reload
  void clearCache() {
    _cachedResume = null;
    _cachedProjects = null;
  }

  /// Get a specific project by ID
  Future<ProjectModel?> getProjectById(String id) async {
    final projects = await loadProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get experiences from resume
  Future<List<Experience>> getExperiences() async {
    final resume = await loadResume();
    return resume.experiences;
  }

  /// Get skills from resume
  Future<List<Skill>> getSkills() async {
    final resume = await loadResume();
    return resume.skills;
  }

  /// Get skills by category
  Future<Map<String, List<Skill>>> getSkillsByCategory() async {
    final skills = await getSkills();
    final Map<String, List<Skill>> grouped = {};

    for (final skill in skills) {
      grouped.putIfAbsent(skill.category, () => []);
      grouped[skill.category]!.add(skill);
    }

    return grouped;
  }

  /// Get certificates from resume
  Future<List<Certificate>> getCertificates() async {
    final resume = await loadResume();
    return resume.certificates;
  }

  /// Get published apps from resume
  Future<List<PublishedApp>> getApps() async {
    final resume = await loadResume();
    return resume.apps;
  }

  /// Get personal info from resume
  Future<PersonalInfo> getPersonalInfo() async {
    final resume = await loadResume();
    return resume.personalInfo;
  }

  /// Get education from resume
  Future<List<Education>> getEducation() async {
    final resume = await loadResume();
    return resume.education;
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
