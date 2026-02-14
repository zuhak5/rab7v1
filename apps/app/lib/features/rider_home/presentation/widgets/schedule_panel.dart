import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_state.dart';

class SchedulePanel extends StatefulWidget {
  const SchedulePanel({
    required this.isOpen,
    required this.scheduleType,
    required this.scheduledAt,
    required this.isCustomOpen,
    required this.validationMessage,
    required this.onToggle,
    required this.onSetNow,
    required this.onSetDelay,
    required this.onSetCustom,
    required this.onCustomToggle,
    required this.onSetValidationMessage,
    super.key,
  });

  final bool isOpen;
  final ScheduleType scheduleType;
  final DateTime? scheduledAt;
  final bool isCustomOpen;
  final String? validationMessage;
  final VoidCallback onToggle;
  final VoidCallback onSetNow;
  final ValueChanged<int> onSetDelay;
  final ValueChanged<DateTime> onSetCustom;
  final ValueChanged<bool> onCustomToggle;
  final ValueChanged<String?> onSetValidationMessage;

  @override
  State<SchedulePanel> createState() => _SchedulePanelState();
}

class _SchedulePanelState extends State<SchedulePanel>
    with SingleTickerProviderStateMixin {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  late final AnimationController _shakeController;
  int? _selectedDelayMinutes;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SchedulePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scheduleType != ScheduleType.later) {
      _selectedDelayMinutes = null;
      return;
    }
    final scheduledAt = widget.scheduledAt;
    if (scheduledAt == null) {
      return;
    }
    final minutes = scheduledAt.difference(DateTime.now()).inMinutes;
    const delays = <int>[15, 30, 60, 180];
    if (delays.contains(minutes)) {
      _selectedDelayMinutes = minutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLater = widget.scheduleType == ScheduleType.later;

    return SizedBox(
      width: HomeMobileSpec.scheduleButtonMinWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SizedBox(
            height: HomeMobileSpec.scheduleButtonHeight,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.24),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: colors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              onPressed: widget.onToggle,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.schedule_rounded, size: 18, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        _headerLabel(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subLabel(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isOpen)
            Positioned(
              top: HomeMobileSpec.scheduleButtonHeight + 8,
              left: 0,
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final t = _shakeController.value;
                  final dx = (1 - t) * (t < 0.5 ? 4 : -4);
                  return Transform.translate(offset: Offset(dx, 0), child: child);
                },
                child: _ScheduleOverlay(
                  isLater: isLater,
                  isCustomOpen: widget.isCustomOpen,
                  validationMessage: widget.validationMessage,
                  dateController: _dateController,
                  timeController: _timeController,
                  onSetNow: () {
                    setState(() {
                      _selectedDelayMinutes = null;
                    });
                    widget.onSetValidationMessage(null);
                    widget.onSetNow();
                  },
                  onSetLater: () {
                    setState(() {
                      _selectedDelayMinutes = 15;
                    });
                    widget.onSetValidationMessage(null);
                    widget.onSetDelay(15);
                  },
                  onSetDelay: (minutes) {
                    setState(() {
                      _selectedDelayMinutes = minutes;
                    });
                    widget.onSetValidationMessage(null);
                    widget.onSetDelay(minutes);
                  },
                  onCustomToggle: widget.onCustomToggle,
                  onApplyCustom: () {
                    final dateText = _dateController.text.trim();
                    final timeText = _timeController.text.trim();
                    final parsed = DateTime.tryParse('${dateText}T$timeText');
                    if (parsed == null ||
                        parsed.isBefore(
                          DateTime.now().add(const Duration(minutes: 1)),
                        )) {
                      widget.onSetValidationMessage('أدخل تاريخًا ووقتًا صالحين.');
                      _shakeController
                        ..reset()
                        ..forward();
                      return;
                    }
                    widget.onSetValidationMessage(null);
                    setState(() {
                      _selectedDelayMinutes = null;
                    });
                    widget.onSetCustom(parsed);
                  },
                  selectedDelayMinutes: _selectedDelayMinutes,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _headerLabel() {
    if (widget.scheduleType == ScheduleType.now) {
      return 'الآن';
    }
    final scheduledAt = widget.scheduledAt;
    if (scheduledAt == null) {
      return 'لاحقًا';
    }
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _subLabel() {
    if (widget.scheduleType == ScheduleType.now) {
      return 'تغيير الوقت';
    }
    final scheduledAt = widget.scheduledAt;
    if (scheduledAt == null) {
      return 'اختيار الوقت';
    }
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    return 'اليوم $hour:$minute';
  }
}

class _ScheduleOverlay extends StatelessWidget {
  const _ScheduleOverlay({
    required this.isLater,
    required this.isCustomOpen,
    required this.validationMessage,
    required this.dateController,
    required this.timeController,
    required this.onSetNow,
    required this.onSetLater,
    required this.onSetDelay,
    required this.onCustomToggle,
    required this.onApplyCustom,
    required this.selectedDelayMinutes,
  });

  final bool isLater;
  final bool isCustomOpen;
  final String? validationMessage;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final VoidCallback onSetNow;
  final VoidCallback onSetLater;
  final ValueChanged<int> onSetDelay;
  final ValueChanged<bool> onCustomToggle;
  final VoidCallback onApplyCustom;
  final int? selectedDelayMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 290,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SegmentHeader(
            isLater: isLater,
            onNowTap: onSetNow,
            onLaterTap: onSetLater,
          ),
          const SizedBox(height: 10),
          if (!isLater)
            Text(
              'سيتم طلب الرحلة فورًا.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            )
          else ...<Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _DelayChip(
                  label: 'بعد ١٥ د',
                  minutes: 15,
                  selected: selectedDelayMinutes == 15,
                  onTap: onSetDelay,
                ),
                _DelayChip(
                  label: 'بعد ٣٠ د',
                  minutes: 30,
                  selected: selectedDelayMinutes == 30,
                  onTap: onSetDelay,
                ),
                _DelayChip(
                  label: 'بعد ساعة',
                  minutes: 60,
                  selected: selectedDelayMinutes == 60,
                  onTap: onSetDelay,
                ),
                _DelayChip(
                  label: 'بعد ٣ ساعات',
                  minutes: 180,
                  selected: selectedDelayMinutes == 180,
                  onTap: onSetDelay,
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => onCustomToggle(!isCustomOpen),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    const Text(
                      'وقت مخصص',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Icon(
                      isCustomOpen
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (isCustomOpen) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        hintText: 'YYYY-MM-DD',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        hintText: 'HH:MM',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onApplyCustom,
                  child: const Text('تعيين'),
                ),
              ),
            ],
            if (validationMessage != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                validationMessage!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.error,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SegmentHeader extends StatelessWidget {
  const _SegmentHeader({
    required this.isLater,
    required this.onNowTap,
    required this.onLaterTap,
  });

  final bool isLater;
  final VoidCallback onNowTap;
  final VoidCallback onLaterTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            duration: HomeMobileSpec.panelDuration,
            curve: HomeMobileSpec.standardEase,
            alignment: isLater ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 136,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: onNowTap,
                  child: const Text(
                    'الآن',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: onLaterTap,
                  child: const Text(
                    'لاحقًا',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DelayChip extends StatelessWidget {
  const _DelayChip({
    required this.label,
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final bool selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onTap(minutes),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? colors.primary.withValues(alpha: 0.1)
              : colors.surface,
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.4)
                : colors.outline.withValues(alpha: 0.8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? colors.primary : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
