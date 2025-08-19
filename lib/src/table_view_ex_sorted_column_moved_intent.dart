// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class TableViewExSortedColumnMovedIntent extends Intent {
  final int newSortedColumnIndex;
  const TableViewExSortedColumnMovedIntent(this.newSortedColumnIndex);
}
