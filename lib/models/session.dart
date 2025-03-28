import 'speaker.dart';
import 'subsession.dart';
import 'chairperson.dart';
import 'room.dart';
import 'day.dart';
import 'subsession_text.dart';

class Session {
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
  final List<Speaker> speakers;
  final List<Subsession> subsessions;
  final List<Chairperson> chairpersonRefs;
  final String? chairpersons;
  final List<SubsessionText> subsessionTexts;

  Session({
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
    this.speakers = const [],
    this.subsessions = const [],
    this.chairpersonRefs = const [],
    this.chairpersons,
    this.subsessionTexts = const [],
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    List<Speaker> speakersList = [];
    if (json['speakers'] != null) {
      speakersList = List<Speaker>.from(
        json['speakers'].map((x) => Speaker.fromJson(x)),
      );
    }

    List<Subsession> subsessionsList = [];
    if (json['subsessions'] != null) {
      subsessionsList = List<Subsession>.from(
        json['subsessions'].map((x) => Subsession.fromJson(x)),
      );
    }

    List<Chairperson> chairpersonRefsList = [];
    if (json['chairpersonRefs'] != null) {
      chairpersonRefsList = List<Chairperson>.from(
        json['chairpersonRefs'].map((x) => Chairperson.fromJson(x)),
      );
    }

    List<SubsessionText> subsessionTextsList = [];
    if (json['subsessionTexts'] != null) {
      subsessionTextsList = List<SubsessionText>.from(
        json['subsessionTexts'].map((x) => SubsessionText.fromJson(x)),
      );
    }

    return Session(
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
      speakers: speakersList,
      subsessions: subsessionsList,
      chairpersonRefs: chairpersonRefsList,
      chairpersons: json['chairpersons'],
      subsessionTexts: subsessionTextsList,
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
        'speakers': List<dynamic>.from(speakers.map((x) => x.toJson())),
        'subsessions': List<dynamic>.from(subsessions.map((x) => x.toJson())),
        'chairpersonRefs': List<dynamic>.from(chairpersonRefs.map((x) => x.toJson())),
        'chairpersons': chairpersons,
        'subsessionTexts': List<dynamic>.from(subsessionTexts.map((x) => x.toJson())),
      };
}
