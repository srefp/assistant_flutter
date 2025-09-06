import '../config_storage.dart';
import 'process_pos_config.dart';

class ProcessPosConfig6427 extends ProcessPosConfig {
  static ProcessPosConfig6427 to = ProcessPosConfig6427();

  @override
  String getFoodPos() => box.read(ProcessPosConfig.keyFoodPos) ?? "30193, 2915";

  @override
  String getConfirmPos() =>
      box.read(ProcessPosConfig.keyConfirmPos) ?? "52909, 60858";
}
