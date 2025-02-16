// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:assistant/ssh/ssh_connector.dart';
import 'package:assistant/util/asset_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ssh', () async {
    await readAsset('assets/ssh_key/Microstar.AWS.3430.SFTP.ppk');
  });

  test('shell', () async {
    executeSSH('pwd');
  });
}
