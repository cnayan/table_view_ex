// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class TableViewExCellSelectionChangeIntent extends Intent {
  final int? rowIndex;
  final int? colIndex;
  const TableViewExCellSelectionChangeIntent(this.rowIndex, this.colIndex);
}
