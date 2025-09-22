import 'dart:math';

import '../../app/config/auto_tp_config.dart';
import '../../app/config/process_pos/process_pos_config.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/operations.dart';

bool allowTpc = true;

/// 传送确认
/// tpc('anchor', [12345, 12345]);
/// tpc('domain', [12345, 12345]);
/// tpc('anchorSelect', [12345, 12345]);
/// tpc('domainSelect', [12345, 12345]);
/// tpc('slow', [12345, 12345]);
///
/// 默认XButton2会输出tpc('slow', [12345, 12345]);，执行两个延迟90ms的单击操作。
void executeTpc() async {
  if (!allowTpc) {
    return;
  }
  allowTpc = false;
  Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpcCooldown()))
      .then((value) => allowTpc = true);

  var currentPos = await api.position();

  // 1. 点击当前位置
  api.click(clicks: 1);

  await Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpcDelay()));
  var point = ProcessPosConfig.to.getConfirmPosIntList();
  var res = KeyMouseUtil.physicalPos(point);

  // 2. 移动鼠标到确认按钮
  api.moveTo(point: Point(res[0], res[1]));
  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getMoveToConfirmDelay()));

  // 3. 点击确认按钮
  api.click(clicks: 1);

  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getTpcRetryDelay()));

  // 4. 重试点击确认按钮
  api.click(clicks: 1);

  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getTpcBackDelay()));

  // 4. 复位
  api.moveTo(point: currentPos!);
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
      var point = ProcessPosConfig.to.getConfirmPosIntList();
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
      var point = ProcessPosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      await api.click(clicks: 1);
    case anchorSelect:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      var point = ProcessPosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
    case domainSelect:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 30));
      var point = ProcessPosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
    case slow:
      await api.moveTo(point: Point(coords[0], coords[1]));
      await api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      var point = ProcessPosConfig.to.getConfirmPosIntList();
      var res = KeyMouseUtil.physicalPos(point);
      await api.moveTo(point: Point(res[0], res[1]));
      await api.click(clicks: 1);
  }
}
