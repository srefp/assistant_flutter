import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';

void halfTp() {
  KeyMouseUtil.click();
  KeyMouseUtil.clickAtPoint(RecordConfig.to.getConfirmPosition());
}
