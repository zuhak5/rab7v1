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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final open = widget.isSuggestOpen && widget.suggestions.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: HomeMobileSpec.destinationFieldHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                HomeMobileSpec.destinationFieldRadius,
              ),
              boxShadow: HomeMobileSpec.elevation1,
            ),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'أدخل وجهتك',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                  filled: true,
                  fillColor: colors.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(
                    48,
                    18,
                    48,
                    18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      HomeMobileSpec.destinationFieldRadius,
                    ),
                    borderSide: BorderSide(
                      color: colors.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      HomeMobileSpec.destinationFieldRadius,
                    ),
                    borderSide: BorderSide(
                      color: colors.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      HomeMobileSpec.destinationFieldRadius,
                    ),
                    borderSide: BorderSide(
                      color: colors.primary.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 28,
                    color: colors.primary,
                  ),
                  suffixIcon: hasText
                      ? IconButton(
                          onPressed: widget.onClear,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: HomeMobileSpec.shortDuration,
          child: open
              ? Container(
                  key: const ValueKey<String>('destination_suggestions_panel'),
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.7),
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.18),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
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
                      ListView.builder(
                        itemCount: widget.suggestions.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final selected =
                              index == widget.activeSuggestionIndex;
                          final item = widget.suggestions[index];
                          return InkWell(
                            onTap: () => widget.onSuggestionTap(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.onSurface.withValues(alpha: 0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.surfaceContainerHighest,
                                      border: Border.all(
                                        color: colors.outline.withValues(
                                          alpha: 0.6,
                                        ),
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
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
