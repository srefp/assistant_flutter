import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';

class LogModel extends ChangeNotifier {
  final logController = CodeLineEditingController();

  void append(String text) {
    logController.text += "${now()} [INFO] $text\n";
    notifyListeners();
  }
}

/// 获取日期并格式化
String now() {
  return DateFormat('yyyy-MM-dd HH:mm:ss:SSS').format(DateTime.now());
}
