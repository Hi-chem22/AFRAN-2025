import 'package:flutter/material.dart';
import '../models/sponsor.dart';

class SponsorLogoCard extends StatelessWidget {
  final Sponsor? sponsor;

  const SponsorLogoCard({
    super.key,
    this.sponsor,
  });

  @override
  Widget build(BuildContext context) {
    if (sponsor == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (sponsor!.logoUrl != null && sponsor!.logoUrl!.isNotEmpty)
              Expanded(
                child: Image.network(
                  sponsor!.logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.business,
                      size: 48,
                      color: Colors.grey,
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Icon(
                  Icons.business,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              sponsor!.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 