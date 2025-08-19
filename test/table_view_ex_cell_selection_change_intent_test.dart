// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/src/table_view_ex_cell_selection_change_intent.dart';

void main() {
  group('TableViewExCellSelectionChangeIntent', () {
    test('can be instantiated', () {
      const intent = TableViewExCellSelectionChangeIntent(1, 2);
      expect(intent, isNotNull);
      expect(intent.rowIndex, 1);
      expect(intent.colIndex, 2);
    });

    test('can be instantiated with null values', () {
      const intent = TableViewExCellSelectionChangeIntent(null, null);
      expect(intent, isNotNull);
      expect(intent.rowIndex, isNull);
      expect(intent.colIndex, isNull);
    });
  });
}
