import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class AccountSheet extends StatelessWidget {
  const AccountSheet({
    required this.isOpen,
    required this.topOffset,
    required this.walletText,
    required this.isWalletLoading,
    required this.isDarkMode,
    required this.onDismiss,
    required this.onThemeToggle,
    required this.onWalletTap,
    required this.onLogoutTap,
    super.key,
  });

  final bool isOpen;
  final double topOffset;
  final String walletText;
  final bool isWalletLoading;
  final bool isDarkMode;
  final VoidCallback onDismiss;
  final VoidCallback onThemeToggle;
  final VoidCallback onWalletTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IgnorePointer(
      ignoring: !isOpen,
      child: AnimatedOpacity(
        opacity: isOpen ? 1 : 0,
        duration: HomeMobileSpec.overlayDuration,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: onDismiss,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: topOffset,
              left: 16,
              right: 16,
              child: Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 292,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.7),
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.dark_mode_rounded,
                                    size: 20,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'الوضع الداكن',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  _ThemeSwitch(
                                    isDarkMode: isDarkMode,
                                    onTap: onThemeToggle,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _ActionRow(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'المحفظة',
                              trailing: isWalletLoading ? '...' : walletText,
                              onTap: onWalletTap,
                            ),
                            const SizedBox(height: 4),
                            _ActionRow(
                              icon: Icons.logout_rounded,
                              label: 'تسجيل الخروج',
                              trailing: '',
                              danger: true,
                              onTap: onLogoutTap,
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        top: -8,
                        end: 22,
                        child: Transform.rotate(
                          angle: 0.78,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              border: BorderDirectional(
                                top: BorderSide(
                                  color: colors.outline.withValues(alpha: 0.7),
                                ),
                                start: BorderSide(
                                  color: colors.outline.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch({required this.isDarkMode, required this.onTap});

  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: HomeMobileSpec.panelDuration,
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.08),
          ),
          gradient: LinearGradient(
            colors: isDarkMode
                ? const <Color>[Color(0xFF0A162C), Color(0xFF231038)]
                : const <Color>[Color(0xFFA6E0FF), Color(0xFFFFDDA6)],
          ),
        ),
        child: AnimatedAlign(
          duration: HomeMobileSpec.panelDuration,
          curve: HomeMobileSpec.standardEase,
          alignment: isDarkMode ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode ? const Color(0xFFFFF4D0) : Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.28),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String trailing;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = danger ? Colors.red.shade400 : colors.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (trailing.isNotEmpty)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
