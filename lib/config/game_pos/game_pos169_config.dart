import 'package:assistant/config/game_pos/game_pos_config.dart';

import '../config_storage.dart';

class GamePosConfig169 extends GamePosConfig {
  static GamePosConfig169 to = GamePosConfig169();

  @override
  String getFoodPos() => box.read(GamePosConfig.keyFoodPos) ?? "29576, 2912";

  @override
  String getConfirmPos() => box.read(GamePosConfig.keyConfirmPos) ?? "55753, 60951";

}
