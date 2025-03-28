import 'package:flutter/material.dart';
import '../models/speaker.dart';

class SpeakerAvatar extends StatelessWidget {
  final Speaker speaker;
  final VoidCallback? onTap;
  final double radius;

  const SpeakerAvatar({
    super.key,
    required this.speaker,
    this.onTap,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: speaker.name,
        child: CircleAvatar(
          radius: radius,
          backgroundImage: speaker.photoUrl.isNotEmpty
              ? NetworkImage(speaker.photoUrl)
              : null,
          onBackgroundImageError: (e, s) => {},
          child: speaker.photoUrl.isEmpty
              ? Icon(Icons.person, size: radius)
              : null,
        ),
      ),
    );
  }
} 