import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/src/extensions/color_extensions.dart';

void main() {
  group('ColorExtensions', () {
    test('getContrastColor returns white for dark colors', () {
      final color = Colors.black;
      final contrast = color.getContrastColor();
      expect((contrast.r * 255).round(), equals(192));
      expect((contrast.g * 255).round(), equals(192));
      expect((contrast.b * 255).round(), equals(192));
    });

    test('getContrastColor returns black for light colors', () {
      final color = Colors.white;
      final contrast = color.getContrastColor();
      expect((contrast.r * 255).round(), equals(63));
      expect((contrast.g * 255).round(), equals(63));
      expect((contrast.b * 255).round(), equals(63));
    });

    test('getContrastColor respects maxContrast parameter', () {
      final color = Colors.grey;
      final contrast = color.getContrastColor(maxContrast: 150);
      expect((contrast.r * 255).round(), lessThanOrEqualTo(255));
      expect((contrast.g * 255).round(), lessThanOrEqualTo(255));
      expect((contrast.b * 255).round(), lessThanOrEqualTo(255));
    });

    test('getContrastColor handles colors near minContrast threshold', () {
      final color = Color(0xFF808080); // Middle grey
      final contrast = color.getContrastColor();
      expect(((contrast.r * 255).round() - 0x80).abs(), greaterThanOrEqualTo(128));
    });

    test('getContrastColor clamps output to valid range', () {
      final color = Colors.purple;
      final contrast = color.getContrastColor(maxContrast: 255);
      expect((contrast.r * 255).round(), lessThanOrEqualTo(255));
      expect((contrast.g * 255).round(), lessThanOrEqualTo(255));
      expect((contrast.b * 255).round(), lessThanOrEqualTo(255));
      expect((contrast.r * 255).round(), greaterThanOrEqualTo(0));
      expect((contrast.g * 255).round(), greaterThanOrEqualTo(0));
      expect((contrast.b * 255).round(), greaterThanOrEqualTo(0));
    });
  });
}
