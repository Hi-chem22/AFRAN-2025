class Speaker {
  final String id;
  final String name;
  final String title;
  final String institution;
  final String bio;
  final String country;
  final String photoUrl;
  final Map<String, String>? socialLinks;

  Speaker({
    required this.id,
    required this.name,
    this.title = '',
    this.institution = '',
    this.bio = '',
    this.country = '',
    this.photoUrl = '',
    this.socialLinks,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    Map<String, String> links = {};
    if (json['socialLinks'] != null) {
      json['socialLinks'].forEach((key, value) {
        links[key] = value.toString();
      });
    }

    return Speaker(
      id: json['_id'],
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      institution: json['institution'] ?? '',
      bio: json['bio'] ?? '',
      country: json['country'] ?? '',
      photoUrl: json['photo'] ?? '',
      socialLinks: links.isNotEmpty ? links : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'title': title,
      'institution': institution,
      'bio': bio,
      'country': country,
      'photo': photoUrl,
      'socialLinks': socialLinks,
    };
  }
}
