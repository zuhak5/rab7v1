import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';
import '../../../rider_rides/domain/entities/ride_request.dart';
import '../../../rider_rides/presentation/viewmodels/rides_list_controller.dart';
import '../viewmodels/rider_home_controller.dart';
import '../viewmodels/rider_home_state.dart';
import '../widgets/bottom_nav_shell.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesListControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF3F6FA), Color(0xFFF7F9FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => context.go(RoutePaths.rides),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      const Expanded(
                        child: Text(
                          'النشاط',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            ref.read(ridesListControllerProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(ridesListControllerProvider.notifier).refresh(),
                  child: ridesAsync.when(
                    data: (requests) {
                      if (requests.isEmpty) {
                        return ListView(
                          children: const <Widget>[
                            SizedBox(height: 140),
                            Center(
                              child: Text(
                                'لا يوجد نشاط حتى الآن',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: requests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return _ActivityCard(request: request);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text('تعذر تحميل النشاط: $error'),
                    ),
                  ),
                ),
              ),
              BottomNavShell(
                activeTab: HomeBottomTab.activity,
                onTabSelected: (tab) {
                  ref.read(riderHomeControllerProvider.notifier).setBottomTab(tab);
                  switch (tab) {
                    case HomeBottomTab.home:
                      context.go(RoutePaths.rides);
                    case HomeBottomTab.activity:
                      context.go(RoutePaths.activity);
                    case HomeBottomTab.account:
                      context.go(RoutePaths.account);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.request});

  final RideRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _StatusChip(status: request.status),
              const Spacer(),
              Text(
                request.createdAt.toLocal().toString().split('.').first,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.pickupAddress ?? '${request.pickupLat}, ${request.pickupLng}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            request.dropoffAddress ?? '${request.dropoffLat}, ${request.dropoffLng}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'requested' => Colors.blue,
      'matched' => Colors.orange,
      'accepted' => Colors.green,
      'assigned' => Colors.green,
      'arrived' => Colors.green,
      'in_progress' => Colors.green,
      'cancelled' => Colors.red,
      'canceled' => Colors.red,
      'completed' => Colors.teal,
      _ => Colors.grey,
    };

    final label = switch (status) {
      'requested' => 'تم الإرسال',
      'matched' => 'مطابقة',
      'accepted' => 'مقبول',
      'assigned' => 'مقبول',
      'arrived' => 'وصل السائق',
      'in_progress' => 'جارية',
      'cancelled' => 'ملغية',
      'canceled' => 'ملغية',
      'completed' => 'مكتملة',
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
