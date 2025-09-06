import '../config_storage.dart';
import 'process_pos_config.dart';

class ProcessPosConfig4318 extends ProcessPosConfig {
  static ProcessPosConfig4318 to = ProcessPosConfig4318();

  @override
  String getFoodPos() => box.read(ProcessPosConfig.keyFoodPos) ?? "30318, 2823";

  @override
  String getConfirmPos() =>
      box.read(ProcessPosConfig.keyConfirmPos) ?? "53072, 60889";
}
