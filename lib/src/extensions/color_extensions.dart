import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Returns a contrasting color to the given color.
  /// You can tweak the contrast ratio, which defaults to 192.
  ///
  /// [maxContrast] should be more than 128.
  Color getContrastColor({int maxContrast = 192}) {
    const int minContrast = 128;

    final int y = (0.299 * ((r * 255).round() & 0xff) + 0.587 * ((g * 255).round() & 0xff) + 0.114 * ((b * 255).round() & 0xff)).round(); // luma
    int oy = 255 - y; // opposite
    int dy = oy - y; // delta

    if (dy.abs() > maxContrast) {
      dy = dy.sign * maxContrast;
      oy = y + dy;
    } else if (dy.abs() < minContrast) {
      dy = dy.sign * minContrast;
      oy = y + dy;
    }

    // Ensure result stays within 0–255 range
    oy = oy.clamp(0, 255);

    return Color.fromARGB(255, oy, oy, oy);
  }
}
