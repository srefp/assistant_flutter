import '../../auto_gui/key_mouse_util.dart';
import '../../auto_gui/keyboard.dart';
import '../../auto_gui/system_control.dart';
import '../../config/auto_tp_config.dart';
import '../../config/game_key_config.dart';
import '../../config/game_pos/game_pos_config.dart';
import '../data_converter.dart';
import 'js_executor.dart';

void registerConvenience() {
  // 开图
  jsRuntime.onMessage(map, openMap);

  // 开书
  jsRuntime.onMessage(book, openBook);

  // 传送确认
  jsRuntime.onMessage(tpc, tpConfirm);

  // 传送
  jsRuntime.onMessage(tp, tpByParams);
}

tpByParams(params) async {
  final script = params['params']['script'];
  if (script != null) {
    await runScript(script!);
  }
}

tpConfirm(params) async {
  SystemControl.refreshRect();
  await KeyMouseUtil.clickAtPoint(convertDynamicListToIntList(params['coords']),
      AutoTpConfig.to.getTpcDelay());
  await KeyMouseUtil.clickAtPoint(
      convertDynamicListToIntList(GamePosConfig.to.getConfirmPosIntList()),
      params['delay']);
}

openBook(params) async {
  api.keyDown(key: GameKeyConfig.to.getOpenBookKey());
  api.keyUp(key: GameKeyConfig.to.getOpenBookKey());
  await Future.delayed(Duration(milliseconds: params['delay']));
  if (!crusade) {
    crusade = true;
    await KeyMouseUtil.clickAtPoint(AutoTpConfig.to.getCrusadePosIntList(),
        AutoTpConfig.to.getCrusadeDelay());
  }
}

openMap(params) async {
  api.keyDown(key: GameKeyConfig.to.getOpenMapKey());
  api.keyUp(key: GameKeyConfig.to.getOpenMapKey());
  await Future.delayed(Duration(milliseconds: params['delay']));
}
