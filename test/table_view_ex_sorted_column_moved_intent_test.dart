import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_view_ex/src/table_view_ex_sorted_column_moved_intent.dart';

void main() {
  group('TableViewExSortedColumnMovedIntent', () {
    test('should create instance with zero index', () {
      const intent = TableViewExSortedColumnMovedIntent(0);
      expect(intent.newSortedColumnIndex, equals(0));
    });

    test('should create instance with positive index', () {
      const intent = TableViewExSortedColumnMovedIntent(5);
      expect(intent.newSortedColumnIndex, equals(5));
    });

    test('should create instance with large index', () {
      const intent = TableViewExSortedColumnMovedIntent(999999);
      expect(intent.newSortedColumnIndex, equals(999999));
    });

    test('instances with same index should be equal', () {
      const intent1 = TableViewExSortedColumnMovedIntent(1);
      const intent2 = TableViewExSortedColumnMovedIntent(1);
      expect(intent1, equals(intent2));
      expect(intent1.hashCode, equals(intent2.hashCode));
    });

    test('instances with different indices should not be equal', () {
      const intent1 = TableViewExSortedColumnMovedIntent(1);
      const intent2 = TableViewExSortedColumnMovedIntent(2);
      expect(intent1, isNot(equals(intent2)));
      expect(intent1.hashCode, isNot(equals(intent2.hashCode)));
    });

    test('should work as Intent type', () {
      const intent = TableViewExSortedColumnMovedIntent(1);
      expect(intent, isA<Intent>());
    });

    test('should create non-const instance', () {
      final intent = TableViewExSortedColumnMovedIntent(10);
      expect(intent.newSortedColumnIndex, equals(10));
    });
  });
}
