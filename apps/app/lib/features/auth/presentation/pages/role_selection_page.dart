import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';
import '../../domain/entities/sign_up_role.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  static const List<SignUpRole> _roles = <SignUpRole>[
    SignUpRole.customer,
    SignUpRole.driver,
    SignUpRole.merchant,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedSignUpRoleProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AuthMobileSpec.pageGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AuthMobileSpec.pageHorizontalPadding,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AuthMobileSpec.maxContentWidth),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AuthMobileSpec.surfaceRadius),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.75)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'اختر نوع الحساب',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اختر الدور الذي ستستخدم به التطبيق قبل إكمال البيانات.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final role in _roles) ...<Widget>[
                        _RoleOptionCard(
                          key: ValueKey<String>('role_option_${role.value}'),
                          role: role,
                          selected: selectedRole == role,
                          onTap: () {
                            ref.read(selectedSignUpRoleProvider.notifier).state = role;
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                      FilledButton(
                        key: const ValueKey<String>('role_continue_button'),
                        onPressed: selectedRole == null
                            ? null
                            : () {
                                context.go(RoutePaths.profileSetup);
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                          ),
                        ),
                        child: const Text('متابعة'),
                      ),
                    ],
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

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.role,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SignUpRole role;
  final bool selected;
  final VoidCallback onTap;

  IconData _icon(SignUpRole role) => switch (role) {
    SignUpRole.customer => Icons.person_rounded,
    SignUpRole.driver => Icons.local_taxi_rounded,
    SignUpRole.merchant => Icons.storefront_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AuthMobileSpec.shortDuration,
        curve: AuthMobileSpec.standardCurve,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? colors.primary : colors.outline.withValues(alpha: 0.8),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: selected
                  ? colors.primary.withValues(alpha: 0.14)
                  : colors.surfaceContainerHighest,
              child: Icon(_icon(role), color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    role.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
