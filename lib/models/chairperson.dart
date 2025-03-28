class Chairperson {
  final String id;
  final String name;
  final String? title;
  final String? institution;
  final String? bio;

  Chairperson({
    required this.id,
    required this.name,
    this.title,
    this.institution,
    this.bio,
  });

  factory Chairperson.fromJson(Map<String, dynamic> json) {
    return Chairperson(
      id: json['_id'],
      name: json['name'] ?? '',
      title: json['title'],
      institution: json['institution'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'title': title,
      'institution': institution,
      'bio': bio,
    };
  }
} 