import 'dart:math';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';
import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';

final _api = FlutterAutoGuiWindows();

/// 传送确认
/// tpc('anchor', [12345, 12345]);
/// tpc('domain', [12345, 12345]);
/// tpc('anchorSelect', [12345, 12345]);
/// tpc('domainSelect', [12345, 12345]);
/// tpc('slow', [12345, 12345]);
///
/// 默认XButton2会输出tpc('slow', [12345, 12345]);，执行两个延迟90ms的单击操作。
void tpc() async {
  await _api.click(clicks: 1);
  var point = RecordConfig.to.getConfirmPosition();
  var res = KeyMouseUtil.physicalPos(point);
  await _api.moveTo(point: Point(res[0], res[1]));
  await Future.delayed(Duration(milliseconds: 10));
  await _api.click(clicks: 1);

  // await _api.click(clicks: 2);
  // var point = RecordConfig.to.getConfirmPosition();
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
      await _api.moveTo(point: Point(coords[0], coords[1]));
      await _api.click(clicks: 2);
      var point = RecordConfig.to.getConfirmPosition();
      var res = KeyMouseUtil.physicalPos(point);
      await _api.moveTo(point: Point(res[0], res[1]));
      await _api.click(clicks: 1);
      await _api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      await _api.click(clicks: 1);
    case domain:
      await _api.moveTo(point: Point(coords[0], coords[1]));
      await _api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 30));
      await _api.click(clicks: 1);
      var point = RecordConfig.to.getConfirmPosition();
      var res = KeyMouseUtil.physicalPos(point);
      await _api.moveTo(point: Point(res[0], res[1]));
      await _api.click(clicks: 1);
      await _api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      await _api.click(clicks: 1);
    case anchorSelect:
      await _api.moveTo(point: Point(coords[0], coords[1]));
      await _api.click(clicks: 1);
      var point = RecordConfig.to.getConfirmPosition();
      var res = KeyMouseUtil.physicalPos(point);
      await _api.moveTo(point: Point(res[0], res[1]));
      await _api.click(clicks: 1);
    case domainSelect:
      await _api.moveTo(point: Point(coords[0], coords[1]));
      await _api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 30));
      var point = RecordConfig.to.getConfirmPosition();
      var res = KeyMouseUtil.physicalPos(point);
      await _api.moveTo(point: Point(res[0], res[1]));
      await _api.click(clicks: 1);
    case slow:
      await _api.moveTo(point: Point(coords[0], coords[1]));
      await _api.click(clicks: 1);
      await Future.delayed(Duration(milliseconds: 90));
      var point = RecordConfig.to.getConfirmPosition();
      var res = KeyMouseUtil.physicalPos(point);
      await _api.moveTo(point: Point(res[0], res[1]));
      await _api.click(clicks: 1);
  }
}
