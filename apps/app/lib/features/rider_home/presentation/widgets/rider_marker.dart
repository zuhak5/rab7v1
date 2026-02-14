import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class RiderMarker extends StatefulWidget {
  const RiderMarker({required this.avatarUrl, super.key});

  final String? avatarUrl;

  @override
  State<RiderMarker> createState() => _RiderMarkerState();
}

class _RiderMarkerState extends State<RiderMarker>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _orbitController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    final isTestBinding = bindingType.contains('TestWidgetsFlutterBinding');
    final isTesting =
        const bool.fromEnvironment('FLUTTER_TEST') || isTestBinding;

    // Pulse Animation: 2.1s cubic-bezier(0.4, 0.0, 0.2, 1) infinite
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    // Float Animation: 2.6s cubic-bezier(0.4, 0.0, 0.2, 1) infinite
    // Keyframes: 0%, 100% -> 0px; 50% -> -4px
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _floatAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -4,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -4,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_floatController);

    // Orbit Animation: 3.4s linear infinite
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    if (isTesting) {
      _pulseController.value = 0.5;
      _floatController.value = 0.5;
      _orbitController.value = 0.5;
    } else {
      _pulseController.repeat();
      _floatController.repeat();
      _orbitController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final trimmedAvatar = widget.avatarUrl?.trim();
    final hasAvatar = trimmedAvatar != null && trimmedAvatar.isNotEmpty;

    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: HomeMobileSpec.markerSize,
          height: HomeMobileSpec.markerSize,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseController,
              _floatController,
              _orbitController,
            ]),
            builder: (context, child) {
              // Pulse values
              // 0% -> scale 0.72, opacity 0.28
              // 65% -> scale 1.35, opacity 0
              // 100% -> scale 1.35, opacity 0
              final tPulse = _pulseController.value;
              double pulseScale;
              double pulseOpacity;
              if (tPulse <= 0.65) {
                final t = tPulse / 0.65;
                final curvedT = const Cubic(0.4, 0.0, 0.2, 1).transform(t);
                pulseScale = 0.72 + (1.35 - 0.72) * curvedT;
                pulseOpacity = 0.28 * (1 - curvedT);
              } else {
                pulseScale = 1.35;
                pulseOpacity = 0.0;
              }

              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    // Pulse Ring
                    Transform.scale(
                      scale: pulseScale,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: pulseOpacity),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // Orbiting Dot
                    // Dot should be at top center relative to the marker, then rotated
                    RotationTransition(
                      turns: _orbitController,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: const Offset(0, 2), // Top offset
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xB30056D2), // rgba(0, 86, 210, 0.7)
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0x2E0056D2,
                                  ), // rgba(0, 86, 210, 0.18)
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Main Marker Body
                    Container(
                      width: HomeMobileSpec.markerInnerSize,
                      height: HomeMobileSpec.markerInnerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.75),
                          width: 2,
                        ),
                        color: colors.surfaceContainerHighest,
                        image: hasAvatar
                            ? DecorationImage(
                                image: NetworkImage(trimmedAvatar),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: HomeMobileSpec.elevation2,
                      ),
                      child: hasAvatar
                          ? null
                          : const Icon(Icons.person_rounded, size: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
