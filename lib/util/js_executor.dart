import 'dart:io';

import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/components/dialog.dart';
import 'package:assistant/components/win_text.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/game_key_config.dart';
import 'package:assistant/cv/cv.dart';
import 'package:assistant/db/pic_record_db.dart';
import 'package:assistant/util/find_util.dart';
import 'package:assistant/util/script_parser.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auto_gui/flutter_auto_gui.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:win32/win32.dart';

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
const findColor = "findColor";
const findPic = "findPic";
const sh = "sh";
const maxCurrentWindow = "maxCurrentWindow";

const hintKeys = [
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
  findColor,
  findPic,
  sh,
  maxCurrentWindow,
];

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

JavascriptRuntime jsRuntime = getJavascriptRuntime(xhr: false);

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

  // 鼠标相对移动
  jsRuntime.onMessage(moveR, (params) async {
    if (params.length == 2) {
      await KeyMouseUtil.moveR(params[0], 1, 0);
    } else if (params.length == 4) {
      await KeyMouseUtil.moveR(params[0], params[1], params[2]);
    }
    await Future.delayed(Duration(milliseconds: params[3]));
  });

  // 3D视角的鼠标相对移动
  jsRuntime.onMessage(moveR3D, (params) async {
    List<int> distance = convertDynamicListToIntList(params[0]);
    if (params.length == 2) {
      await KeyMouseUtil.moveR3D(distance, 1, 0);
      await Future.delayed(Duration(milliseconds: params[1]));
    } else if (params.length == 4) {
      await KeyMouseUtil.moveR3D(distance, params[1], params[2]);
      await Future.delayed(Duration(milliseconds: params[3]));
    }
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

    // 最少参数：click(10)
    if (params.length == 1) {
      await api.click();
      await Future.delayed(Duration(milliseconds: params[0]));
      return;
    }

    // 最多参数：click('left', [12345, 12345], 4, 5, 20)
    if (params.length == 5) {
      await KeyMouseUtil.move(convertDynamicListToIntList(params[1]), 1, 0);
      await Future.delayed(Duration(milliseconds: 2));
      await api.click(
        button: {
          'left': MouseButton.left,
          'right': MouseButton.right,
          'middle': MouseButton.middle,
        }[params[0]]!,
        clicks: params[2],
        interval: Duration(milliseconds: params[3]),
      );
      await Future.delayed(Duration(milliseconds: params[4]));
      return;
    }

    // 三选一：坐标
    if (params.length == 2 && params[0] is List && params[1] is int) {
      await KeyMouseUtil.clickAtPoint(
          convertDynamicListToIntList(params[0]), params[1]);
    }
    // 三选二：坐标+次数
    else if (params.length == 4 &&
        params[0] is List &&
        params[1] is int &&
        params[2] is int &&
        params[3] is int) {
      await KeyMouseUtil.move(convertDynamicListToIntList(params[0]), 1, 0);
      await Future.delayed(Duration(milliseconds: 2));
      await api.click(
        clicks: params[1],
        interval: Duration(milliseconds: params[2]),
      );
      await Future.delayed(Duration(milliseconds: params[3]));
    }

    // 三选一：键位
    else if (params[0] is String && params[1] is int) {
      await api.click(
        button: {
          'left': MouseButton.left,
          'right': MouseButton.right,
          'middle': MouseButton.middle,
        }[params[0]]!,
      );
      await Future.delayed(Duration(milliseconds: params[1]));
    }
    // 三选一：次数
    else if (params[0] is int && params[1] is int && params[2] is int) {
      await api.click(
        clicks: params[0],
        interval: Duration(milliseconds: params[1]),
      );
      await Future.delayed(Duration(milliseconds: params[2]));
    }

    // 三选二：键位+坐标
    else if (params[0] is String && params[1] is List && params[2] is int) {
      await KeyMouseUtil.move(convertDynamicListToIntList(params[1]), 1, 0);
      await api.click(
        button: {
          'left': MouseButton.left,
          'right': MouseButton.right,
          'middle': MouseButton.middle,
        }[params[0]]!,
      );
      await Future.delayed(Duration(milliseconds: params[2]));
    }
    // 三选二：键位+次数
    else if (params[0] is String &&
        params[1] is int &&
        params[2] is int &&
        params[3] is int) {
      await api.click(
        button: {
          'left': MouseButton.left,
          'right': MouseButton.right,
          'middle': MouseButton.middle,
        }[params[0]]!,
        clicks: params[1],
        interval: Duration(milliseconds: params[2]),
      );
      await Future.delayed(Duration(milliseconds: params[3]));
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
    final script = params['params']['script'];
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

  // 复制粘贴
  jsRuntime.onMessage(cp, (params) async {
    await Clipboard.setData(ClipboardData(text: params['text']));
    await api.keyDown(key: 'ctrl');
    await api.keyDown(key: 'v');
    await api.keyUp(key: 'v');
    await api.keyUp(key: 'ctrl');
  });

  // 找色
  jsRuntime.onMessage(findColor, (params) async {
    final res = await FindUtil.findColor(
        convertDynamicListToIntList(params[0]), params[1]);
    return res;
  });

  // 找图
  jsRuntime.onMessage(findPic, (params) async {
    final left = params[0][0];
    final top = params[0][1];
    final right = params[0][2];
    final bottom = params[0][3];
    final image = captureImageWindows(ScreenRect(left, top, right, bottom));
    final template = picRecordMap[params[1]]?.mat;
    if (template == null) {
      return {'match': -1, 'loc': cv.Point(0, 0)};
    }
    final result = cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);
    final minMaxLoc = cv.minMaxLoc(result);
    return {'match': minMaxLoc.$1, 'loc': minMaxLoc.$3};
  });

  // 执行shell脚本
  jsRuntime.onMessage(sh, (parameters) async {
    final params = <String>[];
    for (var i = 0; i < parameters.length; i++) {
      params.add(parameters[i].toString());
    }
    Process? process;
    try {
      process = await Process.start(
        params[0],
        params.sublist(1),
        mode: ProcessStartMode.detached,
        environment: Platform.environment,
      );
    } catch (e) {
      dialog(
        title: '错误',
        child: SizedBox(
          height: 200,
          child: ListView(
            children: [
              WinText(e.toString()),
            ],
          ),
        ),
      );
    }
    return process?.pid;
  });

  // 当前窗口最大化
  jsRuntime.onMessage(maxCurrentWindow, (params) async {
    // 获取当前前台窗口句柄
    final hWnd = GetForegroundWindow();
    if (hWnd == 0) return; // 无前台窗口时返回

    // 调用Win32 API最大化窗口（SW_MAXIMIZE=3）
    ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_MAXIMIZE);
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
    for (final key in keys) {
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
    dialog(
        title: '脚本执行出错',
        child: SizedBox(
          height: 120,
          child: ListView(
            children: [
              WinText(e.toString()),
            ],
          ),
        ));
    jsRuntime.dispose();
    registerJsFunc();
  }
}
