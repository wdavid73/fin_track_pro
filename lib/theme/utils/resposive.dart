import 'dart:math' as math;

import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  double get diagonal => math.sqrt(math.pow(width, 2) + math.pow(height, 2));
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
  Orientation get orientation => MediaQuery.of(this).orientation;
  TextScaler get textScaler => MediaQuery.of(this).textScaler;

  double wp(double percent) => width * (percent / 100);
  double hp(double percent) => height * (percent / 100);
  double dp(double percent) => diagonal * (percent / 100);
}
