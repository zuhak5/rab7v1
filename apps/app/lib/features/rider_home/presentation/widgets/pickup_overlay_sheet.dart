import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_state.dart';

class PickupOverlaySheet extends StatelessWidget {
  const PickupOverlaySheet({
    required this.isOpen,
    required this.mode,
    required this.searchController,
    required this.suggestions,
    required this.onDismiss,
    required this.onModeChanged,
    required this.onUseCurrent,
    required this.onSuggestionTap,
    required this.onConfirmMap,
    super.key,
  });

  final bool isOpen;
  final PickupSheetMode mode;
  final TextEditingController searchController;
  final List<String> suggestions;
  final VoidCallback onDismiss;
  final ValueChanged<PickupSheetMode> onModeChanged;
  final VoidCallback onUseCurrent;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onConfirmMap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

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
                child: Container(color: Colors.black.withValues(alpha: 0.22)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                duration: HomeMobileSpec.overlayDuration,
                offset: isOpen ? Offset.zero : const Offset(0, 0.06),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 12 + safeBottom,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: colors.outline.withValues(alpha: 0.75),
                      ),
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 14,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.onSurface.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'موقع الالتقاط',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'اختر موقع الالتقاط قبل متابعة الرحلة',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: onDismiss,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _Segmented(mode: mode, onModeChanged: onModeChanged),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: HomeMobileSpec.shortDuration,
                        child: switch (mode) {
                          PickupSheetMode.current =>
                            _CurrentMode(onUseCurrent: onUseCurrent),
                          PickupSheetMode.search => _SearchMode(
                            controller: searchController,
                            suggestions: suggestions,
                            onSuggestionTap: onSuggestionTap,
                          ),
                          PickupSheetMode.map =>
                            _MapMode(onConfirmMap: onConfirmMap),
                        },
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

class _Segmented extends StatelessWidget {
  const _Segmented({required this.mode, required this.onModeChanged});

  final PickupSheetMode mode;
  final ValueChanged<PickupSheetMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            duration: HomeMobileSpec.panelDuration,
            curve: HomeMobileSpec.standardEase,
            alignment: switch (mode) {
              PickupSheetMode.current => Alignment.centerRight,
              PickupSheetMode.search => Alignment.center,
              PickupSheetMode.map => Alignment.centerLeft,
            },
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Container(
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
          ),
          Row(
            children: <Widget>[
              _SegmentButton(
                title: 'حالي',
                onTap: () => onModeChanged(PickupSheetMode.current),
              ),
              _SegmentButton(
                title: 'بحث',
                onTap: () => onModeChanged(PickupSheetMode.search),
              ),
              _SegmentButton(
                title: 'الخريطة',
                onTap: () => onModeChanged(PickupSheetMode.map),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CurrentMode extends StatelessWidget {
  const _CurrentMode({required this.onUseCurrent});

  final VoidCallback onUseCurrent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey<String>('current'),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.6)),
          ),
          child: const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                child: Icon(Icons.my_location_rounded, size: 18),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'استخدم موقعي الحالي',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text('GPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onUseCurrent,
            child: const Text('تعيين كموقع الالتقاط'),
          ),
        ),
      ],
    );
  }
}

class _SearchMode extends StatelessWidget {
  const _SearchMode({
    required this.controller,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey<String>('search'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'ابحث عن موقع الالتقاط',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 180),
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final value = suggestions[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined, size: 18),
                title: Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                onTap: () => onSuggestionTap(value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MapMode extends StatelessWidget {
  const _MapMode({required this.onConfirmMap});

  final VoidCallback onConfirmMap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey<String>('map'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.6)),
          ),
          child: const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                child: Icon(Icons.place_rounded, size: 18),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'تحديد على الخريطة',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'ضع نقطة الالتقاط على الخريطة ثم أكد.',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: onConfirmMap,
          child: const Text('تأكيد نقطة الالتقاط'),
        ),
      ],
    );
  }
}
