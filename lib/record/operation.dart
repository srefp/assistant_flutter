import '../config/auto_tp_config.dart';
import '../config/game_pos/game_pos_config.dart';

/// 键鼠操作
class Operation {
  final String func;
  List<int> coords;
  String template;
  int prevDelay;

  static Operation confirm = Operation(
      func: "click",
      coords: GamePosConfig.to.getConfirmPosIntList(),
      template:
      "click(${GamePosConfig.to.getConfirmPos()[0]}, ${GamePosConfig.to.getConfirmPos()[1]}, %s);",
      prevDelay: AutoTpConfig.to.getClickRecordDelay());

  static Operation openMap = Operation(
      func: "map",
      coords: [],
      template: "map(%s);",
      prevDelay: AutoTpConfig.to.getMapRecordDelay());

  static Operation openBook = Operation(
    func: "book",
    template: "book(%s);",
    prevDelay: AutoTpConfig.to.getBookRecordDelay(),
  );

  static Operation mDown = Operation(
    func: "mDown",
    coords: [],
    template: "mDown(%s);",
    prevDelay: AutoTpConfig.to.getClickRecordDelay(),
  );

  Operation({
    required this.func,
    this.coords = const [0, 0],
    required this.template,
    this.prevDelay = 0,
  });

  @override
  String toString() {
    return template.replaceFirst('%s', prevDelay.toString());
  }
}