// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'table_view_ex_header_style.dart';

/// Configuration for the columns in the table [TableViewEx].
class TableViewExColumnConfig {
  /// The key for the column, used to extract cell value in a row.
  /// Example: if the key is set 'name', then the cell value will be extracted from the row as `row['name']`.
  /// `cellValue = row[columnConfig.key]`
  final String key;

  /// The widget for the column header.
  /// This is usually used to display the column name in the header.
  final Widget Function()? widgetBuilder;

  /// Optional horizontal span for the column.
  /// This can be used to specify how many horizontal spans the column should take.
  /// If not provided, the column will take the minimum space specified with [minWidth].
  final SpanExtent? horizontalSpan;

  /// Optional cursor for the cells in this column.
  /// This can be used to change the cursor style when hovering over the cells.
  /// If not provided, the default cursor will be used.
  final MouseCursor? cellCursor;

  /// Minimum width for the column.
  /// This is used to ensure that the column does not shrink below this width.
  final double minWidth;

  /// Alignment for the content of the column cells.
  /// This can be used to align text or other content within the cells.
  /// Defaults to [Alignment.centerLeft].
  final Alignment? contentAlignment;

  /// Optional function to compare two values in the column.
  /// This is used for sorting the column.
  /// If provided, column is sortable.
  final int Function(dynamic a, dynamic b)? comparer;

  /// Optional field to track the sort order for the column.
  /// This can be used to determine if the column is sorted in ascending or descending order.
  /// If null, the column is not sorted.
  bool? isAscending;

  final TableViewExHeaderStyle? headerStyle;

  TableViewExColumnConfig({
    required this.key,
    required this.widgetBuilder,
    this.headerStyle,
    this.horizontalSpan,
    this.minWidth = 10,
    this.contentAlignment = Alignment.centerLeft,
    this.cellCursor,
    this.comparer,
  });
}
