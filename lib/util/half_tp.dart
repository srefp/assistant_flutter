import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';

void halfTp() async {
  KeyMouseUtil.click();
  await Future.delayed(Duration(milliseconds: RecordConfig.to.getHalfTpDelay()));
  KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
}
