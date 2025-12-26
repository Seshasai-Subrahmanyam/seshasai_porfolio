import 'package:equatable/equatable.dart';

/// Project model for portfolio
class ProjectModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String? githubUrl;
  final String? demoUrl;
  final String? videoDemoUrl;
  final List<String> demoScreenshots;
  final List<String> technologies;
  final String? category;
  final bool featured;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.githubUrl,
    this.demoUrl,
    this.videoDemoUrl,
    this.demoScreenshots = const [],
    this.technologies = const [],
    this.category,
    this.featured = false,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      githubUrl: json['githubUrl'] as String?,
      demoUrl: json['demoUrl'] as String?,
      videoDemoUrl: json['videoDemoUrl'] as String?,
      demoScreenshots: (json['demoScreenshots'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      technologies: (json['technologies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String?,
      featured: json['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        if (githubUrl != null) 'githubUrl': githubUrl,
        if (demoUrl != null) 'demoUrl': demoUrl,
        if (videoDemoUrl != null) 'videoDemoUrl': videoDemoUrl,
        if (demoScreenshots.isNotEmpty) 'demoScreenshots': demoScreenshots,
        'technologies': technologies,
        if (category != null) 'category': category,
        'featured': featured,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnailUrl,
        githubUrl,
        demoUrl,
        videoDemoUrl,
        demoScreenshots,
        technologies,
        category,
        featured,
      ];
}

/// Project story request to Make.com
class ProjectStoryRequest extends Equatable {
  final String section = 'project_story';
  final String projectId;
  final String persona;

  const ProjectStoryRequest({
    required this.projectId,
    required this.persona,
  });

  Map<String, dynamic> toJson() => {
        'section': section,
        'project_id': projectId,
        'persona': persona,
      };

  @override
  List<Object?> get props => [projectId, persona];
}

/// Project story response from Make.com
class ProjectStoryResponse extends Equatable {
  final String headline;
  final String storyMarkdown;
  final List<String> techBreakdown;
  final ProjectStoryLinks links;

  const ProjectStoryResponse({
    required this.headline,
    required this.storyMarkdown,
    required this.techBreakdown,
    required this.links,
  });

  factory ProjectStoryResponse.fromJson(Map<String, dynamic> json) {
    return ProjectStoryResponse(
      headline: json['headline'] as String? ?? '',
      storyMarkdown: json['story_markdown'] as String? ?? '',
      techBreakdown: (json['tech_breakdown'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      links: ProjectStoryLinks.fromJson(
          json['links'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [headline, storyMarkdown, techBreakdown, links];
}

/// Links in project story response
class ProjectStoryLinks extends Equatable {
  final String? github;
  final String? demo;

  const ProjectStoryLinks({this.github, this.demo});

  factory ProjectStoryLinks.fromJson(Map<String, dynamic> json) {
    return ProjectStoryLinks(
      github: json['github'] as String?,
      demo: json['demo'] as String?,
    );
  }

  @override
  List<Object?> get props => [github, demo];
}
