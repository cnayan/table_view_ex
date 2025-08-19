// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_view_ex/src/table_view_ex_column_re_arrangement_intent.dart';
import 'package:table_view_ex/src/table_view_ex_width_calculator.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'table_view_ex_column_config.dart';
import 'extensions/color_extensions.dart';
import 'table_view_ex_cell_selection_change_intent.dart';

enum SelectionMode {
  none,
  cell,
  row,
}

typedef RowColorProvider = Color Function(int rowIndex);
typedef SortRequestHandler = void Function(int colIndex);

/// Extended [TableView] class which provides features:
/// - Column width change by user
/// - Column rearrangement by user
/// - Scrollbars visibility if desired
/// - Column sorting with indicator
class ViewOnlyTableViewEx extends StatefulWidget {
  /// The color of the scrollbar thumb.
  /// Defaults to [Colors.grey].
  final Color? scrollThumbColor;

  /// The thickness of the scrollbar thumb.
  /// Defaults to 6.
  final double? scrollThumbThickness;

  /// Allows visibility control of vertical scrollbar.
  ///
  /// If [verticalThumbVisibility] is false and [horizontalThumbVisibility] is false, you will not see the scrollbars.
  ///
  /// See [RawScrollbar.trackVisibility] for default behaviors.
  final bool? verticalThumbVisibility;

  /// Allows visibility control of horizontal scrollbar.
  ///
  /// If [verticalThumbVisibility] is false and [horizontalThumbVisibility] is false, you will not see the scrollbars.
  ///
  /// See [RawScrollbar.trackVisibility] for default behaviors.
  final bool? horizontalThumbVisibility;

  /// Whether the table has a header row.
  /// If true, the first row is treated as the header.
  final bool showHeader;

  /// Optional function to provide alternating row colors.
  /// If not provided, no alternating colors are applied.
  final RowColorProvider? rowBackgroundColorProvider;

  /// The columns of the table.
  /// Each column is defined by an [TableViewExColumnConfig].
  final List<TableViewExColumnConfig> columnDefinitions;

  /// Optional parameter [horizontalBorderSide]: The border style for the lines.
  /// If you want to disable internal horizontal lines, skip it.
  final BorderSide? horizontalBorderSide;

  /// Optional parameter [verticalBorderSide]: The border style for the lines.
  /// If you want to disable internal vertical lines, skip it.
  final BorderSide? verticalBorderSide;

  /// Optional parameter [allowColumnReordering]: Whether to allow reordering of columns by dragging.
  /// Defaults to false.
  final bool? allowColumnReordering;

  /// Optional parameter [enableColumnWidthResize]: Whether to allow resizing of column widths.
  /// Defaults to true.
  final bool enableColumnWidthResize;

  /// The width of the divider line used for resizing columns.
  final double? resizingSeparatorWidth;

  /// The color of the divider line used for resizing columns.
  ///
  /// Default is null.
  final Color? resizingSeparatorColor;

  /// A function that builds the span extent for each row.
  /// The function receives the row index and returns a [SpanExtent].
  final SpanExtent Function(int rowIndex) rowSpanBuilder;

  /// The total number of rows in the table.
  final int contentRowsCount;

  /// A function that builds the widget for each cell.
  /// The function receives the [BuildContext] and the (colIndex, rowIndex) of the cell.
  final Widget Function(
    BuildContext context,
    int colIndex,
    int rowIndex,
  ) contentCellWidgetBuilder;

  /// Optional feature: Provide a function that calculates the maximum width of content in that column.
  ///
  /// It is used to lazily calculate max column width and expand it to that size, when user double click the right edge of the column.
  final double Function(int colIndex)? contentMaxWidthProvider;

  /// Optional callback for sorting requests.
  final SortRequestHandler? onSortRequested;

  /// An implementation for the calculator of column widths
  final TableViewExWidthCalculator columnWidthCalculator;

  /// Option to set the selection style, if any
  final SelectionMode? selectionMode;

  /// Option to set the selected widget color, if any
  final Color? selectionBackgroundColor;

  ViewOnlyTableViewEx({
    super.key,
    required this.columnDefinitions,
    required this.rowSpanBuilder,
    required this.contentRowsCount,
    required this.contentCellWidgetBuilder,
    required this.onSortRequested,
    required this.columnWidthCalculator,
    this.contentMaxWidthProvider,
    this.enableColumnWidthResize = true,
    this.scrollThumbColor = Colors.grey,
    this.scrollThumbThickness = 6,
    this.resizingSeparatorWidth = 1.9,
    this.resizingSeparatorColor,
    this.showHeader = false,
    this.horizontalBorderSide,
    this.verticalBorderSide,
    this.rowBackgroundColorProvider,
    this.allowColumnReordering = false,
    this.verticalThumbVisibility,
    this.horizontalThumbVisibility,
    this.selectionMode,
    this.selectionBackgroundColor,
  })  : assert(columnDefinitions.isNotEmpty,
            'columnDefinitions must not be empty'),
        assert(contentRowsCount >= 0, 'rowCount must be non-negative');

