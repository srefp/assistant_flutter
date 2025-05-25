import 'package:assistant/config/game_pos/game_pos_config.dart';

class GamePosConfig1610 extends GamePosConfig {
  static GamePosConfig1610 to = GamePosConfig1610();

  @override
  String getFoodPos() => box.read(GamePosConfig.keyFoodPos) ?? "30531, 11104";

  @override
  String getConfirmPos() => box.read(GamePosConfig.keyConfirmPos) ?? "44901, 54733";

}
