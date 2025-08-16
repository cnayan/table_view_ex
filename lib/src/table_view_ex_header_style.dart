// Copyright 2025 Nayan Choudhary. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class TableViewExHeaderStyle {
  /// Optional background color for the header.
  final Color? backgroundColor;

  /// Optional height for the column.
  /// This can be used to specify a fixed height for the column.
  final double? height;

  /// Alignment for the column header.
  /// This can be used to align the header text within the column.
  /// Defaults to [Alignment.centerLeft].
  final Alignment? textAlignment;

  const TableViewExHeaderStyle({
    this.height,
    this.backgroundColor,
    this.textAlignment = Alignment.centerLeft,
  });
}
