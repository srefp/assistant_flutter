// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

void main() {
  final RegExp keyValuePairRegex = RegExp(
      r'(\w+):\s*((?:"[^"]*")|(?:\[.*?\])|(?:-?\d+(?:\.\d+)?))(?:,\s*|$)'
  );

  test('regex', () async {
    final matches = keyValuePairRegex.allMatches("boss: [1, 2], delay: 1, name: \"hhh\", script: \"click([12345, 12345]); wait(1);\"");
    final res = matches.expand((match) => [match[1]!, match[2]!.replaceAll('"', '')]).toList();
    print(res);
  });
}
