import '../config_storage.dart';
import 'game_pos_config.dart';

class GamePosConfig1610 extends GamePosConfig {
  static GamePosConfig1610 to = GamePosConfig1610();

  @override
  String getFoodPos() => box.read(GamePosConfig.keyFoodPos) ?? "29476, 2786";

  @override
  String getConfirmPos() =>
      box.read(GamePosConfig.keyConfirmPos) ?? "51347, 61395";
}
