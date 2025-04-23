import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';
import 'package:uuid/uuid.dart';

import '../app/windows_app.dart';

class Operation {
  final String func;
  List<int> coords;
  String template;
  int prevDelay;

  Operation({
    required this.func,
    this.coords = const [0, 0],
    required this.template,
    this.prevDelay = 0,
  });

  @override
  String toString() {
    return template.replaceFirst('%s', prevDelay.toString());
  }
}

class LogModel extends ChangeNotifier {
  final logController = CodeLineEditingController();

  final List<Command> commands = [];

  List<Operation> prevOperations = [];

  bool operationDown = false;

  /// 计算两个点位之间的差距
  int getDiff(List<int> point1, List<int> point2) {
    final dx = point2[0] - point1[0];
    final dy = point2[1] - point1[1];
    return dx.abs() + dy.abs();
  }

  void appendOperation(Operation operation) {
    if (operation.func == 'kDown' || operation.func == 'mDown') {
      operationDown = true;
    } else {
      operationDown = false;
    }

    if (prevOperations.isEmpty) {
      prevOperations.add(operation);
      return;
    }

    final previousOperation = prevOperations[prevOperations.length - 1];

    // 如果前一个操作是Down，且两个操作之间的延迟小于300ms，则将两个操作合并
    if (operation.func == 'kUp' &&
        previousOperation.func == 'kDown' &&
        operation.prevDelay < 300) {
      previousOperation.template =
          previousOperation.template.replaceFirst('kDown', 'press');
      previousOperation.prevDelay = operation.prevDelay;
    } else if (operation.func == 'mUp' &&
        previousOperation.func == 'mDown' &&
        getDiff(previousOperation.coords, operation.coords) < 500 &&
        operation.prevDelay < 300) {
      previousOperation.template =
          previousOperation.template.replaceFirst('mDown', 'click');
      previousOperation.prevDelay = operation.prevDelay;
    } else {
      prevOperations.add(operation);
    }
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
    if (operationDown) {
      return;
    }
    for (var element in prevOperations) {
      logController.text += "$element\n";
    }
    prevOperations = [];
  }

  /// 输出为路线
  void outputAsRoute() {
    if (prevOperations.isEmpty) {
      return;
    }
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
    prevOperations.last.prevDelay = delay;

    if (!operationDown) {
      prevOperations.last.template =
          prevOperations.last.template.replaceFirst('%s', delay.toString());
    }

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
