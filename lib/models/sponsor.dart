class Sponsor {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final String tier;

  Sponsor({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    required this.tier,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo'],
      websiteUrl: json['website'],
      tier: json['tier'] ?? 'standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'logo': logoUrl,
      'website': websiteUrl,
      'tier': tier,
    };
  }
}
