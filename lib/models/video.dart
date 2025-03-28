import 'session_info.dart';

class Video {
  final String id;
  final String title;
  final String description;
  final String url;
  final String? thumbnailUrl;
  final String? category;
  final String? duration;
  final String? speaker;
  final DateTime? date;
  final bool featured;
  final bool active;
  final int order;
  final SessionInfo? session;

  Video({
    required this.id,
    required this.title,
    this.description = '',
    required this.url,
    this.thumbnailUrl,
    this.category,
    this.duration,
    this.speaker,
    this.date,
    this.featured = false,
    this.active = true,
    this.order = 0,
    this.session,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    // Parse the session if it exists
    SessionInfo? sessionInfo;
    if (json['sessionId'] != null && json['sessionId'] is Map<String, dynamic>) {
      sessionInfo = SessionInfo.fromJson(json['sessionId']);
    }

    return Video(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      category: json['category'],
      duration: json['duration'],
      speaker: json['speaker'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      featured: json['featured'] ?? false,
      active: json['active'] ?? true,
      order: json['order'] ?? 0,
      session: sessionInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'category': category,
        'duration': duration,
        'speaker': speaker,
        'date': date?.toIso8601String(),
        'featured': featured,
        'active': active,
        'order': order,
        'sessionId': session?.id,
      };
} 