// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/src/default_table_view_ex_width_calculator.dart';
import 'package:table_view_ex/src/table_view_ex_column_config.dart';
import 'package:table_view_ex/src/table_view_ex_header_style.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class TestTableViewExColumnConfig implements TableViewExColumnConfig {
  @override
  final String key;

  @override
  final double minWidth;

  @override
  final Alignment? contentAlignment;

  @override
  final Widget Function()? widgetBuilder;

  @override
  final int Function(dynamic, dynamic)? comparer;

  @override
  bool? isAscending;

  @override
  final TableViewExHeaderStyle? headerStyle;

  @override
  final MouseCursor? cellCursor;

  @override
  final SpanExtent? horizontalSpan;

  TestTableViewExColumnConfig({
    required this.key,
    this.minWidth = 50.0,
    this.contentAlignment,
    this.widgetBuilder,
    this.comparer,
    this.isAscending,
    this.headerStyle,
    this.cellCursor,
    this.horizontalSpan,
  });
}

void main() {
  group('DefaultTableViewExWidthCalculator', () {
    late DefaultTableViewExWidthCalculator calculator;

    setUp(() {
      calculator = DefaultTableViewExWidthCalculator();
    });

    test('distributes width equally among columns with no fixed width', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1'),
        TestTableViewExColumnConfig(key: 'col2'),
        TestTableViewExColumnConfig(key: 'col3'),
      ];

      final expectedWidth = columns.map((x) => x.minWidth).toList();

      final widths = calculator.calculateColumnWidths(300, columns);
      expect(widths, expectedWidth);
    });

    test('respects fixed width columns', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1', horizontalSpan: FixedSpanExtent(150)),
        TestTableViewExColumnConfig(key: 'col2', horizontalSpan: FixedSpanExtent(75)),
        TestTableViewExColumnConfig(key: 'col3', horizontalSpan: FixedSpanExtent(75)),
      ];
      final widths = calculator.calculateColumnWidths(300, columns);
      expect(widths, [150, 75, 75]);
    });

    test('handles case where fixed widths exceed available width', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1', horizontalSpan: FixedSpanExtent(200)),
        TestTableViewExColumnConfig(key: 'col2', horizontalSpan: FixedSpanExtent(200)),
      ];
      final widths = calculator.calculateColumnWidths(300, columns);
      expect(widths, [200, 200]);
    });

    test('distributes remaining width to non-fixed columns', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1', horizontalSpan: FractionalSpanExtent(.3)),
        TestTableViewExColumnConfig(key: 'col2', horizontalSpan: FractionalSpanExtent(.5)),
        TestTableViewExColumnConfig(key: 'col3', horizontalSpan: RemainingSpanExtent()),
        TestTableViewExColumnConfig(key: 'col3', horizontalSpan: RemainingSpanExtent()),
      ];
      final widths = calculator.calculateColumnWidths(300, columns);
      expect(widths, [90, 150, 30, 30]);
    });

    test('distributes fractional %ages width columns', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1', horizontalSpan: FractionalSpanExtent(.3)),
        TestTableViewExColumnConfig(key: 'col2', horizontalSpan: FractionalSpanExtent(.5)),
        TestTableViewExColumnConfig(key: 'col3', horizontalSpan: FractionalSpanExtent(.2)),
      ];
      final widths = calculator.calculateColumnWidths(300, columns);
      expect(widths, [90, 150, 60]);
    });

    test('ensures minimum width is respected', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1', minWidth: 120),
        TestTableViewExColumnConfig(key: 'col2', minWidth: 120),
      ];
      final widths = calculator.calculateColumnWidths(200, columns);
      expect(widths, [120, 120]);
    });

    test('handles empty column list', () {
      final widths = calculator.calculateColumnWidths(300, []);
      expect(widths, []);
    });

    test('handles zero available width', () {
      final columns = [
        TestTableViewExColumnConfig(key: 'col1'),
        TestTableViewExColumnConfig(key: 'col2'),
      ];
      final widths = calculator.calculateColumnWidths(0, columns);
      expect(widths, [50, 50]); // Should fall back to minWidth
    });
  });
}
