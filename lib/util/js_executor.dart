import 'dart:math';

import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/game_key_config.dart';
import 'package:assistant/util/script_parser.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auto_gui/flutter_auto_gui.dart';
import 'package:flutter_js/flutter_js.dart';

import '../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/keyboard.dart';
import '../config/game_pos/game_pos_config.dart';
import '../win32/toast.dart';
import 'data_converter.dart';

const tp = "tp";
const tip = "tip";
const wait = "wait";
const move = "move";
const moveR = "moveR";
const moveR3D = "moveR3D";
const drag = "drag";
const mDown = "mDown";
const mUp = "mUp";
const click = "click";
const kDown = "kDown";
const kUp = "kUp";
const press = "press";
const cp = "cp";
const wheel = "wheel";
const map = "map";
const book = "book";
const tpc = "tpc";

const keys = [
  tp,
  wait,
  move,
  moveR,
  moveR3D,
  drag,
  mDown,
  mUp,
  click,
  kDown,
  kUp,
  press,
  cp,
  wheel,
  map,
  book,
  tpc,
];

final JavascriptRuntime jsRuntime = getJavascriptRuntime();

late String jsFunction;

bool crusade = false;

void registerJsFunc() async {
  jsFunction = await rootBundle.loadString('assets/js/func.js');
  jsFunction = zipJsCode(jsFunction);

  // 注册所有函数
  jsRuntime.evaluate(jsFunction);

  // 打印日志
  jsRuntime.onMessage('log', (params) {
    WindowsApp.logModel.info(params['info']);
  });

  // 弹出消息框
  jsRuntime.onMessage(tip, (params) async {
    if (params['duration'] == null) {
      params['duration'] = 3000;
    }
    showToast(params['message'], duration: params['duration']);
  });

  // 鼠标移动
  jsRuntime.onMessage(move, (params) async {
    if (params.length == 2) {
      await KeyMouseUtil.move(params[0], 1, 0);
    } else if (params.length == 4) {
      await KeyMouseUtil.move(params[0], params[1], params[2]);
    }
    await Future.delayed(Duration(milliseconds: params[3]));
  });

  // 滚轮
  jsRuntime.onMessage(wheel, (params) async {
    await api.scroll(clicks: -params['clicks']);
    await Future.delayed(Duration(milliseconds: params['delay']));
  });

  // 鼠标按下
  jsRuntime.onMessage(mDown, (params) async {
    await api.mouseDown();
    await Future.delayed(Duration(milliseconds: params[0]));
  });

  // 鼠标抬起
  jsRuntime.onMessage(mUp, (params) async {
    await api.mouseUp();
    await Future.delayed(Duration(milliseconds: params[0]));
  });

  // 点击
  jsRuntime.onMessage(click, (params) async {
    SystemControl.refreshRect();
    if (params[0] == null) {
      await api.click();
    } else if (params[0] is int) {
      await api.click();
      await Future.delayed(Duration(milliseconds: params[0]));
    } else if (params[0] is List && params[1] is int) {
      await KeyMouseUtil.clickAtPoint(
          convertDynamicListToIntList(params[0]), params[1]);
    } else if (params[0] is String && params[1] is int) {
      await api.click(
        button: {
          'left': MouseButton.left,
          'right': MouseButton.right,
          'middle': MouseButton.middle,
        }[params[0]]!,
      );
      await Future.delayed(Duration(milliseconds: params[1]));
    } else if (params[0] is String &&
        params[1] is List &&
        params[2] is int) {
      var res = KeyMouseUtil.physicalPos(params[1]);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(
        button: {
          'left': MouseButton.left,
          'right': MouseButton.right,
          'middle': MouseButton.middle,
        }[params[0]]!,
      );
      await Future.delayed(Duration(milliseconds: params[2]));
    }
  });

  // 按键
  jsRuntime.onMessage(press, (params) async {
    api.keyDown(key: params['key']);
    api.keyUp(key: params['key']);
    await Future.delayed(Duration(milliseconds: params['delay']));
  });

  // 按下
  jsRuntime.onMessage(kDown, (params) async {
    api.keyDown(key: params['key']);
    await Future.delayed(Duration(milliseconds: params['delay']));
  });

  // 抬起
  jsRuntime.onMessage(kUp, (params) async {
    api.keyUp(key: params['key']);
    await Future.delayed(Duration(milliseconds: params['delay']));
  });

  // 等待
  jsRuntime.onMessage(wait, (param) async {
    await Future.delayed(Duration(milliseconds: param));
  });

  // 开图
  jsRuntime.onMessage(map, (params) async {
    api.keyDown(key: GameKeyConfig.to.getOpenMapKey());
    api.keyUp(key: GameKeyConfig.to.getOpenMapKey());
    await Future.delayed(Duration(milliseconds: params['delay']));
  });

  // 开书
  jsRuntime.onMessage(book, (params) async {
    api.keyDown(key: GameKeyConfig.to.getOpenBookKey());
    api.keyUp(key: GameKeyConfig.to.getOpenBookKey());
    await Future.delayed(Duration(milliseconds: params['delay']));
    if (!crusade) {
      crusade = true;
      await KeyMouseUtil.clickAtPoint(AutoTpConfig.to.getCrusadePosIntList(),
          AutoTpConfig.to.getCrusadeDelay());
    }
  });

  // 传送确认
  jsRuntime.onMessage(tpc, (params) async {
    SystemControl.refreshRect();
    await KeyMouseUtil.clickAtPoint(
        convertDynamicListToIntList(params['coords']),
        AutoTpConfig.to.getTpcDelay());
    await KeyMouseUtil.clickAtPoint(
        convertDynamicListToIntList(GamePosConfig.to.getConfirmPosIntList()),
        params['delay']);
  });

  // 传送
  jsRuntime.onMessage(tp, (params) async {
    var script = params['params']['script'];
    if (script != null) {
      await runScript(script!);
    }
  });

  // 拖动
  jsRuntime.onMessage(drag, (params) async {
    SystemControl.refreshRect();
    await KeyMouseUtil.fastDrag(
        convertDynamicListToIntList(params['coords']), params['shortMove']);
    await Future.delayed(Duration(milliseconds: params['delay']));
  });
}

/// 运行js代码
Future<void> runScript(
  String code, {
  bool addAwait = true,
  bool stoppable = false,
}) async {
  // 将code中的异步函数添加await
  if (addAwait) {
    for (var key in keys) {
      if (stoppable) {
        code = code.replaceAll('$key(',
            'if (!scriptRunning) { scriptRunning = true; return;} await $key(');
      } else {
        code = code.replaceAll('$key(', 'await $key(');
      }
    }
  }

  try {
    JsEvalResult result = await jsRuntime.evaluateAsync(
        '${stoppable ? 'scriptRunning = true;' : ''}(async function() { $code })();');
    jsRuntime.executePendingJob();
    await jsRuntime.handlePromise(result);
  } catch (e) {
    print(e);
  }
}
