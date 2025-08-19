import 'package:flutter/material.dart';
import 'package:table_view_ex/table_view_ex.dart';

/// Sorted column moved Intent action handler
class TableViewExCellSelectionChangeIntentHandler
    extends Action<TableViewExCellSelectionChangeIntent> {
  final void Function(int? rowIndex, int? colIndex) onNotified;

  TableViewExCellSelectionChangeIntentHandler(this.onNotified);

  @override
  void invoke(covariant TableViewExCellSelectionChangeIntent intent) =>
      onNotified(intent.rowIndex, intent.colIndex);
}
