import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_view_ex/table_view_ex.dart';

import 'table_view_ex_sorted_column_moved_intent_handler.dart';

const int maxRows = 30; // Maximum number of dummy rows for the table
int defaultComparer(a, b) => a.compareTo(b); // Generic comparer method

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<TableViewExColumnConfig> columnDefs;
  late List<Map<String, String?>> rows;
  // int? _lastSortedColumn;

  @override
  void initState() {
    super.initState();
    columnDefs = _createColumnDefinitions();
    rows = _createRows();
  }

  final ValueNotifier notifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'table_view_ex demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Actions(
          actions: <Type, Action<Intent>>{
            TableViewExSortedColumnMovedIntent: TableViewExSortedColumnMovedIntentHandler((int newSortedColumnIndex) {
              // _lastSortedColumn = newSortedColumnIndex;
            }),
          },
          child: ViewOnlyTableViewEx(
            verticalThumbVisibility: true,
            horizontalThumbVisibility: true,
            scrollThumbColor: Colors.deepPurple,
            scrollThumbThickness: 10.0,

            showHeader: true,
            columnDefinitions: columnDefs,
            columnWidthCalculator: DefaultTableViewExWidthCalculator(),
            contentRowsCount: rows.length,
            rowSpanBuilder: (int rowIndex) => const FixedTableSpanExtent(30),
            contentCellWidgetBuilder: (context, int colIndex, int rowIndex) => _contentCellWidgetBuilder(
              context,
              columnDefs,
              rows,
              colIndex,
              rowIndex,
            ),

            // expand to max content width
            contentMaxWidthProvider: (colIndex) => _contentMaxWidthCalculator(columnDefs[colIndex], rows),

            allowColumnReordering: true,
            // scrollThumbThickness: 100,

            verticalBorderSide: const BorderSide(color: Colors.purple, width: 1.5),
            horizontalBorderSide: const BorderSide(color: Colors.red, width: 1.5),
            rowBackgroundColorProvider: (row) => row.isOdd ? Colors.transparent : Colors.grey[200]!,
            onSortRequested: (int colIndex) {
              final columnDef = columnDefs[colIndex];
              final comparer = columnDef.comparer;
              if (comparer != null) {
                setState(() {
                  rows.sort((rowA, rowB) {
                    final aVal = rowA[columnDef.key], bVal = rowB[columnDef.key];
                    return columnDef.isAscending! ? comparer(aVal, bVal) : comparer(bVal, aVal);
                  });
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _contentCellWidgetBuilder(
    BuildContext context,
    List<TableViewExColumnConfig> columnDefs,
    List<Map<String, String?>> rows,
    int colIndex,
    int rowIndex,
  ) {
    Map<String, Object?> row = rows[rowIndex];
    return Text(
      row[columnDefs[colIndex].key].toString(),
      overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
      maxLines: 1, // Ensure ellipsis is at the end
      softWrap: false, // Prevent text from wrapping
    );
  }

  /// Find widest cell content in pixels
  double _contentMaxWidthCalculator(TableViewExColumnConfig columnDef, List<Map<String, String?>> rows) {
    double maxWidth = 0.0;
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final Map<String, String?> row = rows[rowIndex];
      String contentAsText;
      if (row[columnDef.key] == null) {
        contentAsText = "";
      } else if (row[columnDef.key] is String) {
        contentAsText = row[columnDef.key] as String;
      } else {
        // Force the text conversion - can be controlled by user
        contentAsText = row[columnDef.key].toString();
      }

      final measuredWidth = _measureTextSize(contentAsText, null).width;
      maxWidth = max(maxWidth, measuredWidth);
    }

    return maxWidth;
  }
}

/// Rough estimation of the text size in pixels
Size _measureTextSize(String? text, TextStyle? style) {
  if (text == null || text.isEmpty) {
    return Size.zero;
  }

  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

/// Creates column definitions for the table
List<TableViewExColumnConfig> _createColumnDefinitions() {
  // 5 Columns for the data
  return [
    TableViewExColumnConfig(
      key: 'name',
      widgetBuilder: () {
        return Text(
          'Name',
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(color: Colors.blue.getContrastColor()),
        );
      },
      horizontalSpan: const RemainingSpanExtent(),
      headerStyle: const TableViewExHeaderStyle(
        backgroundColor: Colors.blue,
      ),
      comparer: defaultComparer,
    ),
    TableViewExColumnConfig(
      key: 'price',
      widgetBuilder: () => Text(
        'Price',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(color: Colors.green.getContrastColor()),
      ),
      horizontalSpan: const FixedSpanExtent(50),
      headerStyle: const TableViewExHeaderStyle(
        textAlignment: Alignment.centerRight,
        backgroundColor: Colors.green,
      ),
      contentAlignment: Alignment.centerRight,
      comparer: defaultComparer,
    ),
    TableViewExColumnConfig(
      key: 'qty',
      widgetBuilder: () => Text(
        'Qty',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(color: Colors.orange.getContrastColor()),
      ),
      horizontalSpan: const FixedSpanExtent(50),
      headerStyle: const TableViewExHeaderStyle(
        textAlignment: Alignment.centerRight,
        backgroundColor: Colors.orange,
      ),
      contentAlignment: Alignment.centerRight,
      comparer: defaultComparer,
    ),
    TableViewExColumnConfig(
      key: 'category',
      widgetBuilder: () => Text(
        'Category',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(color: Colors.purple.getContrastColor()),
      ),
      horizontalSpan: const RemainingSpanExtent(),
      headerStyle: const TableViewExHeaderStyle(
        textAlignment: Alignment.centerRight,
        backgroundColor: Colors.purple,
      ),
    ),
    TableViewExColumnConfig(
      key: 'description',
      widgetBuilder: () => Text(
        'Description',
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(color: Colors.yellow.getContrastColor()),
      ),
      horizontalSpan: const RemainingSpanExtent(),
      headerStyle: const TableViewExHeaderStyle(
        textAlignment: Alignment.centerRight,
        backgroundColor: Colors.yellow,
      ),
      comparer: defaultComparer,
    ),
  ];
}

/// Create dummy rows data for the table
List<Map<String, String?>> _createRows() {
  // Generate dummy data rows
  final List<Map<String, String?>> rows = List.generate(maxRows, (i) {
    return {
      'name':
          '${i + 1} Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'price': Random().nextInt(100).toString(),
      'qty': Random().nextInt(100).toString(),
      'category':
          'Unsortable - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'description': 'This is a description for product ${i + 1}',
    };
  });

  return rows;
}
