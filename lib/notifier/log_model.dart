import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/game_key_config.dart';
import 'package:assistant/config/record_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';

import '../app/windows_app.dart';
import '../config/game_pos/game_pos_config.dart';
import '../constants/script_record_mode.dart';

class Operation {
  final String func;
  List<int> coords;
  String template;
  int prevDelay;

  static Operation confirm = Operation(
      func: "click",
      coords: GamePosConfig.to.getConfirmPosIntList(),
      template:
          "click(${GamePosConfig.to.getConfirmPos()[0]}, ${GamePosConfig.to.getConfirmPos()[1]}, %s);",
      prevDelay: AutoTpConfig.to.getClickRecordDelay());

  static Operation openMap = Operation(
      func: "map",
      coords: [],
      template: "map(%s);",
      prevDelay: AutoTpConfig.to.getMapRecordDelay());

  static Operation openBook = Operation(
    func: "book",
    template: "book(%s);",
    prevDelay: AutoTpConfig.to.getBookRecordDelay(),
  );

  static Operation mDown = Operation(
    func: "mDown",
    coords: [],
    template: "mDown(%s);",
    prevDelay: AutoTpConfig.to.getClickRecordDelay(),
  );

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

typedef ValueCallback = ScriptRecordMode Function();

class LogModel extends ChangeNotifier {

  late final CodeLineEditingController scriptController;

  late final ValueCallback getScriptRecordMode;

  LogModel(this.scriptController, this.getScriptRecordMode);

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
    if (getScriptRecordMode() == ScriptRecordMode.autoTp) {
      outputAsRoute();
    } else {
      outputAsScript();
    }
  }

  /// 输出为脚本
  void outputAsScript() {
    print('prevOperations: $prevOperations');

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

    bool startKeyFound = false;
    for (var index = 0; index < prevOperations.length; index++) {
      var element = prevOperations[index];
      if (!startKeyFound) {
        if (element.template
            .contains("press('${GameKeyConfig.to.getOpenMapKey()}'")) {
          element = Operation.openMap;
          startKeyFound = true;
        } else if (element.template
            .contains("press('${GameKeyConfig.to.getOpenBookKey()}'")) {
          element = Operation.openBook;
          startKeyFound = true;
        }
      }
      if (startKeyFound) {
        script += '  ${element.toString()}\n';
      }
    }

    if (script.isNotEmpty) {
      appendText("{\n$script}\n");
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
