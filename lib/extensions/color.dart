import 'dart:ui';

import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color get toColor {
    final hex = replaceAll('#', '').toUpperCase();

    if (hex.length == 6) {
      // RGB (no alpha)
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      // ARGB
      return Color(int.parse(hex, radix: 16));
    } else {
      throw ArgumentError("Invalid hex color code: $this");
    }
  }
}

Color parseHexColor(String? hexColor, {Color fallback = Colors.black}) {
  if (hexColor == null || hexColor.isEmpty) return fallback;

  try {
    String hex = hexColor.replaceAll('#', '');

    if (hex.length == 6) {
      // Add full opacity if only RGB is provided
      hex = 'FF$hex';
    } else if (hex.length == 8) {
      // Already ARGB (alpha + RGB)
    } else {
      return fallback;
    }

    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return fallback;
  }
}
