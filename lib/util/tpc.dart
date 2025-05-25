import 'dart:math';

import 'package:assistant/auto_gui/key_mouse_util.dart';

import '../auto_gui/keyboard.dart';
import '../config/auto_tp_config.dart';
import '../config/game_pos/game_pos_config.dart';

bool allowTpc = true;

/// 传送确认
/// tpc('anchor', [12345, 12345]);
/// tpc('domain', [12345, 12345]);
/// tpc('anchorSelect', [12345, 12345]);
/// tpc('domainSelect', [12345, 12345]);
/// tpc('slow', [12345, 12345]);
///
/// 默认XButton2会输出tpc('slow', [12345, 12345]);，执行两个延迟90ms的单击操作。
void tpc() async {
  if (!allowTpc) {
    return;
  }
  allowTpc = false;
  Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpcCooldown()))
      .then((value) => allowTpc = true);

  // 获取当前鼠标位置
  var currentPos = await api.position();

  api.click(clicks: 1);
  await Future.delayed(Duration(milliseconds: 20));
  var point = GamePosConfig.to.getConfirmPosIntList();
  var res = KeyMouseUtil.physicalPos(point);
  api.moveTo(point: Point(res[0], res[1]));
  await Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpcDelay()));
  api.click(clicks: 1);
  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getTpcRetryDelay()));
  api.click(clicks: 1);

  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getTpcBackDelay()));
  // 复位
  api.moveTo(point: currentPos!);

  // await _api.click(clicks: 2);
  // var point = AutoTpConfig.to.getConfirmPosIntList();
  // var res = KeyMouseUtil.physicalPos(point);
  // await _api.moveTo(point: Point(res[0], res[1]));
  // await _api.click(clicks: 1);
  // await _api.click(clicks: 1);
  // await Future.delayed(Duration(milliseconds: 90));
  // await _api.click(clicks: 1);

  // await KeyMouseUtil.click();
  // await KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
  // await KeyMouseUtil.click();
  // await KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
}

const anchor = 'anchor';
const domain = 'domain';
const anchorSelect = 'anchorSelect';
const domainSelect = 'domainSelect';
const slow = 'slow';

void tpcFunc(String type, List<int> coords) async {
  switch (type) {
    case anchor:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 2);
      var point = GamePosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      await api.click(clicks: 1);
    case domain:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 30));
      await api.click(clicks: 1);
      var point = GamePosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      await api.click(clicks: 1);
    case anchorSelect:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      var point = GamePosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
    case domainSelect:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 30));
      var point = GamePosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
    case slow:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      var point = GamePosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
  }
}
