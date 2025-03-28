import 'room.dart';

class Day {
  final String id;
  final int number;
  final String date;
  final String name;
  final List<Room> rooms;

  Day({
    required this.id,
    required this.number,
    required this.date,
    required this.name,
    this.rooms = const [],
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    List<Room> roomsList = [];
    if (json['rooms'] != null) {
      roomsList = List<Room>.from(
        json['rooms'].map((x) => Room.fromJson(x)),
      );
    }

    return Day(
      id: json['_id'],
      number: json['number'] ?? 0,
      date: json['date'] ?? '',
      name: json['name'] ?? '',
      rooms: roomsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'number': number,
      'date': date,
      'name': name,
      'rooms': rooms.map((x) => x.id).toList(),
    };
  }
} 