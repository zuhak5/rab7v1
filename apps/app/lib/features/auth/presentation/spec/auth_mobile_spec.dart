import 'package:flutter/material.dart';

class AuthMobileSpec {
  const AuthMobileSpec._();

  static const Size designSize = Size(390, 844);
  static const double maxContentWidth = 430;
  static const double surfaceRadius = 28;
  static const double fieldRadius = 16;
  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double iconSize = 22;
  static const double sectionTitleGap = 8;
  static const double cardPadding = 24;
  static const double pageHorizontalPadding = 20;
  static const double sectionGap = 16;

  static const Duration pageTransitionDuration = Duration(milliseconds: 220);
  static const Duration shortDuration = Duration(milliseconds: 140);
  static const Duration mediumDuration = Duration(milliseconds: 220);
  static const Curve standardCurve = Cubic(0.2, 0.9, 0.2, 1);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFEAF1FB), Color(0xFFF7F9FC)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFEDF4FF), Color(0xFFF7F9FC)],
  );
}
