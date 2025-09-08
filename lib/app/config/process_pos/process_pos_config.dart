import '../../../constant/ratio.dart';
import '../../../helper/auto_gui/system_control.dart';
import '../../../helper/route_util.dart';
import '../config_storage.dart';
import 'process_pos1610_config.dart';
import 'process_pos169_config.dart';
import 'process_pos4318_config.dart';
import 'process_pos6427_config.dart';

abstract class ProcessPosConfig with ConfigStorage {
  static ProcessPosConfig get to {
    if (SystemControl.ratio == Ratio.r169) {
      return ProcessPosConfig169.to;
    } else if (SystemControl.ratio == Ratio.r1610) {
      return ProcessPosConfig1610.to;
    } else if (SystemControl.ratio == Ratio.r4318) {
      return ProcessPosConfig4318.to;
    } else if (SystemControl.ratio == Ratio.r6427) {
      return ProcessPosConfig6427.to;
    }
    return ProcessPosConfig169();
  }

  static String keyFoodPos = "foodPos${SystemControl.ratio.name}";
  static String keyConfirmPos = "confirmPos${SystemControl.ratio.name}";
  static String keySelectPos = "selectPos${SystemControl.ratio.name}";

  String getFoodPos();

  String getConfirmPos();

  String getSelectPos();

  List<int> getConfirmPosIntList() =>
      RouteUtil.stringToIntList(getConfirmPos());

  List<int> getFoodPosIntList() => RouteUtil.stringToIntList(getFoodPos());

  List<int> getSelectPosIntList() => RouteUtil.stringToIntList(getSelectPos());
}
