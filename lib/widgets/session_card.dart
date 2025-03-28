import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/speaker.dart';
import 'speaker_avatar.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horaire
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.startTime} - ${session.endTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Titre de la session
              Text(
                session.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Display chair information if available
              if (session.chairpersons != null && session.chairpersons!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.chairpersons!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Liste des interventions
              const Text(
                'Interventions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...session.subsessions.asMap().entries.map((entry) {
                final index = entry.key;
                final subsession = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subsession.title,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (subsession.speakers.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...subsession.speakers.map((speaker) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SpeakerAvatar(
                                        speaker: speaker,
                                        onTap: () {
                                          // Afficher la biographie du speaker
                                          _showSpeakerBio(context, speaker);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeakerBio(BuildContext context, Speaker speaker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(speaker.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (speaker.photoUrl.isNotEmpty)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(speaker.photoUrl),
                    onBackgroundImageError: (e, s) => {},
                    child: speaker.photoUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              const SizedBox(height: 16),
              if (speaker.title.isNotEmpty) ...[
                Text(
                  speaker.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (speaker.institution.isNotEmpty) ...[
                Text(
                  speaker.institution,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (speaker.country.isNotEmpty) ...[
                Text(
                  'Pays: ${speaker.country}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              if (speaker.bio.isNotEmpty)
                Text(
                  speaker.bio,
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
} 