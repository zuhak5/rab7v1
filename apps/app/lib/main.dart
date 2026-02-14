import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'data/supabase/supabase_client_provider.dart';
import 'features/auth/presentation/viewmodels/auth_controller.dart';
import 'features/notifications/presentation/notification_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final config = AppConfig.fromEnvironment();

  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const _Bootstrap(),
    ),
  );
}

class _Bootstrap extends ConsumerStatefulWidget {
  const _Bootstrap();

  @override
  ConsumerState<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<_Bootstrap> {
  @override
  void initState() {
    super.initState();

    Future<void>.microtask(() async {
      try {
        await ref.read(authControllerProvider.notifier).bootstrap();
      } catch (error, stackTrace) {
        debugPrint('Auth bootstrap failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      try {
        await ref.read(notificationBootstrapProvider).initialize();
      } catch (error, stackTrace) {
        debugPrint('Notification bootstrap failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const RideIqApp();
  }
}
