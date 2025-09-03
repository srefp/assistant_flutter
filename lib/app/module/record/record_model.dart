import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:re_editor/re_editor.dart';

import '../../../constant/script_record_mode.dart';
import '../../../helper/auto_gui/key_mouse_util.dart';
import '../../../helper/key_mouse/event_type.dart';
import '../../../helper/key_mouse/mouse_button.dart';
import '../../../helper/key_mouse/mouse_event.dart';
import '../../../helper/record/operation.dart';
import '../../../helper/win32/key_listen.dart';
import '../../config/auto_tp_config.dart';
import '../../config/game_key_config.dart';
import '../../config/hotkey_config.dart';
import '../../config/record_config.dart';
import '../../windows_app.dart';

class RecordModel extends ChangeNotifier {
  static RecordModel instance = RecordModel();

  /// 录制开始时间
  DateTime recordCurrentTime = DateTime.now();
  CodeLineEditingController? scriptController;
  ScriptRecordMode scriptRecordMode = ScriptRecordMode.autoScript;

  void registerKeyMouseStream(
    CodeLineEditingController controller, {
    ScriptRecordMode mode = ScriptRecordMode.autoScript,
  }) {
    recordCurrentTime = DateTime.now();
    scriptController = controller;
    scriptRecordMode = mode;
  }

  void unRegisterKeyMouseStream() {
    scriptController = null;
    appendDelay(getDelay());
    output();
  }

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

  getDelay() {
    final int delay =
        DateTime.now().difference(recordCurrentTime).inMilliseconds;
    recordCurrentTime = DateTime.now();
    return delay;
  }

  record(EventType eventType, String name, bool down, List<int> coords,
      MouseEvent? mouseEvent) {
    if (scriptController == null ||
        (eventType == EventType.mouse && !mouseButtonNames.contains(name)) ||
        (eventType == EventType.keyboard && mouseButtonNames.contains(name))) {
      return;
    }

    if (scriptRecordMode == ScriptRecordMode.autoTp) {
      recordRoute(name, down, coords, mouseEvent);
    } else {
      recordScript(eventType, name, down, coords);
    }
  }

  /// 记录脚本
  void recordScript(
      EventType eventType, String name, bool down, List<int> coords) {
    appendDelay(getDelay());
    outputAsScript();

    if (name == 'left') {
      simulateMouseMove('left');
      outputAsScript();
      WindowsApp.logModel
          .append('moveR3D(${directionDistances['left']}, 10, 5);');
    } else if (name == 'up') {
      simulateMouseMove('up');
      outputAsScript();
      append('moveR3D(${directionDistances['up']}, 10, 5);');
    } else if (name == 'right') {
      simulateMouseMove('right');
      outputAsScript();
      WindowsApp.logModel
          .append('moveR3D(${directionDistances['right']}, 10, 5);');
    } else if (name == 'down') {
      simulateMouseMove('down');
      outputAsScript();
      WindowsApp.logModel
          .append('moveR3D(${directionDistances['down']}, 10, 5);');
    } else if (eventType == EventType.keyboard) {
      final func = down ? 'kDown' : 'kUp';
      appendOperation(Operation(
        func: func,
        template: "$func('$name', %s);",
      ));
    } else if (eventType == EventType.mouse) {
      final func = down ? 'mDown' : 'mUp';
      final template =
          name == leftButton ? "$func(%s);" : "$func('$name', %s);";
      appendOperation(Operation(
        func: func,
        template: template,
        coords: coords,
      ));
    }
  }

  /// 记录路线
  void recordRoute(
      String name, bool down, List<int> coords, MouseEvent? mouseEvent) {
    recordTpc(name, down);
    appendDelay(getDelay());

    if (mouseEvent != null) {
      recordMouse(mouseEvent, coords);
    }

    // 开图键录制
    if (name != GameKeyConfig.to.getOpenMapKey() &&
        name != GameKeyConfig.to.getOpenBookKey()) {
      return;
    }

    final operation = down ? 'kDown' : 'kUp';
    appendOperation(
        Operation(func: operation, template: "$operation('$name', %s);"));
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
    if (scriptRecordMode == ScriptRecordMode.autoTp) {
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
    if (scriptController == null) {
      return;
    }
    var controller = scriptController!;
    var content = controller.text;
    if (content.endsWith('\n')) {
      content = content.substring(0, content.length - 1);
    }
    if (content.trim().isEmpty) {
      controller.text = '$text';
    } else {
      controller.text = '$content\n$text';
    }

    // 设置光标位置到末尾
    controller.selection = CodeLineSelection.collapsed(
      index: controller.codeLines.length - 1,
      offset: controller.codeLines.last.length,
    );
  }

  void info(String text) {
    logController.text += "${now()} [INFO] $text\n";
    notifyListeners();
  }

  void recordTpc(String name, bool down) {
    // 获取当前鼠标位置
    List<int> coords =
        KeyMouseUtil.logicalPos(KeyMouseUtil.getMousePosOfWindow());
    if (name == HotkeyConfig.to.getHalfTp()) {
      WindowsApp.logModel.appendOperation(Operation(
          func: "tpc", template: "tpc([${coords[0]}, ${coords[1]}], 0);"));

      WindowsApp.logModel.outputAsRoute();
    }
  }

  void recordMouse(MouseEvent event, List<int> coords) {
    int delay = WindowsApp.logModel.getDelay();
    WindowsApp.logModel.appendDelay(delay);

    switch (event.type) {
      case MouseEventType.leftButtonDown:
        WindowsApp.logModel.appendOperation(Operation(
            func: 'mDown',
            coords: coords,
            template: 'mDown([${coords[0]}, ${coords[1]}], %s);',
            prevDelay: delay));
        break;
      case MouseEventType.leftButtonUp:
        WindowsApp.logModel.appendOperation(Operation(
            func: 'mUp',
            coords: coords,
            template: 'mUp([${coords[0]}, ${coords[1]}], %s);',
            prevDelay: delay));
        break;
      case MouseEventType.rightButtonDown:
        WindowsApp.logModel.appendOperation(Operation(
            func: 'mDownRight',
            coords: coords,
            template: "mDown('right', '[${coords[0]}, ${coords[1]}], %s);",
            prevDelay: delay));
        break;
      case MouseEventType.rightButtonUp:
        WindowsApp.logModel.appendOperation(Operation(
            func: 'mUpRight',
            coords: coords,
            template: "mUp('right', '[${coords[0]}, ${coords[1]}], %s);",
            prevDelay: delay));
        break;
      case MouseEventType.wheelUp:
        WindowsApp.logModel.appendOperation(Operation(
            func: 'wheel', template: "wheel(1, %s);", prevDelay: delay));
        break;
      case MouseEventType.wheelDown:
        WindowsApp.logModel.appendOperation(Operation(
            func: 'wheel', template: "wheel(-1, %s);", prevDelay: delay));
        break;
      default:
        break;
    }
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
