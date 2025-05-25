import 'package:assistant/config/game_pos/game_pos_config.dart';

class GamePosConfig4318 extends GamePosConfig {
  static GamePosConfig4318 to = GamePosConfig4318();

  @override
  String getFoodPos() => box.read(GamePosConfig.keyFoodPos) ?? "30318, 2823";

  @override
  String getConfirmPos() => box.read(GamePosConfig.keyConfirmPos) ?? "53072, 60889";

}