  @override
  State<ViewOnlyTableViewEx> createState() => _ViewOnlyTableViewExState();
}

class _ViewOnlyTableViewExState extends State<ViewOnlyTableViewEx> {
  List<double>? _calculatedColumnWidths;
  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();

  int? _lastSortedColumn;
  bool _isResizing = false;
  int? _resizingColumnIndex;

  int get _columnCount => widget.columnDefinitions.length;
  int get _contentRowsCount => widget.contentRowsCount;

  int? _selectedRow, _selectedColumn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width once - translate the span widths to pixel width values
        _calculatedColumnWidths ??= widget.columnWidthCalculator
            .calculateColumnWidths(
                constraints.maxWidth, widget.columnDefinitions);
        assert(_calculatedColumnWidths?.length == _columnCount,
            "All column width were not provided");

        final TableCellBuilderDelegate cellBuilder = TableCellBuilderDelegate(
          columnCount: _columnCount,
          rowCount: _contentRowsCount > 0
              ? _contentRowsCount + (widget.showHeader ? 1 : 0)
              : null,
          pinnedRowCount: widget.showHeader ? 1 : 0,
          columnBuilder: (int colIndex) => TableSpan(
            extent: FixedTableSpanExtent(_calculatedColumnWidths![colIndex]),
          ),
          rowBuilder: (rowIndex) => Span(
            extent: widget.rowSpanBuilder(rowIndex),
            backgroundDecoration: widget.selectionMode == SelectionMode.row &&
                    _selectedRow != null &&
                    _selectedRow! == rowIndex
                ? SpanDecoration(
                    color: widget.selectionBackgroundColor,
                  )
                : null,
          ),
          cellBuilder: _cellBuilder,
        );

        final tableView = TableView(
          delegate: cellBuilder,
          verticalDetails:
              ScrollableDetails.vertical(controller: _verticalScrollController),
          horizontalDetails: ScrollableDetails.horizontal(
              controller: _horizontalScrollController),
        );

        // If user doesn't want to see scollbars
        if (widget.verticalThumbVisibility == false &&
            widget.horizontalThumbVisibility == false) {
          return tableView;
        }

        // Keep some padding for the scrollbars to avoid overlapping on the content
        EdgeInsetsGeometry padding = EdgeInsetsGeometry.zero;
        if (widget.scrollThumbThickness != null) {
          if (widget.horizontalThumbVisibility == true &&
              widget.verticalThumbVisibility != true) {
            padding =
                EdgeInsetsGeometry.only(right: widget.scrollThumbThickness!);
          } else if (widget.horizontalThumbVisibility == true &&
              widget.verticalThumbVisibility == true) {
            padding = EdgeInsetsGeometry.only(
                right: widget.scrollThumbThickness!,
                bottom: widget.scrollThumbThickness!);
          } else if (widget.horizontalThumbVisibility != true &&
              widget.verticalThumbVisibility == true) {
            padding =
                EdgeInsetsGeometry.only(bottom: widget.scrollThumbThickness!);
          }
        }

