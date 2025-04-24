import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';

void halfTp() async {
  await KeyMouseUtil.click();
  await KeyMouseUtil.click();
  await Future.delayed(Duration(milliseconds: 10));
  await KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
  await KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
}
