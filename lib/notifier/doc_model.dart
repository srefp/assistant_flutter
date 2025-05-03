import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class DocModel extends ChangeNotifier {
  String _doc = '';

  String get doc => _doc;

  DocModel() {
    loadFile();
  }

  loadFile() async {
    _doc = await rootBundle.loadString('assets/doc/operation.md');
    notifyListeners();
  }

  set doc(String value) {
    _doc = value;
    notifyListeners();
  }
}
