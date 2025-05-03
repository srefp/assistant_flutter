import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/util/js_executor.dart';

import '../util/route_util.dart';

class RouteExecutor {
  static bool tpForbidden = false;

  static Future<void> tpNext(bool qm) async {
    if (!AutoTpConfig.to.getAutoTpEnabled()) {
      return;
    }

    if (tpForbidden) {
      return;
    }

    tpForbidden = true;

    Future.delayed(Duration(milliseconds: AutoTpConfig.to.getTpCooldown()), () {
      tpForbidden = false;
    });
  }

  static Future<void> executeStep(TpPoint tpPoint, bool qmParam) async {
    if (tpPoint.script != null) {
      await runScript(tpPoint.script!);
    }
  }
}
