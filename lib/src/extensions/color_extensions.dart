import 'dart:math';

import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Returns a color that is a darker version of the current color.
  /// The [amount] parameter (as percentage) controls how much darker the color will be.
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final HSLColor hsl = HSLColor.fromColor(this);
    final HSLColor darkerHsl =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkerHsl.toColor();
  }

  /// Returns a color that is a lighter version of the current color.
  /// The [amount] parameter (as percentage) controls how much lighter the color will be.
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final HSLColor hsl = HSLColor.fromColor(this);
    final HSLColor darkerHsl =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return darkerHsl.toColor();
  }

  String toRGBString() =>
      'Color(red: ${(r * 255).round() & 0xff}, green: ${(g * 255).round() & 0xff}, blue: ${(b * 255).round() & 0xff})';

  /// Calculates the relative luminance of a color according to WCAG guidelines
  double _getRelativeLuminance() {
    // Apply gamma correction
    final rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    // Calculate relative luminance using ITU-R BT.709 coefficients
    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  /// Calculates contrast ratio between two colors
  double calculateContrastRatio(Color color2) {
    final luminance1 = _getRelativeLuminance();
    final luminance2 = color2._getRelativeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns a contrasting color to the given color.
  /// You can tweak the contrast ratio, which defaults to 192.
  ///
  /// [maxContrast] should be more than 128.
  Color getContrastColor({int maxContrast = 192}) {
    const int minContrast = 128;

    final int y = (0.299 * ((r * 255).round() & 0xff) +
            0.587 * ((g * 255).round() & 0xff) +
            0.114 * ((b * 255).round() & 0xff))
        .round(); // luma
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
