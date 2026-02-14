import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class PlaceEditOverlay extends StatefulWidget {
  const PlaceEditOverlay({
    required this.isOpen,
    required this.placeLabel,
    required this.initialValue,
    required this.topInset,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final bool isOpen;
  final String placeLabel;
  final String initialValue;
  final double topInset;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;

  @override
  State<PlaceEditOverlay> createState() => _PlaceEditOverlayState();
}

class _PlaceEditOverlayState extends State<PlaceEditOverlay> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant PlaceEditOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _controller.text = widget.initialValue;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IgnorePointer(
      ignoring: !widget.isOpen,
      child: AnimatedOpacity(
        opacity: widget.isOpen ? 1 : 0,
        duration: HomeMobileSpec.overlayDuration,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onCancel,
                child: Container(color: Colors.black.withValues(alpha: 0.16)),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: widget.topInset + 8,
              child: AnimatedSlide(
                duration: HomeMobileSpec.overlayDuration,
                offset: widget.isOpen ? Offset.zero : const Offset(0, 0.04),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.8),
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colors.surfaceContainerHighest,
                                border: Border.all(
                                  color: colors.outline.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Icon(
                                widget.placeLabel == 'home'
                                    ? Icons.home_rounded
                                    : Icons.work_rounded,
                                size: 20,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.placeLabel == 'home'
                                    ? 'تعيين المنزل'
                                    : 'تعيين العمل',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onCancel,
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'مثال: شارع الأميرات، المنصور',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  final value = _controller.text.trim();
                                  if (value.isEmpty) {
                                    return;
                                  }
                                  widget.onSave(value);
                                },
                                child: const Text('حفظ'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onCancel,
                                child: const Text('إلغاء'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
