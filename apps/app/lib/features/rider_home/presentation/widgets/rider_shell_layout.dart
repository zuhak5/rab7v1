import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class RiderShellLayout extends StatelessWidget {
  const RiderShellLayout({
    required this.metrics,
    required this.map,
    required this.header,
    required this.mainSheet,
    required this.bottomNav,
    this.marker,
    this.overlays = const <Widget>[],
    super.key,
  });

  final HomeLayoutMetrics metrics;
  final Widget map;
  final Widget header;
  final Widget mainSheet;
  final Widget bottomNav;
  final Widget? marker;
  final List<Widget> overlays;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: map),
        Positioned(
          top: metrics.headerTop,
          left: 0,
          right: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: HomeMobileSpec.maxContentWidth,
              ),
              child: header,
            ),
          ),
        ),
        if (marker != null)
          Positioned(
            left: 0,
            right: 0,
            top: metrics.markerTop,
            child: marker!,
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: metrics.mainSheetBottom,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: HomeMobileSpec.maxContentWidth,
              ),
              child: mainSheet,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: HomeMobileSpec.maxContentWidth,
              ),
              child: bottomNav,
            ),
          ),
        ),
        ...overlays,
      ],
    );
  }
}
