class Partner {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final String type;

  Partner({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    required this.type,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo'],
      websiteUrl: json['website'],
      type: json['type'] ?? 'standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'logo': logoUrl,
      'website': websiteUrl,
      'type': type,
    };
  }
} 