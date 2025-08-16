import 'package:flutter/material.dart';
import 'package:table_view_ex/table_view_ex.dart';

/// Sorted column moved Intent action handler
class TableViewExSortedColumnMovedIntentHandler extends Action<TableViewExSortedColumnMovedIntent> {
  final void Function(int newSortedColumnIndex) onNotified;

  TableViewExSortedColumnMovedIntentHandler(this.onNotified);

  @override
  void invoke(covariant TableViewExSortedColumnMovedIntent intent) => onNotified(intent.newSortedColumnIndex);
}
