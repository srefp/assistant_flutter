import '../../app/config/auto_tp_config.dart';
import '../../app/config/process_key_config.dart';
import '../../app/config/process_pos/process_pos_config.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/operations.dart';
import '../auto_gui/system_control.dart';
import '../data_converter.dart';
import 'js_executor.dart';

void registerConvenience() {
  // 开图
  jsRuntime.onMessage(map, openMap);

  // 开书
  jsRuntime.onMessage(book, openBook);

  // 传送确认
  jsRuntime.onMessage(tpc, tpConfirm);

  // 包传送的传送确认
  jsRuntime.onMessage(tpcPlus, tpConfirmPlus);

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
  if (params.length == 2) {
    await KeyMouseUtil.clickAtPoint(
        convertDynamicListToIntList(params[0]), AutoTpConfig.to.getTpcDelay());
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getConfirmPosIntList(), params[1]);
  } else if (params.length == 3) {
    await KeyMouseUtil.clickAtPoint(
        convertDynamicListToIntList(params[0]), params[1]);
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getConfirmPosIntList(), params[2]);
  }
}

// 包传送的传送确认
tpConfirmPlus(params) async {
  SystemControl.refreshRect();

  final pos = convertDynamicListToIntList(params[0]);
  if (params.length == 2) {
    // 直接传
    await KeyMouseUtil.clickAtPoint(
        pos, AutoTpConfig.to.getTpcPlusFirstDelay());
    await KeyMouseUtil.clickAtPoint(ProcessPosConfig.to.getConfirmPosIntList(),
        AutoTpConfig.to.getTpcPlusSecondDelay());

    // 二选一
    await KeyMouseUtil.clickAtPoint(
        pos, AutoTpConfig.to.getTpcPlusThirdDelay());
    await KeyMouseUtil.clickAtPoint(ProcessPosConfig.to.getSelectPosIntList(),
        AutoTpConfig.to.getTpcPlusFourthDelay());
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getConfirmPosIntList(), params[1]);
  } else if (params.length == 3) {
    // 直接传
    await KeyMouseUtil.clickAtPoint(pos, params[1]);
    await KeyMouseUtil.clickAtPoint(ProcessPosConfig.to.getConfirmPosIntList(),
        AutoTpConfig.to.getTpcPlusSecondDelay());

    // 二选一
    await KeyMouseUtil.clickAtPoint(
        pos, AutoTpConfig.to.getTpcPlusThirdDelay());
    await KeyMouseUtil.clickAtPoint(ProcessPosConfig.to.getSelectPosIntList(),
        AutoTpConfig.to.getTpcPlusFourthDelay());
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getConfirmPosIntList(), params[2]);
  } else if (params.length == 6) {
    // 直接传
    await KeyMouseUtil.clickAtPoint(pos, params[1]);
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getConfirmPosIntList(), params[2]);

    // 二选一
    await KeyMouseUtil.clickAtPoint(pos, params[3]);
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getSelectPosIntList(), params[4]);
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getConfirmPosIntList(), params[5]);
  }
}

openBook(params) async {
  api.keyDown(key: ProcessKeyConfig.to.getOpenBookKey());
  api.keyUp(key: ProcessKeyConfig.to.getOpenBookKey());
  await Future.delayed(Duration(milliseconds: params['delay']));
  if (!crusade) {
    crusade = true;
    await KeyMouseUtil.clickAtPoint(AutoTpConfig.to.getCrusadePosIntList(),
        AutoTpConfig.to.getCrusadeDelay());
  }
}

openMap(params) async {
  api.keyDown(key: ProcessKeyConfig.to.getOpenMapKey());
  api.keyUp(key: ProcessKeyConfig.to.getOpenMapKey());
  await Future.delayed(Duration(milliseconds: params['delay']));
}