        return RawScrollbar(
          controller: _verticalScrollController,
          thumbColor: widget.scrollThumbColor,
          thickness: widget.scrollThumbThickness,
          thumbVisibility: widget.verticalThumbVisibility,
          child: RawScrollbar(
            controller: _horizontalScrollController,
            thumbColor: widget.scrollThumbColor,
            thickness: widget.scrollThumbThickness,
            thumbVisibility: widget.horizontalThumbVisibility,
            child: Padding(
              padding: padding,
              child: tableView,
            ),
          ),
        );
      },
    );
  }

  /// Builds the cell widget for the table.
  /// If the row index is 0 and [showHeader] is true, it builds the header cell.
  /// Otherwise, it builds a content cell with the provided cell widget.
  TableViewCell _cellBuilder(BuildContext context, TableVicinity vicinity) {
    final Widget wrappedWidget;
    if (vicinity.row == 0 && widget.showHeader) {
      wrappedWidget = _buildHeaderCell(vicinity);
    } else {
      // Adjust the row index for the header "row"
      final rowIndex = widget.showHeader ? vicinity.row - 1 : vicinity.row;

      Widget child =
          widget.contentCellWidgetBuilder(context, vicinity.column, rowIndex);
      wrappedWidget = _buildContentCell(vicinity, child);
    }

    return TableViewCell(child: wrappedWidget);
  }

  /// Builds the content cell with the appropriate styling and alignment.
  /// This includes applying the row background color and borders.
  ///
  /// The cell is aligned based on the column's content alignment.
  /// The cell width is determined by the calculated column widths.
  /// The cell is wrapped in a container with the specified background color and border.
  /// If the rowBackgroundColorProvider is provided, it will be used to set the background color,
  /// else, the cell will have a transparent background.
  /// The cell will also have borders based on the showVerticalLines and showHorizontalLines properties.
  /// The borders are set based on the visibility of vertical and horizontal lines configured.
  /// The cell will also have a minimum width based on the column's minWidth property.
  Widget _buildContentCell(TableVicinity vicinity, Widget cell) {
    Border border = _createInternalLineBorder(vicinity.column, vicinity.row);

    Widget result = Container(
      alignment: widget.columnDefinitions[vicinity.column].contentAlignment,
      width: _calculatedColumnWidths![vicinity.column],
      decoration: BoxDecoration(
        color: widget.selectionMode == SelectionMode.cell &&
                _selectedRow == vicinity.row &&
                _selectedColumn == vicinity.column
            ? widget.selectionBackgroundColor ?? Colors.transparent
            : widget.rowBackgroundColorProvider != null
                ? widget.rowBackgroundColorProvider!(vicinity.row)
                : Colors.transparent,
        border: border,
      ),
      child: cell,
    );

    if (widget.selectionMode == SelectionMode.row ||
        widget.selectionMode == SelectionMode.cell) {
      result = GestureDetector(
        onTap: () {
          if (_selectedRow != vicinity.row ||
              _selectedColumn != vicinity.column) {
            setState(() {
              _selectedRow = vicinity.row;
              _selectedColumn = vicinity.column;
            });

            Actions.invoke(
                context,
                TableViewExCellSelectionChangeIntent(
                    widget.showHeader ? _selectedRow! - 1 : _selectedRow,
                    _selectedColumn));
          }
        },
        child: result,
      );
    }

    return result;
  }

  /// Builds the header cell with the appropriate styling and alignment.
  /// This includes applying the header style, text alignment, and borders.
  ///
  /// The header cell will have a background color and text style defined in the headerStyle.
  /// If headerStyle is not provided, it will
  /// - use the text color specified in the column definition, if available.
  /// - use the backgroundColor specified in the column definition, if available.
  ///
  /// It will create controls to alter the width of the column if enableColumnWidthResize is true.
  ///
  /// It will also handle drag-and-drop reordering of columns, if allowColumnReordering is set to true.
  Widget _buildHeaderCell(TableVicinity vicinity) {
    final colIndex = vicinity.column;
    final TableViewExColumnConfig columnDef =
        widget.columnDefinitions[colIndex];

    final backgroundColor = columnDef.headerStyle?.backgroundColor ??
        Theme.of(context).textTheme.bodyMedium?.backgroundColor ??
        Colors.transparent;
    Color contrastingColor = backgroundColor.getContrastColor();

    final fontSize = (Theme.of(context).textTheme.bodyMedium ??
                TextStyle(color: contrastingColor))
            .fontSize ??
        14;

    if (widget.showHeader == true) {
      assert(columnDef.widgetBuilder != null,
          "Cannot show header without header widget builder.");
    }

    final Widget? headerWidget =
        columnDef.widgetBuilder != null ? columnDef.widgetBuilder!() : null;

    const iconSpacing = 2.0;
    final IconData? sortIcon = _lastSortedColumn == colIndex
        ? (columnDef.isAscending ?? true
            ? Icons.arrow_upward
            : Icons.arrow_downward)
        : null;

    Widget result = GestureDetector(
      onTap: () => _sortEventHandler(columnDef, colIndex),
      child: Container(
        color: backgroundColor,
        alignment: columnDef.headerStyle?.textAlignment,
        width: _calculatedColumnWidths![colIndex],
        child: Row(
          children: [
            if (headerWidget != null) Expanded(child: headerWidget),
            if (sortIcon != null) // Show icon only if sorted
              Padding(
                padding: const EdgeInsets.only(right: iconSpacing),
                // Icon color matches text color
                child: Icon(sortIcon, size: fontSize, color: contrastingColor),
              ),
          ],
        ),
      ),
    );

    if (widget.enableColumnWidthResize) {
      result = Stack(
        children: [
          result,
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                if (widget.contentMaxWidthProvider != null) {
                  _expandColumnToContentSize(columnDef, vicinity);
                }
              },
              onHorizontalDragStart: (details) {
                _isResizing = true;
                _resizingColumnIndex = colIndex;
              },
              onHorizontalDragUpdate: (details) {
                if (_isResizing && _resizingColumnIndex == colIndex) {
                  // Add a minimum width constraint
                  final double newWidth = max(
                    _calculatedColumnWidths![colIndex] + details.delta.dx,
                    columnDef.minWidth,
                  );

                  setState(() {
                    _calculatedColumnWidths![colIndex] = newWidth;
                  });
                }
              },
              onHorizontalDragCancel: () {
                _isResizing = false;
                _resizingColumnIndex = null;
              },
              onHorizontalDragEnd: (details) {
                _isResizing = false;
                _resizingColumnIndex = null;
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(
                  width: widget.resizingSeparatorWidth ?? 3.0,
                  color: widget.resizingSeparatorColor ?? Colors.transparent,
                ),
              ),
            ),
          )
        ],
      );
    }

    Widget finalWidget = result;
    if (widget.allowColumnReordering == true) {
      result = Draggable<int>(
        data: colIndex,
        feedback: Material(
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: backgroundColor,
                ),
                color: backgroundColor,
              ),
              child: result),
        ),
        child: result,
      );

      finalWidget = DragTarget<int>(
        onWillAcceptWithDetails: (details) =>
            details.data != colIndex && !_isResizing,
        onAcceptWithDetails: (details) => _rearrangeColumns(colIndex, details),
        builder: (context, candidateData, rejectedData) => result,
      );
    }

    return finalWidget;
  }

  /// A basic 'sort' event handler
  void _sortEventHandler(TableViewExColumnConfig columnDef, int colIndex) {
    if (columnDef.comparer != null) {
      bool isAscendingOrder = true;
      if (_lastSortedColumn == colIndex && columnDef.isAscending != null) {
        isAscendingOrder = !columnDef.isAscending!;
      }

      columnDef.isAscending = isAscendingOrder;

      widget.onSortRequested?.call(colIndex);
      setState(() {
        _lastSortedColumn = colIndex;
      });
    }
  }

  /// Puts the column in its place
  void _rearrangeColumns(int colIndex, DragTargetDetails<int> details) {
    final TableViewExColumnConfig draggedColumn =
        widget.columnDefinitions.removeAt(details.data);
    widget.columnDefinitions.insert(colIndex, draggedColumn);
    final double colWidth = _calculatedColumnWidths!.removeAt(details.data);
    _calculatedColumnWidths!.insert(colIndex, colWidth);

    if (_lastSortedColumn != null) {
      _adjustSortedColumnIndex(details.data, colIndex);
    }

    setState(() {});
  }

  void _adjustSortedColumnIndex(int oldIndex, int newIndex) {
    if (_lastSortedColumn == null) {
      return;
    }

    int newSortedColumnIndex = _lastSortedColumn!;

    if (_lastSortedColumn == oldIndex) {
      newSortedColumnIndex = newIndex;
    } else if (oldIndex < newIndex &&
        _lastSortedColumn! > oldIndex &&
        _lastSortedColumn! <= newIndex) {
      // A column to the left of the sorted column was moved to the right,
      // shifting the sorted column one position to the left.
      newSortedColumnIndex--;
    } else if (oldIndex > newIndex &&
        _lastSortedColumn! >= newIndex &&
        _lastSortedColumn! < oldIndex) {
      // A column to the right of the sorted column was moved to the left,
      // shifting the sorted column one position to the right.
      newSortedColumnIndex++;
    }

    if (newSortedColumnIndex != _lastSortedColumn!) {
      _lastSortedColumn = newSortedColumnIndex;
      Actions.invoke(
          context, TableViewExSortedColumnMovedIntent(newSortedColumnIndex));
    }
  }

  /// Expands the column to fit the content size.
  /// This is done by measuring the content width and updating the column width.
  void _expandColumnToContentSize(
    TableViewExColumnConfig columnDef,
    TableVicinity vicinity,
  ) {
    if (widget.contentMaxWidthProvider != null && _contentRowsCount > 0) {
      Border createLineBorder =
          _createInternalLineBorder(vicinity.column, widget.showHeader ? 1 : 0);
      final double maxWidth = widget.contentMaxWidthProvider!(vicinity.column) +
          createLineBorder.left.width +
          createLineBorder.right.width +
          10; // Add some padding
      setState(() {
        _calculatedColumnWidths![vicinity.column] = maxWidth + 10;
      });
    }
  }

  /// Creates a border for the cell based on the visibility of vertical and horizontal lines.
  /// Sets internal border sides as provided with `borderSide`, if provided.
  /// If the border side is [BorderSide.none] or not given, no border will be drawn.
  /// Returns a [Border] object with the appropriate sides set.
  Border _createInternalLineBorder(int colIndex, int rowIndex) {
    final hBorderSide = rowIndex < _contentRowsCount - 1
        ? widget.horizontalBorderSide ?? BorderSide.none
        : BorderSide.none;

    final vBorderSide = colIndex < _columnCount - 1
        ? widget.verticalBorderSide ?? BorderSide.none
        : BorderSide.none;

    return Border(right: vBorderSide, bottom: hBorderSide);
  }
}
