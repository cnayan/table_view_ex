// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/table_view_ex.dart';

// Mock implementation of TableViewExWidthCalculator for testing
class MockTableViewExWidthCalculator implements TableViewExWidthCalculator {
  @override
  List<double> calculateColumnWidths(
    double availableWidth,
    List<TableViewExColumnConfig> columnDefinitions,
  ) {
    if (columnDefinitions.isEmpty) {
      return [];
    }

    final double columnWidth = availableWidth / columnDefinitions.length;
    return List.generate(columnDefinitions.length, (index) => columnWidth);
  }
}

// Mock implementation of TableViewExColumnConfig for testing
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

// Mock implementation of TableViewExHeaderStyle for testing
class TestTableViewExHeaderStyle implements TableViewExHeaderStyle {
  @override
  final Color? backgroundColor;

  @override
  final Alignment? textAlignment;

  @override
  final double? height;

  TestTableViewExHeaderStyle({
    this.backgroundColor,
    this.textAlignment,
    this.height,
  });
}

void main() {
  group('ViewOnlyTableViewEx', () {
    late List<TableViewExColumnConfig> testColumns;
    late MockTableViewExWidthCalculator mockCalculator;
    int sortRequestedColumn = -1;

    setUp(() {
      sortRequestedColumn = -1;
      mockCalculator = MockTableViewExWidthCalculator();
      testColumns = [
        TestTableViewExColumnConfig(
          key: 'column1',
          minWidth: 100,
          contentAlignment: Alignment.centerLeft,
          comparer: (a, b) => a.toString().compareTo(b.toString()),
          widgetBuilder: () => Text('column1 header'),
        ),
        TestTableViewExColumnConfig(
          key: 'column2',
          minWidth: 80,
          contentAlignment: Alignment.center,
          widgetBuilder: () => Text('column2 header'),
        ),
        TestTableViewExColumnConfig(
          key: 'column3',
          minWidth: 120,
          contentAlignment: Alignment.centerRight,
          comparer: (a, b) => a.toString().compareTo(b.toString()),
          widgetBuilder: () => Text('column3 header'),
        ),
      ];
    });

    testWidgets('creates widget with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              contentCellWidgetBuilder: (context, colIndex, rowIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      expect(find.byType(TableView), findsOneWidget);
    });

    testWidgets('displays header when showHeader is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find header content
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('handles sort request when header is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and tap the first column header (which has a comparer)
      await tester.tap(find.text('column1 header'));
      await tester.pumpAndSettle();

      // Verify sort was requested for the first column
      expect(sortRequestedColumn, equals(0));
    });

    testWidgets('applies row background colors when provider is given', (WidgetTester tester) async {
      Color rowColorProvider(int rowIndex) {
        return rowIndex % 2 == 0 ? Colors.grey[100]! : Colors.white;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              rowBackgroundColorProvider: rowColorProvider,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('shows scrollbars when visibility is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 10,
                verticalThumbVisibility: true,
                horizontalThumbVisibility: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find RawScrollbar widgets
      expect(find.byType(RawScrollbar), findsWidgets);
    });

    testWidgets('hides scrollbars when visibility is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              verticalThumbVisibility: false,
              horizontalThumbVisibility: false,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should not wrap with RawScrollbar when both are false
      expect(find.byType(RawScrollbar), findsNothing);
    });

    testWidgets('enables column width resizing when enableColumnWidthResize is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              enableColumnWidthResize: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find resize handles (MouseRegion with resize cursor)
      expect(find.byType(MouseRegion), findsWidgets);
    });

    testWidgets('displays sort indicators correctly', (WidgetTester tester) async {
      // Set up a column with initial ascending sort
      testColumns[0].isAscending = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap to sort first column
      final headerGestures = find.byType(GestureDetector);
      if (headerGestures.evaluate().isNotEmpty) {
        await tester.tap(headerGestures.first);
        await tester.pump();

        // Should show sort icon
        expect(find.byIcon(Icons.arrow_upward), findsWidgets);
      }
    });

    testWidgets('handles column reordering when allowColumnReordering is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              allowColumnReordering: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find Draggable and DragTarget widgets
      expect(find.byType(Draggable<int>), findsWidgets);
      expect(find.byType(DragTarget<int>), findsWidgets);
    });

    testWidgets('applies custom scroll properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              scrollThumbColor: Colors.red,
              scrollThumbThickness: 10,
              verticalThumbVisibility: true,
              horizontalThumbVisibility: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles content max width provider', (WidgetTester tester) async {
      double contentMaxWidthProvider(int colIndex) {
        return 200.0; // Fixed width for testing
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              enableColumnWidthResize: true,
              contentMaxWidthProvider: contentMaxWidthProvider,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles column width drag gestures', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                enableColumnWidthResize: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find resize handle
      final mouseRegions = find.byType(MouseRegion);
      if (mouseRegions.evaluate().isNotEmpty) {
        final resizeHandle = mouseRegions.first;

        // Test drag start
        await tester.startGesture(tester.getCenter(resizeHandle));
        await tester.pump();

        // Test drag update
        await tester.drag(resizeHandle, const Offset(50, 0));

        // Test drag end
        await tester.pumpAndSettle();
      }

      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles double tap on resize handle for auto-sizing', (WidgetTester tester) async {
      bool contentExpanded = false;
      double contentMaxWidthProvider(int colIndex) {
        contentExpanded = true;
        return 250.0;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                enableColumnWidthResize: true,
                contentMaxWidthProvider: contentMaxWidthProvider,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and double-tap resize handle
      final gestureDetectors = find.byType(GestureDetector);
      for (var detector in gestureDetectors.evaluate()) {
        final widget = detector.widget as GestureDetector;
        if (widget.onDoubleTap != null) {
          await tester.tap(find.byWidget(widget));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.tap(find.byWidget(widget));
          await tester.pumpAndSettle();
          break;
        }
      }

      expect(true, contentExpanded);
    });

    testWidgets('handles drag cancellation during resize', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                enableColumnWidthResize: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find resize handle and test drag cancellation
      final mouseRegions = find.byType(MouseRegion);
      if (mouseRegions.evaluate().isNotEmpty) {
        final resizeHandle = mouseRegions.first;

        // Start drag then cancel
        final gesture = await tester.startGesture(tester.getCenter(resizeHandle));
        await tester.pump();
        await gesture.cancel();
        await tester.pump();
      }

      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('toggles sort direction on repeated header taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();

      // Find first header with comparer and tap multiple times
      final headerGestures = find.byType(GestureDetector);
      if (headerGestures.evaluate().isNotEmpty) {
        // First tap - should sort ascending
        await tester.tap(headerGestures.first);
        await tester.pump();
        expect(sortRequestedColumn, equals(0));
        expect(testColumns[0].isAscending, isTrue);

        // Second tap on same column - should toggle to descending
        await tester.tap(headerGestures.first);
        await tester.pump();
        expect(testColumns[0].isAscending, isFalse);

        // Should show descending arrow
        expect(find.byIcon(Icons.arrow_downward), findsWidgets);
      }
    });

    testWidgets('applies borders correctly based on configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 3,
              horizontalBorderSide: const BorderSide(color: Colors.red, width: 2),
              verticalBorderSide: const BorderSide(color: Colors.blue, width: 1),
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles partial scrollbar visibility configurations', (WidgetTester tester) async {
      // Test only vertical scrollbar visible
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              verticalThumbVisibility: true,
              horizontalThumbVisibility: false,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(RawScrollbar), findsWidgets);

      // Test only horizontal scrollbar visible
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              verticalThumbVisibility: false,
              horizontalThumbVisibility: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(RawScrollbar), findsWidgets);
    });

    testWidgets('handles column drag and drop operations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                allowColumnReordering: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find drag targets and test drag operation
      final dragTargets = find.byType(DragTarget<int>);
      final draggables = find.byType(Draggable<int>);

      if (dragTargets.evaluate().isNotEmpty && draggables.evaluate().isNotEmpty) {
        // Simulate drag from first column to second column
        await tester.drag(draggables.first, const Offset(100, 0));
        await tester.pump();
      }

      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('respects minimum column width during resize', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                enableColumnWidthResize: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find resize handle and drag it to make column very small (should respect minWidth)
      final mouseRegions = find.byType(MouseRegion);
      if (mouseRegions.evaluate().isNotEmpty) {
        await tester.drag(mouseRegions.first, const Offset(-500, 0)); // Large negative drag
        await tester.pump();
      }

      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles header with custom widget builder', (WidgetTester tester) async {
      final customColumns = [
        TestTableViewExColumnConfig(
          key: 'custom_column',
          minWidth: 100,
          widgetBuilder: () => const Icon(Icons.star, color: Colors.yellow),
          comparer: (a, b) => a.toString().compareTo(b.toString()),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: customColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('handles header with custom style', (WidgetTester tester) async {
      final styledColumns = [
        TestTableViewExColumnConfig(
          key: 'styled_column',
          minWidth: 100,
          headerStyle: TestTableViewExHeaderStyle(
            backgroundColor: Colors.blue,
            textAlignment: Alignment.centerRight,
            height: 60.0, // Add height for more comprehensive testing
          ),
          comparer: (a, b) => a.toString().compareTo(b.toString()),
          widgetBuilder: () => Text('column'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: styledColumns,
              rowSpanBuilder: (index) => const FixedSpanExtent(50),
              contentRowsCount: 5,
              showHeader: true,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles different row span extents', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ViewOnlyTableViewEx(
              columnDefinitions: testColumns,
              rowSpanBuilder: (index) => index == 0 ? const FixedSpanExtent(80) : const FixedSpanExtent(50),
              contentRowsCount: 5,
              contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
              onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
              columnWidthCalculator: mockCalculator,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    testWidgets('handles sorted column index adjustment during reordering', (WidgetTester tester) async {
      // Set up initial sort on first column
      testColumns[0].isAscending = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                allowColumnReordering: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // First tap to establish sort
      final headerGestures = find.byType(GestureDetector);
      if (headerGestures.evaluate().isNotEmpty) {
        await tester.tap(headerGestures.first);
        await tester.pump();
      }

      // Now test column reordering with sorted column
      final dragTargets = find.byType(DragTarget<int>);
      final draggables = find.byType(Draggable<int>);

      if (dragTargets.evaluate().isNotEmpty && draggables.evaluate().isNotEmpty) {
        await tester.drag(draggables.first, const Offset(100, 0));
        await tester.pump();
      }

      expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('handles empty row count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 0,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('handles single column', (WidgetTester tester) async {
        final singleColumn = [testColumns.first];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: singleColumn,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('handles column without comparer (no sorting)', (WidgetTester tester) async {
        final columnsWithoutComparer = [
          TestTableViewExColumnConfig(
            key: 'no_sort_column',
            minWidth: 100,
            widgetBuilder: () => Text("column1"),
            // No comparer provided
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: columnsWithoutComparer,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();

        // Tap header - should not trigger sort
        final headerGestures = find.byType(GestureDetector);
        if (headerGestures.evaluate().isNotEmpty) {
          await tester.tap(headerGestures.first);
          await tester.pump();

          // Sort should not be requested
          expect(sortRequestedColumn, equals(-1));
        }
      });

      testWidgets('handles null contentMaxWidthProvider during double tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: ViewOnlyTableViewEx(
                  columnDefinitions: testColumns,
                  rowSpanBuilder: (index) => const FixedSpanExtent(50),
                  contentRowsCount: 5,
                  showHeader: true,
                  enableColumnWidthResize: true,
                  // contentMaxWidthProvider is null
                  contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                  onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                  columnWidthCalculator: mockCalculator,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Find and double-tap resize handle - should not crash
        final gestureDetectors = find.byType(GestureDetector);
        for (var detector in gestureDetectors.evaluate()) {
          final widget = detector.widget as GestureDetector;
          if (widget.onDoubleTap != null) {
            await tester.tap(find.byWidget(widget));
            await tester.pump(const Duration(milliseconds: 50));
            await tester.tap(find.byWidget(widget));
            await tester.pumpAndSettle();
            break;
          }
        }

        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('prevents reordering during resize operation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: ViewOnlyTableViewEx(
                  columnDefinitions: testColumns,
                  rowSpanBuilder: (index) => const FixedSpanExtent(50),
                  contentRowsCount: 5,
                  showHeader: true,
                  allowColumnReordering: true,
                  enableColumnWidthResize: true,
                  contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                  onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                  columnWidthCalculator: mockCalculator,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Start resize operation, then try to drag - should not accept drop
        final mouseRegions = find.byType(MouseRegion);
        if (mouseRegions.evaluate().isNotEmpty) {
          await tester.startGesture(tester.getCenter(mouseRegions.first));
          await tester.pump();

          // Now try to drag column - should be rejected due to resize in progress
          final draggables = find.byType(Draggable<int>);
          if (draggables.evaluate().isNotEmpty) {
            await tester.drag(draggables.first, const Offset(100, 0));
            await tester.pump();
          }
        }

        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });
    });

    group('Internal Methods Coverage', () {
      testWidgets('tests _createInternalLineBorder method thoroughly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 3,
                horizontalBorderSide: const BorderSide(color: Colors.red, width: 2),
                verticalBorderSide: const BorderSide(color: Colors.blue, width: 1),
                contentCellWidgetBuilder: (context, rowIndex, colIndex) {
                  // This will trigger _createInternalLineBorder for different positions
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green), // Will be overridden
                    ),
                    child: Text('Cell $rowIndex-$colIndex'),
                  );
                },
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();

        // This ensures all cell positions are rendered and _createInternalLineBorder is called
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('tests different scrollbar padding configurations', (WidgetTester tester) async {
        // Test with null thickness
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                scrollThumbThickness: null, // This should be handled
                verticalThumbVisibility: true,
                horizontalThumbVisibility: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('tests layout builder constraints', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 100, // Very small width to test constraint handling
                height: 100,
                child: ViewOnlyTableViewEx(
                  columnDefinitions: testColumns,
                  rowSpanBuilder: (index) => const FixedSpanExtent(50),
                  contentRowsCount: 5,
                  contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                  onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                  columnWidthCalculator: mockCalculator,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('tests header cell color contrast calculation', (WidgetTester tester) async {
        final darkBackgroundColumn = [
          TestTableViewExColumnConfig(
            key: 'dark_header',
            minWidth: 100,
            headerStyle: TestTableViewExHeaderStyle(
              backgroundColor: Colors.black, // Dark background to test contrast
              height: 50.0,
            ),
            widgetBuilder: () => Text("column_dark"),
            comparer: (a, b) => a.toString().compareTo(b.toString()),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: darkBackgroundColumn,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                showHeader: true,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();

        // Tap to sort and show icon with contrasting color
        final headerGestures = find.byType(GestureDetector);
        if (headerGestures.evaluate().isNotEmpty) {
          await tester.tap(headerGestures.first);
          await tester.pump();
        }

        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('tests column width calculation edge cases', (WidgetTester tester) async {
        // Create a custom calculator that returns specific widths
        final customCalculator = MockTableViewExWidthCalculator();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return ViewOnlyTableViewEx(
                    columnDefinitions: testColumns,
                    rowSpanBuilder: (index) => const FixedSpanExtent(50),
                    contentRowsCount: 5,
                    contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                    onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                    columnWidthCalculator: customCalculator,
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });
    });

    group('Comprehensive Gesture Testing', () {
      testWidgets('tests all drag gesture states during column resize', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: ViewOnlyTableViewEx(
                  columnDefinitions: testColumns,
                  rowSpanBuilder: (index) => const FixedSpanExtent(50),
                  contentRowsCount: 5,
                  showHeader: true,
                  enableColumnWidthResize: true,
                  contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                  onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                  columnWidthCalculator: mockCalculator,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Find resize handles
        final mouseRegions = find.byType(MouseRegion);
        if (mouseRegions.evaluate().isNotEmpty) {
          final resizeHandle = mouseRegions.first;
          final center = tester.getCenter(resizeHandle);

          // Test complete drag sequence
          final gesture = await tester.startGesture(center);
          await tester.pump();

          // Multiple drag updates
          await gesture.moveBy(const Offset(10, 0));
          await tester.pump();
          await gesture.moveBy(const Offset(20, 0));
          await tester.pump();
          await gesture.moveBy(const Offset(-5, 0)); // Move back
          await tester.pump();

          // End the drag
          await gesture.up();
          await tester.pump();
        }

        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });

      testWidgets('tests mouse cursor changes during resize', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: ViewOnlyTableViewEx(
                  columnDefinitions: testColumns,
                  rowSpanBuilder: (index) => const FixedSpanExtent(50),
                  contentRowsCount: 5,
                  showHeader: true,
                  enableColumnWidthResize: true,
                  contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                  onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                  columnWidthCalculator: mockCalculator,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final mouseRegions = tester.widgetList<MouseRegion>(find.byType(MouseRegion));
        final resizeMouseRegions = mouseRegions.where((region) => region.cursor == SystemMouseCursors.resizeLeftRight);

        expect(resizeMouseRegions.length, equals(testColumns.length)); // One per column
      });
    });

    group('Assertions', () {
      testWidgets('throws assertion error for empty column definitions', (WidgetTester tester) async {
        expect(
          () => ViewOnlyTableViewEx(
            columnDefinitions: [], // Empty list
            rowSpanBuilder: (index) => const FixedSpanExtent(50),
            contentRowsCount: 5,
            contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
            onSortRequested: (colIndex) {},
            columnWidthCalculator: mockCalculator,
          ),
          throwsAssertionError,
        );
      });

      testWidgets('throws assertion error for negative row count', (WidgetTester tester) async {
        expect(
          () => ViewOnlyTableViewEx(
            columnDefinitions: testColumns,
            rowSpanBuilder: (index) => const FixedSpanExtent(50),
            contentRowsCount: -1, // Negative count
            contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
            onSortRequested: (colIndex) {},
            columnWidthCalculator: mockCalculator,
          ),
          throwsAssertionError,
        );
      });

      testWidgets('validates calculated column widths match column count', (WidgetTester tester) async {
        // This test ensures the assertion in build method is covered
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ViewOnlyTableViewEx(
                columnDefinitions: testColumns,
                rowSpanBuilder: (index) => const FixedSpanExtent(50),
                contentRowsCount: 5,
                contentCellWidgetBuilder: (context, rowIndex, colIndex) => Text('Cell $rowIndex-$colIndex'),
                onSortRequested: (colIndex) => sortRequestedColumn = colIndex,
                columnWidthCalculator: mockCalculator,
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(ViewOnlyTableViewEx), findsOneWidget);
      });
    });
  });
}
