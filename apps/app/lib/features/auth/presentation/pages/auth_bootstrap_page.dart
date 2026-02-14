import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

class AuthBootstrapPage extends ConsumerWidget {
  const AuthBootstrapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authAppContextBootstrapStatusProvider);
    final error = ref.watch(authAppContextErrorProvider);
    final isBusy = status == AuthAppContextBootstrapStatus.loading;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AuthMobileSpec.pageGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AuthMobileSpec.pageHorizontalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AuthMobileSpec.maxContentWidth,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AuthMobileSpec.surfaceRadius,
                    ),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.14),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(Icons.sync_rounded, size: 52),
                        const SizedBox(height: 12),
                        const Text(
                          'جارٍ تهيئة الحساب',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          error == null || error.trim().isEmpty
                              ? 'نقوم بمزامنة صلاحيات الحساب قبل فتح الصفحة الرئيسية.'
                              : 'تعذر مزامنة سياق الحساب: $error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .retryAppContextBootstrap();
                                },
                          icon: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded),
                          label: Text(isBusy ? 'جارٍ التحقق...' : 'إعادة المحاولة'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: isBusy
                              ? null
                              : () async {
                                  await ref.read(authControllerProvider.notifier).signOut();
                                  if (!context.mounted) {
                                    return;
                                  }
                                  context.go(RoutePaths.login);
                                },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('العودة لتسجيل الدخول'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
