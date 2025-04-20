import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';

class LogModel extends ChangeNotifier {
  final logController = CodeLineEditingController();

  final List<Command> commands = [];

  String prevOperation = '';

  void appendTemplate(String text) {
    prevOperation = text;
  }

  void appendDelay(int delay) {
    if (prevOperation.isEmpty) {
      return;
    }
    logController.text += "${Command(prevOperation, delay)}\n";
    prevOperation = '';
    notifyListeners();
  }

  void append(String text) {
    logController.text += "$text\n";
    prevOperation = '';
    notifyListeners();
  }

  void info(String text) {
    logController.text += "${now()} [INFO] $text\n";
    notifyListeners();
  }

  void clear() {
    logController.text = '';
  }
}

class Command {
  final String template;

  final int delay;

  Command(this.template, this.delay);

  @override
  String toString() {
    return template.replaceFirst('%s', delay.toString());
  }
}

/// 获取日期并格式化
String now() {
  return DateFormat('yyyy-MM-dd HH:mm:ss:SSS').format(DateTime.now());
}
