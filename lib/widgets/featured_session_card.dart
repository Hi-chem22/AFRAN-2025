import 'package:flutter/material.dart';
import '../models/session.dart';

class FeaturedSessionCard extends StatelessWidget {
  final Session? session;

  const FeaturedSessionCard({
    super.key,
    this.session,
  });

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horaire et salle
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session!.startTime} - ${session!.endTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.room,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  session!.roomData?.name ?? session!.room ?? '',
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
              session!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Display chair information if available
            if (session!.chairpersons != null && session!.chairpersons!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      session!.chairpersons!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // Nombre d'interventions
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session!.subsessions.length} intervention${session!.subsessions.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 