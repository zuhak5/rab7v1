import 'package:flutter/material.dart';

import '../../domain/entities/ride_request.dart';

class RideRequestCard extends StatelessWidget {
  const RideRequestCard({
    required this.request,
    required this.onCancel,
    required this.onMatch,
    super.key,
  });

  final RideRequestEntity request;
  final VoidCallback onCancel;
  final VoidCallback onMatch;

  Color _statusColor(BuildContext context) {
    switch (request.status) {
      case 'requested':
        return Theme.of(context).colorScheme.primary;
      case 'matched':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'cancelled':
      case 'expired':
      case 'no_driver':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${request.status}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  request.createdAt
                      .toLocal()
                      .toIso8601String()
                      .split('T')
                      .join(' '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Pickup: ${request.pickupAddress ?? '${request.pickupLat}, ${request.pickupLng}'}',
            ),
            Text(
              'Dropoff: ${request.dropoffAddress ?? '${request.dropoffLat}, ${request.dropoffLng}'}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: request.isActive ? onCancel : null,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: request.status == 'requested' ? onMatch : null,
                  icon: const Icon(Icons.search),
                  label: const Text('Trigger Match'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
