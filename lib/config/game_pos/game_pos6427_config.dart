import 'package:assistant/config/game_pos/game_pos_config.dart';

class GamePosConfig6427 extends GamePosConfig {
  static GamePosConfig6427 to = GamePosConfig6427();

  @override
  String getFoodPos() => box.read(GamePosConfig.keyFoodPos) ?? "30193, 2915";

  @override
  String getConfirmPos() => box.read(GamePosConfig.keyConfirmPos) ?? "52909, 60858";

}
