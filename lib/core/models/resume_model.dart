import 'package:equatable/equatable.dart';

/// Complete resume data model
class ResumeModel extends Equatable {
  final PersonalInfo personalInfo;
  final List<Experience> experiences;
  final List<Skill> skills;
  final List<Certificate> certificates;
  final List<PublishedApp> apps;
  final List<Education> education;

  const ResumeModel({
    required this.personalInfo,
    required this.experiences,
    required this.skills,
    required this.certificates,
    required this.apps,
    required this.education,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      personalInfo: PersonalInfo.fromJson(
          json['personalInfo'] as Map<String, dynamic>? ?? {}),
      experiences: (json['experiences'] as List<dynamic>?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((e) => Certificate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      apps: (json['apps'] as List<dynamic>?)
              ?.map((e) => PublishedApp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'personalInfo': personalInfo.toJson(),
        'experiences': experiences.map((e) => e.toJson()).toList(),
        'skills': skills.map((e) => e.toJson()).toList(),
        'certificates': certificates.map((e) => e.toJson()).toList(),
        'apps': apps.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [personalInfo, experiences, skills, certificates, apps, education];
}

/// Personal information
class PersonalInfo extends Equatable {
  final String name;
  final String title;
  final String summary;
  final String email;
  final String? phone;
  final String? location;
  final String? linkedIn;
  final String? github;
  final String? medium;
  final String? profileImageUrl;
  final String? availability;
  final DateTime? availabilityUpdated;

  const PersonalInfo({
    required this.name,
    required this.title,
    required this.summary,
    required this.email,
    this.phone,
    this.location,
    this.linkedIn,
    this.github,
    this.medium,
    this.profileImageUrl,
    this.availability,
    this.availabilityUpdated,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      linkedIn: json['linkedIn'] as String?,
      github: json['github'] as String?,
      medium: json['medium'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      availability: json['availability'] as String?,
      availabilityUpdated: json['availabilityUpdated'] != null
          ? DateTime.tryParse(json['availabilityUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'summary': summary,
        'email': email,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
        if (linkedIn != null) 'linkedIn': linkedIn,
        if (github != null) 'github': github,
        if (medium != null) 'medium': medium,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (availability != null) 'availability': availability,
        if (availabilityUpdated != null)
          'availabilityUpdated': availabilityUpdated!.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        name,
        title,
        summary,
        email,
        phone,
        location,
        linkedIn,
        github,
        medium,
        profileImageUrl,
        availability,
        availabilityUpdated,
      ];
}

/// Work experience
class Experience extends Equatable {
  final String id;
  final String company;
  final String title;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final String location;
  final List<String> highlights;
  final List<String> technologies;
  final String? logoUrl;

  const Experience({
    required this.id,
    required this.company,
    required this.title,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    required this.location,
    required this.highlights,
    this.technologies = const [],
    this.logoUrl,
  });

  String get duration {
    final start = startDate;
    final end = isCurrent ? 'Present' : (endDate ?? '');
    return '$start - $end';
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as String? ?? '',
      company: json['company'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      isCurrent: json['isCurrent'] as bool? ?? false,
      location: json['location'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      technologies: (json['technologies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'title': title,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        'isCurrent': isCurrent,
        'location': location,
        'highlights': highlights,
        'technologies': technologies,
        if (logoUrl != null) 'logoUrl': logoUrl,
      };

  @override
  List<Object?> get props => [
        id,
        company,
        title,
        startDate,
        endDate,
        isCurrent,
        location,
        highlights,
        technologies,
        logoUrl,
      ];
}

/// Skill with category and proficiency
class Skill extends Equatable {
  final String id;
  final String name;
  final String category;
  final int proficiencyLevel; // 1-5
  final int yearsOfExperience;
  final String? iconUrl;
  final String? description;

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.proficiencyLevel,
    this.yearsOfExperience = 0,
    this.iconUrl,
    this.description,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      proficiencyLevel: json['proficiencyLevel'] as int? ?? 3,
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
      iconUrl: json['iconUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'proficiencyLevel': proficiencyLevel,
        'yearsOfExperience': yearsOfExperience,
        if (iconUrl != null) 'iconUrl': iconUrl,
        if (description != null) 'description': description,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        proficiencyLevel,
        yearsOfExperience,
        iconUrl,
        description,
      ];
}

/// Certificate or credential
class Certificate extends Equatable {
  final String id;
  final String name;
  final String issuer;
  final String issueDate;
  final String? expiryDate;
  final String? credentialUrl;
  final String? badgeUrl;
  final String? description;

  const Certificate({
    required this.id,
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    this.credentialUrl,
    this.badgeUrl,
    this.description,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      issueDate: json['issueDate'] as String? ?? '',
      expiryDate: json['expiryDate'] as String?,
      credentialUrl: json['credentialUrl'] as String?,
      badgeUrl: json['badgeUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'issuer': issuer,
        'issueDate': issueDate,
        if (expiryDate != null) 'expiryDate': expiryDate,
        if (credentialUrl != null) 'credentialUrl': credentialUrl,
        if (badgeUrl != null) 'badgeUrl': badgeUrl,
        if (description != null) 'description': description,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        issuer,
        issueDate,
        expiryDate,
        credentialUrl,
        badgeUrl,
        description
      ];
}

/// Published app on app stores
class PublishedApp extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? webUrl;
  final int? downloads;
  final double? rating;

  const PublishedApp({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.playStoreUrl,
    this.appStoreUrl,
    this.webUrl,
    this.downloads,
    this.rating,
  });

  factory PublishedApp.fromJson(Map<String, dynamic> json) {
    return PublishedApp(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? '',
      playStoreUrl: json['playStoreUrl'] as String?,
      appStoreUrl: json['appStoreUrl'] as String?,
      webUrl: json['webUrl'] as String?,
      downloads: json['downloads'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        if (playStoreUrl != null) 'playStoreUrl': playStoreUrl,
        if (appStoreUrl != null) 'appStoreUrl': appStoreUrl,
        if (webUrl != null) 'webUrl': webUrl,
        if (downloads != null) 'downloads': downloads,
        if (rating != null) 'rating': rating,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        playStoreUrl,
        appStoreUrl,
        webUrl,
        downloads,
        rating,
      ];
}

/// Education entry
class Education extends Equatable {
  final String id;
  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String? endDate;
  final String? gpa;
  final List<String> achievements;

  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.achievements = const [],
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      field: json['field'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      gpa: json['gpa'] as String?,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institution,
        'degree': degree,
        'field': field,
        'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (gpa != null) 'gpa': gpa,
        'achievements': achievements,
      };

  @override
  List<Object?> get props => [
        id,
        institution,
        degree,
        field,
        startDate,
        endDate,
        gpa,
        achievements,
      ];
}
