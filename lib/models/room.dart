class Room {
  final String id;
  final String name;
  final String? location;
  final int? capacity;

  Room({
    required this.id,
    required this.name,
    this.location,
    this.capacity,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      name: json['name'] ?? '',
      location: json['location'],
      capacity: json['capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
    };
  }
} 