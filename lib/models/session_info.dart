import 'dart:convert';

class SessionInfo {
  final String id;
  final String title;
  final String? room;
  final String? roomId;
  final int? day;
  final String? dayId;
  final String startTime;
  final String endTime;
  final String? duration;
  final String? description;
  final String? chairpersons;  // Text representation of chairpersons
  final List<SubsessionText> subsessionTexts;

  SessionInfo({
    required this.id,
    required this.title,
    this.room,
    this.roomId,
    this.day,
    this.dayId,
    required this.startTime,
    required this.endTime,
    this.duration,
    this.description,
    this.chairpersons,
    this.subsessionTexts = const [],
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    // Handle subsession texts
    List<SubsessionText> parsedSubsessionTexts = [];
    if (json['subsessionTexts'] != null) {
      parsedSubsessionTexts = List<SubsessionText>.from(
        json['subsessionTexts'].map((x) => SubsessionText.fromJson(x)),
      );
    }

    return SessionInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      room: json['room'],
      roomId: json['roomId']?['_id'] ?? json['roomId'],
      day: json['day'],
      dayId: json['dayId']?['_id'] ?? json['dayId'],
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'],
      description: json['description'],
      chairpersons: json['chairpersons'],
      subsessionTexts: parsedSubsessionTexts,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'room': room,
        'roomId': roomId,
        'day': day,
        'dayId': dayId,
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'description': description,
        'chairpersons': chairpersons,
        'subsessionTexts': List<dynamic>.from(subsessionTexts.map((x) => x.toJson())),
      };
}

class SubsessionText {
  final String title;
  final String? startTime;
  final String? endTime;
  final String? duration;
  final List<String> speakerIds;
  final String? description;

  SubsessionText({
    required this.title,
    this.startTime,
    this.endTime,
    this.duration,
    this.speakerIds = const [],
    this.description,
  });

  factory SubsessionText.fromJson(Map<String, dynamic> json) {
    List<String> speakers = [];
    if (json['speakerIds'] != null) {
      speakers = List<String>.from(json['speakerIds']);
    }

    return SubsessionText(
      title: json['title'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
      speakerIds: speakers,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'speakerIds': List<dynamic>.from(speakerIds),
        'description': description,
      };
} 