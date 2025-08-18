// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:table_view_ex/src/table_view_ex_column_config.dart';
import 'package:table_view_ex/src/table_view_ex_width_calculator.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

/// Default implementation of [TableViewExWidthCalculator] which computes widths based on the [Span] of the columns provided.
/// Singleton class.
class DefaultTableViewExWidthCalculator extends TableViewExWidthCalculator {
  static final DefaultTableViewExWidthCalculator _instance =
      DefaultTableViewExWidthCalculator._internal();
  factory DefaultTableViewExWidthCalculator() => _instance;
  DefaultTableViewExWidthCalculator._internal();

  /// Calculate the actual pixel widths based on the current constraints
  @override
  List<double> calculateColumnWidths(
      double viewportWidth, List<TableViewExColumnConfig> columnDefinitions) {
    final columnSpans = columnDefinitions
        .map((c) => TableSpan(
              extent: c.horizontalSpan ?? FixedTableSpanExtent(c.minWidth),
            ))
        .toList();

    final List<double> calculatedColumnWidths =
        Iterable.generate(columnSpans.length, (_) => 0.0).toList();

    double totalFixedAndFractionalWidth = 0;
    int remainingCount = 0;

    for (int i = 0; i < columnSpans.length; i++) {
      final SpanExtent extent = columnSpans[i].extent;

      if (extent is FixedTableSpanExtent) {
        calculatedColumnWidths[i] = extent.pixels;
        totalFixedAndFractionalWidth += extent.pixels;
      } else if (extent is FractionalTableSpanExtent) {
        final value = viewportWidth * extent.fraction;
        calculatedColumnWidths[i] = value;
        totalFixedAndFractionalWidth += value;
      } else if (extent is RemainingTableSpanExtent) {
        remainingCount++;
      }
    }

    if (remainingCount > 0) {
      final remainingWidth =
          (viewportWidth - totalFixedAndFractionalWidth) / remainingCount;

      for (int i = 0; i < columnSpans.length; i++) {
        if (columnSpans[i].extent is RemainingTableSpanExtent) {
          calculatedColumnWidths[i] = remainingWidth;
        }
      }
    }

    return calculatedColumnWidths;
  }
}
