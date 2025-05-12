import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/record_config.dart';
import 'package:assistant/constants/script_type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';

import '../app/windows_app.dart';

class Operation {
  final String func;
  List<int> coords;
  String template;
  int prevDelay;

  static Operation confirm = Operation(
      func: "click",
      coords: AutoTpConfig.to.getConfirmPosIntList(),
      template:
          "click(${AutoTpConfig.to.getConfirmPos()[0]}, ${AutoTpConfig.to.getConfirmPos()[1]}, %s);",
      prevDelay: AutoTpConfig.to.getClickRecordDelay());

  static Operation openMap = Operation(
      func: "map",
      coords: [],
      template: "map(%s);",
      prevDelay: AutoTpConfig.to.getMapRecordDelay());

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
        !['kDown', 'mDown', 'kUp', 'mUp', 'click', 'tpc']
            .contains(operation.func)) {
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
            ? AutoTpConfig.to.getClickRecordDelay()
            : operation.prevDelay;
        previousOperation.template =
            "click([${operation.coords[0]}, ${operation.coords[1]}], $delay);";
        previousOperation.prevDelay = delay;
      } else {
        // 归类为拖动
        final delay = RecordConfig.to.getEnableDefaultDelay()
            ? AutoTpConfig.to.getDragRecordDelay()
            : operation.prevDelay;
        final shortMove = AutoTpConfig.to.getShortMoveRecord();
        previousOperation.template =
            "drag([${previousOperation.coords[0]}, ${previousOperation.coords[1]}, ${operation.coords[0]}, ${operation.coords[1]}], $shortMove, $delay);";
        previousOperation.prevDelay = delay;
      }
    } else {
      prevOperations.add(operation);
    }
  }

  void output() {
    if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
      outputAsRoute();
    } else {
      outputAsScript();
    }
  }

  CodeLineEditingController get scriptController {
    return WindowsApp.scriptEditorModel.controller;
  }

  /// 输出为脚本
  void outputAsScript() {
    if (operationDown) {
      return;
    }
    for (var element in prevOperations) {
      appendText("$element\n");
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
    for (var index = 0; index < prevOperations.length; index++) {
      var element = prevOperations[index];
      if (!openMapKeyFound &&
          element.template
              .contains("press('${RecordConfig.to.getOpenMapKey()}'")) {
        element = Operation.openMap;
        openMapKeyFound = true;
      }
      if (openMapKeyFound) {
        script += index == prevOperations.length - 1
            ? element.toString()
            : '$element ';
      }
    }

    if (script.isNotEmpty) {
      appendText("script: \"$script\"\n");
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
    appendText("$text\n");
    notifyListeners();
  }

  appendText(text) {
    var content = scriptController.text;
    if (content.endsWith('\n')) {
      content = content.substring(0, content.length - 1);
    }
    if (content.trim().isEmpty) {
      scriptController.text = '$text';
    } else {
      scriptController.text = '$content\n$text';
    }

    // 设置光标位置到末尾
    scriptController.selection = CodeLineSelection.collapsed(
      index: scriptController.codeLines.length - 1,
      offset: scriptController.codeLines.last.length,
    );
  }

  void info(String text) {
    logController.text += "${now()} [INFO] $text\n";
    notifyListeners();
  }

// void clear() {
//   scriptController.text = '';
// }
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
