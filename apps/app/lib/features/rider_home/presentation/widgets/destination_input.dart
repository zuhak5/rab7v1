import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../spec/home_mobile_spec.dart';

class DestinationInput extends StatefulWidget {
  const DestinationInput({
    required this.controller,
    required this.suggestions,
    required this.isSuggestOpen,
    required this.activeSuggestionIndex,
    required this.onChanged,
    required this.onClear,
    required this.onSuggestionTap,
    required this.onMoveSelection,
    required this.onOpenSuggestions,
    required this.onCloseSuggestions,
    super.key,
  });

  final TextEditingController controller;
  final List<String> suggestions;
  final bool isSuggestOpen;
  final int activeSuggestionIndex;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<int> onMoveSelection;
  final VoidCallback onOpenSuggestions;
  final VoidCallback onCloseSuggestions;

  @override
  State<DestinationInput> createState() => _DestinationInputState();
}

class _DestinationInputState extends State<DestinationInput> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onCloseSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double? _fieldWidth() {
    final renderBox = _fieldKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox) {
      return null;
    }
    return renderBox.size.width;
  }

  void _syncOverlay({required bool open}) {
    if (!open) {
      _removeOverlay();
      return;
    }

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    if (overlay == null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final colors = Theme.of(overlayContext).colorScheme;
        final width = _fieldWidth();

        return Positioned.fill(
          child: Stack(
            children: <Widget>[
              // Tap-away to close. Keeps the home sheet layout stable (no jumps).
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onCloseSuggestions,
                child: const SizedBox.expand(),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 8),
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // If we can't measure the field, fall back to a safe width.
                      maxWidth: width ?? HomeMobileSpec.designWidth,
                      minWidth: width ?? 0,
                      maxHeight: 260,
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.85),
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.14),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                10,
                                4,
                                10,
                                6,
                              ),
                              child: Text(
                                'اقتراحات سريعة',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.88,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: widget.suggestions.length,
                                itemBuilder: (context, index) {
                                  final selected =
                                      index == widget.activeSuggestionIndex;
                                  final item = widget.suggestions[index];
                                  return InkWell(
                                    onTap: () => widget.onSuggestionTap(item),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? colors.primary.withValues(
                                                alpha: 0.06,
                                              )
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colors
                                                  .surfaceContainerHighest,
                                              border: Border.all(
                                                color: colors.outline
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.place_rounded,
                                              size: 18,
                                              color: colors.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: colors.onSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final open = widget.isSuggestOpen && widget.suggestions.isNotEmpty;

    // Keep the home sheet height stable: suggestions render in an overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncOverlay(open: open);
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        key: _fieldKey,
        height: HomeMobileSpec.destinationFieldHeight,
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) {
              return KeyEventResult.ignored;
            }
            if (!open) {
              return KeyEventResult.ignored;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              widget.onMoveSelection(1);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              widget.onMoveSelection(-1);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              final idx = widget.activeSuggestionIndex.clamp(
                0,
                widget.suggestions.length - 1,
              );
              widget.onSuggestionTap(widget.suggestions[idx]);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onCloseSuggestions();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            key: const ValueKey<String>('home_destination_input'),
            controller: widget.controller,
            onTap: widget.onOpenSuggestions,
            onChanged: (value) {
              widget.onChanged(value);
              if (value.trim().isNotEmpty) {
                widget.onOpenSuggestions();
              } else {
                widget.onCloseSuggestions();
              }
            },
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'أدخل وجهتك',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant.withValues(alpha: 0.78),
              ),
              isDense: true,
              filled: true,
              fillColor: colors.surface,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                8,
                18,
                8,
                18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HomeMobileSpec.destinationFieldRadius,
                ),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.85),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HomeMobileSpec.destinationFieldRadius,
                ),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.85),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HomeMobileSpec.destinationFieldRadius,
                ),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.9),
                  width: 1,
                ),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 22,
                color: colors.primary,
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              // Reserve suffix space to avoid text "jump" when the clear button
              // appears/disappears.
              suffixIcon: SizedBox(
                width: 44,
                child: hasText
                    ? IconButton(
                        onPressed: widget.onClear,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    : const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.transparent,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
