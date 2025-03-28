import 'package:flutter/material.dart';
import '../models/partner.dart';

class PartnerLogoCard extends StatelessWidget {
  final Partner? partner;

  const PartnerLogoCard({
    super.key,
    this.partner,
  });

  @override
  Widget build(BuildContext context) {
    if (partner == null) {
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
            if (partner!.logoUrl != null && partner!.logoUrl!.isNotEmpty)
              Expanded(
                child: Image.network(
                  partner!.logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_balance,
                      size: 48,
                      color: Colors.grey,
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Icon(
                  Icons.account_balance,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              partner!.name,
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