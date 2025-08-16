// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:table_view_ex/src/table_view_ex_column_config.dart';

abstract class TableViewExWidthCalculator {
  /// Calculates the actual pixel widths based on the current constraints
  List<double> calculateColumnWidths(double viewportWidth, List<TableViewExColumnConfig> columnDefinitions);
}
