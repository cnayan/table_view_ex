import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/table_view_ex.dart';

void main() {
  group('TableViewExColumnConfig', () {
    test('creates instance with required parameters', () {
      final config = TableViewExColumnConfig(
        key: 'test',
        widgetBuilder: () => const Text('Test'),
      );

      expect(config.key, equals('test'));
      expect(config.widgetBuilder, isNotNull);
      expect(config.minWidth, equals(10));
      expect(config.contentAlignment, equals(Alignment.centerLeft));
      expect(config.isAscending, isNull);
      expect(config.comparer, isNull);
      expect(config.cellCursor, isNull);
      expect(config.horizontalSpan, isNull);
      expect(config.headerStyle, isNull);
    });

    test('creates instance with all parameters', () {
      final headerStyle = TableViewExHeaderStyle(
        backgroundColor: Colors.blue,
      );

      final config = TableViewExColumnConfig(
        key: 'test',
        widgetBuilder: () => const Text('Test'),
        headerStyle: headerStyle,
        horizontalSpan: FixedSpanExtent(100),
        minWidth: 150,
        contentAlignment: Alignment.center,
        cellCursor: SystemMouseCursors.click,
        comparer: (a, b) => (a as String).compareTo(b as String),
      );

      expect(config.key, equals('test'));
      expect(config.widgetBuilder?.call(), isA<Text>());
      expect(config.minWidth, equals(150));
      expect(config.contentAlignment, equals(Alignment.center));
      expect(config.cellCursor, equals(SystemMouseCursors.click));
      expect(config.horizontalSpan, isA<FixedSpanExtent>());
      expect(config.headerStyle, equals(headerStyle));
      expect(config.comparer, isNotNull);
    });

    test('comparer function works correctly', () {
      final config = TableViewExColumnConfig(
        key: 'test',
        widgetBuilder: () => const Text('Test'),
        comparer: (a, b) => (a as String).compareTo(b as String),
      );

      expect(config.comparer!('a', 'b'), lessThan(0));
      expect(config.comparer!('b', 'a'), greaterThan(0));
      expect(config.comparer!('a', 'a'), equals(0));
    });

    test('isAscending can be modified', () {
      final config = TableViewExColumnConfig(
        key: 'test',
        widgetBuilder: () => const Text('Test'),
        comparer: (a, b) => (a as String).compareTo(b as String),
      );

      expect(config.isAscending, isNull);

      config.isAscending = true;
      expect(config.isAscending, isTrue);

      config.isAscending = false;
      expect(config.isAscending, isFalse);
    });

    test('widgetBuilder returns correct widget', () {
      final config = TableViewExColumnConfig(
        key: 'test',
        widgetBuilder: () => const Text('Test Header'),
      );

      final widget = config.widgetBuilder!();
      expect(widget, isA<Text>());
      expect((widget as Text).data, equals('Test Header'));
    });
  });
}
