import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef RealtimePayload = Map<String, dynamic>;

class RealtimeSubscriptionManager {
  RealtimeSubscriptionManager(this._client);

  final SupabaseClient _client;
  final Map<String, _ManagedRealtimeSubscription> _managed = {};

  Stream<RealtimePayload> watchPostgres({
    required String key,
    required String schema,
    required String table,
    PostgresChangeFilter? filter,
    PostgresChangeEvent event = PostgresChangeEvent.all,
  }) {
    return _acquire(
      key: 'pg:$key',
      builder: () => _buildPostgres(
        key: 'pg:$key',
        schema: schema,
        table: table,
        filter: filter,
        event: event,
      ),
    );
  }

  Stream<RealtimePayload> watchBroadcast({
    required String key,
    required String topic,
    String event = '*',
  }) {
    return _acquire(
      key: 'bc:$key',
      builder: () =>
          _buildBroadcast(key: 'bc:$key', topic: topic, event: event),
    );
  }

  Stream<RealtimePayload> _acquire({
    required String key,
    required _ManagedRealtimeSubscription Function() builder,
  }) {
    final managed = _managed.putIfAbsent(key, builder);

    return Stream<RealtimePayload>.multi((controller) {
      managed.refCount += 1;
      final sub = managed.controller.stream.listen(
        controller.add,
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await sub.cancel();
        managed.refCount -= 1;
        if (managed.refCount <= 0) {
          await managed.dispose();
          _managed.remove(key);
        }
      };
    });
  }

  _ManagedRealtimeSubscription _buildPostgres({
    required String key,
    required String schema,
    required String table,
    required PostgresChangeEvent event,
    PostgresChangeFilter? filter,
  }) {
    final managed = _ManagedRealtimeSubscription(
      key: key,
      controller: StreamController<RealtimePayload>.broadcast(),
    );

    managed.attach = () {
      final channel = _client.channel('rideiq_$key');
      managed.channel = channel;

      channel
          .onPostgresChanges(
            event: event,
            schema: schema,
            table: table,
            filter: filter,
            callback: (payload) {
              managed.controller.add({
                'kind': 'postgres',
                'schema': schema,
                'table': table,
                'eventType': payload.eventType,
                'new': payload.newRecord,
                'old': payload.oldRecord,
                'raw': payload,
              });
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              managed.resetBackoff();
              return;
            }

            if (status == RealtimeSubscribeStatus.channelError ||
                status == RealtimeSubscribeStatus.timedOut ||
                status == RealtimeSubscribeStatus.closed) {
              managed.scheduleReconnect();
              if (error != null) {
                managed.controller.addError(StateError(error.toString()));
              }
            }
          });
    };

    managed.attach();
    return managed;
  }

  _ManagedRealtimeSubscription _buildBroadcast({
    required String key,
    required String topic,
    required String event,
  }) {
    final managed = _ManagedRealtimeSubscription(
      key: key,
      controller: StreamController<RealtimePayload>.broadcast(),
    );

    managed.attach = () {
      final channel = _client.channel(topic);
      managed.channel = channel;

      channel
          .onBroadcast(
            event: event,
            callback: (payload) {
              managed.controller.add({
                'kind': 'broadcast',
                'topic': topic,
                'event': event,
                'payload': payload,
              });
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              managed.resetBackoff();
              return;
            }

            if (status == RealtimeSubscribeStatus.channelError ||
                status == RealtimeSubscribeStatus.timedOut ||
                status == RealtimeSubscribeStatus.closed) {
              managed.scheduleReconnect();
              if (error != null) {
                managed.controller.addError(StateError(error.toString()));
              }
            }
          });
    };

    managed.attach();
    return managed;
  }

  Future<void> dispose() async {
    final values = _managed.values.toList(growable: false);
    _managed.clear();
    for (final item in values) {
      await item.dispose();
    }
  }
}

class _ManagedRealtimeSubscription {
  _ManagedRealtimeSubscription({required this.key, required this.controller});

  final String key;
  final StreamController<RealtimePayload> controller;

  RealtimeChannel? channel;
  late void Function() attach;
  int refCount = 0;
  Duration _reconnectDelay = const Duration(seconds: 1);
  Timer? _reconnectTimer;
  bool _disposed = false;

  void resetBackoff() {
    _reconnectDelay = const Duration(seconds: 1);
  }

  void scheduleReconnect() {
    if (_disposed || _reconnectTimer?.isActive == true) {
      return;
    }

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_disposed) {
        return;
      }

      attach();
      _reconnectDelay = Duration(
        seconds: (_reconnectDelay.inSeconds * 2).clamp(1, 30),
      );
    });
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    final activeChannel = channel;
    channel = null;
    if (activeChannel != null) {
      await activeChannel.unsubscribe();
    }
    await controller.close();
    debugPrint('Disposed realtime subscription: $key');
  }
}
