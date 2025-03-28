class SubsessionText {
  final String title;
  final String startTime;
  final String endTime;
  final String duration;
  final List<String> speakerIds;
  final String description;

  SubsessionText({
    required this.title,
    this.startTime = '',
    this.endTime = '',
    this.duration = '',
    this.speakerIds = const [],
    this.description = '',
  });

  factory SubsessionText.fromJson(Map<String, dynamic> json) {
    List<String> speakers = [];
    if (json['speakerIds'] != null) {
      speakers = List<String>.from(json['speakerIds']);
    }

    return SubsessionText(
      title: json['title'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? '',
      speakerIds: speakers,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'speakerIds': speakerIds,
        'description': description,
      };
} 