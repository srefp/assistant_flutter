import '../config_storage.dart';
import 'process_pos_config.dart';

class ProcessPosConfig169 extends ProcessPosConfig {
  static ProcessPosConfig169 to = ProcessPosConfig169();

  @override
  String getFoodPos() => box.read(ProcessPosConfig.keyFoodPos) ?? "29576, 2912";

  @override
  String getConfirmPos() =>
      box.read(ProcessPosConfig.keyConfirmPos) ?? "55753, 60951";
}
