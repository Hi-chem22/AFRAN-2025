import 'speaker.dart';

class Subsession {
  final String id;
  final String title;
  final String? startTime;
  final String? endTime;
  final String? description;
  final List<Speaker> speakers;
  final List<Subsubsession> subsubsessions;
  final String? sessionId;

  Subsession({
    required this.id,
    required this.title,
    this.startTime,
    this.endTime,
    this.description,
    this.speakers = const [],
    this.subsubsessions = const [],
    this.sessionId,
  });

  factory Subsession.fromJson(Map<String, dynamic> json) {
    List<Speaker> speakersList = [];
    if (json['speakers'] != null) {
      speakersList = List<Speaker>.from(
        json['speakers'].map((x) => Speaker.fromJson(x)),
      );
    }

    List<Subsubsession> subsubsList = [];
    if (json['subsubsessions'] != null) {
      subsubsList = List<Subsubsession>.from(
        json['subsubsessions'].map((x) => Subsubsession.fromJson(x)),
      );
    }

    return Subsession(
      id: json['_id'],
      title: json['title'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      description: json['description'],
      speakers: speakersList,
      subsubsessions: subsubsList,
      sessionId: json['sessionId']?['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'speakers': speakers.map((x) => x.id).toList(),
      'sessionId': sessionId,
    };
  }
}

class Subsubsession {
  final String? id;
  final String title;
  final String? startTime;
  final String? endTime;
  final String? description;
  final List<Speaker> speakers;

  Subsubsession({
    this.id,
    required this.title,
    this.startTime,
    this.endTime,
    this.description,
    this.speakers = const [],
  });

  factory Subsubsession.fromJson(Map<String, dynamic> json) {
    List<Speaker> speakersList = [];
    if (json['speakers'] != null) {
      speakersList = List<Speaker>.from(
        json['speakers'].map((x) => Speaker.fromJson(x)),
      );
    }

    return Subsubsession(
      id: json['_id'],
      title: json['title'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      description: json['description'],
      speakers: speakersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'speakers': speakers.map((x) => x.id).toList(),
    };
  }
} 