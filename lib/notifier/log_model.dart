import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';
import 'package:uuid/uuid.dart';

import '../app/windows_app.dart';

class LogModel extends ChangeNotifier {
  final logController = CodeLineEditingController();

  final List<Command> commands = [];

  List<String> prevOperations = [];

  void appendTemplate(String text) {
    prevOperations.add(text);
  }

  void output() {
    if (WindowsApp.scriptEditorModel.selectedDir == '自动传') {
      outputAsRoute();
    } else {
      outputAsScript();
    }
  }

  /// 输出为脚本
  void outputAsScript() {
    for (var element in prevOperations) {
      logController.text += "$element\n";
    }
    prevOperations = [];
  }

  /// 输出为路线
  void outputAsRoute() {
    var script = '';
    for (var element in prevOperations) {
      script += "$element ";
    }
    logController.text += "name: \"${Uuid().v4()}\", script: \"$script\"\n";
    prevOperations = [];
  }

  void appendDelay(int delay) {
    if (prevOperations.isEmpty) {
      return;
    }
    prevOperations.last = prevOperations.last.replaceFirst('%s', delay.toString());
    notifyListeners();
  }

  void append(String text) {
    logController.text += "$text\n";
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
