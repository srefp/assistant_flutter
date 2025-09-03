import '../../../constant/ratio.dart';
import '../../../helper/auto_gui/system_control.dart';
import '../../../helper/route_util.dart';
import '../config_storage.dart';
import 'game_pos1610_config.dart';
import 'game_pos169_config.dart';
import 'game_pos4318_config.dart';
import 'game_pos6427_config.dart';

abstract class GamePosConfig with ConfigStorage {
  static GamePosConfig get to {
    if (SystemControl.ratio == Ratio.r169) {
      return GamePosConfig169.to;
    } else if (SystemControl.ratio == Ratio.r1610) {
      return GamePosConfig1610.to;
    } else if (SystemControl.ratio == Ratio.r4318) {
      return GamePosConfig4318.to;
    } else if (SystemControl.ratio == Ratio.r6427) {
      return GamePosConfig6427.to;
    }
    return GamePosConfig169();
  }

  static String keyFoodPos = "foodPos${SystemControl.ratio.name}";

  static String keyConfirmPos = "confirmPos${SystemControl.ratio.name}";

  String getFoodPos();

  String getConfirmPos();

  List<int> getConfirmPosIntList() =>
      RouteUtil.stringToIntList(getConfirmPos());

  List<int> getFoodPosIntList() => RouteUtil.stringToIntList(getFoodPos());
}
