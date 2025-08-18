import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/src/table_view_ex_header_style.dart';

void main() {
  group('TableViewExHeaderStyle', () {
    test('should create with default values', () {
      final style = TableViewExHeaderStyle();

      expect(style.backgroundColor, isNull);
      expect(style.height, isNull);
      expect(style.textAlignment, equals(Alignment.centerLeft));
    });

    test('should create with all custom values', () {
      final style = TableViewExHeaderStyle(
        backgroundColor: Colors.blue,
        height: 50.0,
        textAlignment: Alignment.center,
      );

      expect(style.backgroundColor, equals(Colors.blue));
      expect(style.height, equals(50.0));
      expect(style.textAlignment, equals(Alignment.center));
    });

    test('should create with only height', () {
      final style = TableViewExHeaderStyle(height: 60.0);

      expect(style.height, equals(60.0));
      expect(style.backgroundColor, isNull);
      expect(style.textAlignment, equals(Alignment.centerLeft));
    });

    test('should create with only backgroundColor', () {
      final style = TableViewExHeaderStyle(backgroundColor: Colors.red);

      expect(style.backgroundColor, equals(Colors.red));
      expect(style.height, isNull);
      expect(style.textAlignment, equals(Alignment.centerLeft));
    });

    test('should create with only textAlignment', () {
      final style =
          TableViewExHeaderStyle(textAlignment: Alignment.centerRight);

      expect(style.textAlignment, equals(Alignment.centerRight));
      expect(style.backgroundColor, isNull);
      expect(style.height, isNull);
    });

    test('should create with height and backgroundColor', () {
      final style = TableViewExHeaderStyle(
        height: 40.0,
        backgroundColor: Colors.green,
      );

      expect(style.height, equals(40.0));
      expect(style.backgroundColor, equals(Colors.green));
      expect(style.textAlignment, equals(Alignment.centerLeft));
    });

    test('should create with backgroundColor and textAlignment', () {
      final style = TableViewExHeaderStyle(
        backgroundColor: Colors.yellow,
        textAlignment: Alignment.topCenter,
      );

      expect(style.backgroundColor, equals(Colors.yellow));
      expect(style.textAlignment, equals(Alignment.topCenter));
      expect(style.height, isNull);
    });
  });
}
