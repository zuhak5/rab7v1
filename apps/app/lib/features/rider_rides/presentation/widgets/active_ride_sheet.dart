import 'package:flutter/material.dart';

import '../../domain/entities/ride.dart';

class ActiveRideSheet extends StatelessWidget {
  const ActiveRideSheet({super.key, this.ride});

  final RideEntity? ride;

  @override
  Widget build(BuildContext context) {
    if (ride == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(width: 48, child: Divider(thickness: 5)),
          ),
          const SizedBox(height: 12),
          Text('Active Ride', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Ride ID: ${ride!.id}'),
          Text('Status: ${ride!.status}'),
          Text('Version: ${ride!.version}'),
          if (ride!.driverId != null) Text('Driver: ${ride!.driverId}'),
          if (ride!.fareAmountIqd != null)
            Text('Fare (IQD): ${ride!.fareAmountIqd}'),
        ],
      ),
    );
  }
}
