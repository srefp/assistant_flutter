import '../../auto_gui/keyboard.dart';
import 'js_executor.dart';

void registerKeyboardFunc() {

  // 按键
  jsRuntime.onMessage(press, pressKeyboard);

  // 按下
  jsRuntime.onMessage(kDown, keyboardDown);

  // 抬起
  jsRuntime.onMessage(kUp, keyboardUp);

}

keyboardUp(params) async {
  api.keyUp(key: params['key']);
  await Future.delayed(Duration(milliseconds: params['delay']));
}

keyboardDown(params) async {
  api.keyDown(key: params['key']);
  await Future.delayed(Duration(milliseconds: params['delay']));
}

pressKeyboard(params) async {
  api.keyDown(key: params['key']);
  api.keyUp(key: params['key']);
  await Future.delayed(Duration(milliseconds: params['delay']));
}