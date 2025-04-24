import 'package:assistant/config/record_config.dart';
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

  static Operation confirm = Operation(
      func: "click",
      coords: RecordConfig.to.getConfirmPosition(),
      template:
          "click(${RecordConfig.to.getConfirmPosition()[0]}, ${RecordConfig.to.getConfirmPosition()[1]}, %s);",
      prevDelay: RecordConfig.to.getClickDelay());

  static Operation openMap = Operation(
      func: "press",
      coords: [],
      template: "press('${RecordConfig.to.getOpenMapKey()}', %s);",
      prevDelay: RecordConfig.to.getOpenMapDelay());

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

  void appendOperation(Operation operation, {bool route = true}) {
    // 路线模式下，只记录键盘和鼠标点击操作
    if (route &&
        !['kDown', 'mDown', 'kUp', 'mUp', 'click'].contains(operation.func)) {
      return;
    }

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
    if (operation.func == 'kUp' && previousOperation.func == 'kDown' && route) {
      previousOperation.template =
          previousOperation.template.replaceFirst('kDown', 'press');
      previousOperation.prevDelay = operation.prevDelay;
    } else if (operation.func == 'mUp' &&
        previousOperation.func == 'mDown' &&
        route) {
      if (getDiff(previousOperation.coords, operation.coords) <
          RecordConfig.to.getClickDiff()) {
        // 归类为单击
        final delay = RecordConfig.to.getEnableDefaultDelay()
            ? RecordConfig.to.getClickDelay()
            : operation.prevDelay;
        previousOperation.template =
            "click(${operation.coords[0]}, ${operation.coords[1]}, $delay);";
        previousOperation.prevDelay = delay;
      } else {
        // 归类为拖动
        final delay = RecordConfig.to.getEnableDefaultDelay()
            ? RecordConfig.to.getDragDelay()
            : operation.prevDelay;
        previousOperation.template =
            "drag([${previousOperation.coords[0]}, ${previousOperation.coords[1]}, ${operation.coords[0]}, ${operation.coords[1]}], 15, $delay);";
        previousOperation.prevDelay = delay;
      }
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

    bool openMapKeyFound = false;
    for (var element in prevOperations) {
      if (!openMapKeyFound &&
          element.template
              .contains("press('${RecordConfig.to.getOpenMapKey()}'")) {
        element = Operation.openMap;
        openMapKeyFound = true;
      }
      if (openMapKeyFound) {
        script += "$element ";
      }
    }

    if (script.isNotEmpty) {
      logController.text += "name: \"${Uuid().v4()}\", script: \"$script\"\n";
    }
    prevOperations = [];
  }

  void appendDelay(int delay) {
    if (prevOperations.isEmpty) {
      return;
    }
    prevOperations.last.prevDelay = delay;

    // if (!operationDown) {
    //   prevOperations.last.template =
    //       prevOperations.last.template.replaceFirst('%s', delay.toString());
    // }

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
