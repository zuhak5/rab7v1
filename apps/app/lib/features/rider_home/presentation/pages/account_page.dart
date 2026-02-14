import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';
import '../../../auth/presentation/viewmodels/auth_controller.dart';
import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_controller.dart';
import '../viewmodels/rider_home_data_controller.dart';
import '../viewmodels/rider_home_state.dart';
import '../viewmodels/theme_mode_controller.dart';
import '../widgets/bottom_nav_shell.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletAccountProvider);
    final profileAsync = ref.watch(riderProfileProvider);
    final wallet = walletAsync.valueOrNull;
    final profile = profileAsync.valueOrNull;
    final avatarUrl = profile?.avatarUrl;
    final resolvedAvatarUrl =
        avatarUrl == null || avatarUrl.isEmpty ? null : avatarUrl;
    final themeMode =
        ref.watch(appThemeModeControllerProvider).valueOrNull ??
        ThemeMode.system;
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
                          'حسابي',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
                      ),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: resolvedAvatarUrl == null
                                ? null
                                : NetworkImage(resolvedAvatarUrl),
                            child: resolvedAvatarUrl == null
                                ? const Icon(Icons.person_rounded, size: 26)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  profile?.displayName ?? 'مستخدم RideIQ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  profile?.phoneE164 ?? '—',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'المحفظة',
                      trailing: walletAsync.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              walletAsync.hasError
                                  ? 'خطأ'
                                  : wallet == null
                                  ? '—'
                                  : '${wallet.balanceIqd} د.ع',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    if (walletAsync.hasError || profileAsync.hasError) ...<Widget>[
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          ref.invalidate(walletAccountProvider);
                          ref.invalidate(riderProfileProvider);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة تحميل بيانات الحساب'),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: colors.surface,
                      value: themeMode == ThemeMode.dark,
                      title: const Text(
                        'الوضع الداكن',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onChanged: (_) {
                        ref.read(appThemeModeControllerProvider.notifier).toggleDark();
                      },
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (!context.mounted) {
                          return;
                        }
                        context.go(RoutePaths.login);
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              ),
              BottomNavShell(
                activeTab: HomeBottomTab.account,
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: HomeMobileSpec.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
