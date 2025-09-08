import '../config_storage.dart';
import 'process_pos_config.dart';

class ProcessPosConfig1610 extends ProcessPosConfig {
  static ProcessPosConfig1610 to = ProcessPosConfig1610();

  @override
  String getFoodPos() => box.read(ProcessPosConfig.keyFoodPos) ?? "29476, 2786";

  @override
  String getConfirmPos() =>
      box.read(ProcessPosConfig.keyConfirmPos) ?? "51347, 61395";

  @override
  String getSelectPos() =>
      box.read(ProcessPosConfig.keySelectPos) ?? "51347, 61395";
}
