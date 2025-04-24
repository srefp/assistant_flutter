import 'dart:math';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';
import 'package:flutter_auto_gui_windows/flutter_auto_gui_windows.dart';

final _api = FlutterAutoGuiWindows();

void halfTp() async {
  await _api.click(clicks: 2);
  var point = RecordConfig.to.getConfirmPosition();
  var res = KeyMouseUtil.physicalPos(point);
  await _api.moveTo(point: Point(res[0], res[1]));
  await _api.click(clicks: 1);
  await _api.click(clicks: 1);
  await Future.delayed(Duration(milliseconds: 90));
  await _api.click(clicks: 1);

  // await KeyMouseUtil.click();
  // await KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
  // await KeyMouseUtil.click();
  // await KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
}
