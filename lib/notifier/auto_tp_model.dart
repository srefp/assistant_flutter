import 'package:fluent_ui/fluent_ui.dart';

import '../components/delay_config_row.dart';
import '../config/auto_tp_config.dart';
import '../manager/screen_manager.dart';
import '../model/tp_point.dart';
import '../util/search_utils.dart';
import '../win32/key_listen.dart';
import '../win32/mouse_listen.dart';
import '../win32/window.dart';

final delayConfigItems = [
  DelayConfigItem(
    title: '半自动传送冷却',
    subTitle: '',
    valueKey: AutoTpConfig.keyTpcCooldown,
    valueCallback: AutoTpConfig.to.getTpcCooldown,
  ),
  DelayConfigItem(
    title: '半自动传送延迟',
    subTitle: '半自动传送时，点击锚点后，需要等待的毫秒数',
    valueKey: AutoTpConfig.keyTpcDelay,
    valueCallback: AutoTpConfig.to.getTpcDelay,
  ),
  DelayConfigItem(
    title: '半自动传送鼠标重试延迟',
    subTitle: '半自动传送时，副本锚点响应慢，需要等待一定的毫秒后，再次重试点击确认按钮',
    valueKey: AutoTpConfig.keyTpcRetryDelay,
    valueCallback: AutoTpConfig.to.getTpcBackDelay,
  ),
  DelayConfigItem(
    title: '半自动传送鼠标归位延迟',
    subTitle: '半自动传送时，点击确认按钮后，归位需要等待的毫秒数',
    valueKey: AutoTpConfig.keyTpcBackDelay,
    valueCallback: AutoTpConfig.to.getTpcBackDelay,
  ),
  DelayConfigItem(
    title: '关闭开书后Boss抽屉的延迟',
    subTitle: '开书后Boss抽屉关不上，需要手动关闭',
    valueKey: AutoTpConfig.keyBossDrawerDelay,
    valueCallback: AutoTpConfig.to.getBossDrawerDelay,
  ),
  DelayConfigItem(
    title: '自动传送冷却时间',
    subTitle: '点击完传送按钮后经过冷却时间才可以再次点击传送',
    valueKey: AutoTpConfig.keyTpCooldown,
    valueCallback: AutoTpConfig.to.getTpCooldown,
  ),
];

class AutoTpModel extends ChangeNotifier {
  String? selectedDir;
  String? selectedFile;
  int currentRouteIndex = 0;
  List<TpPoint> tpPoints = [];
  bool isRunning = false;

  var displayedDelayConfigItems = delayConfigItems;
  var lightText = '';

  void searchDisplayedDelayConfigItems(String searchValue) {
    lightText = searchValue;
    if (searchValue.isEmpty) {
      displayedDelayConfigItems = delayConfigItems;
      notifyListeners();
      return;
    }
    displayedDelayConfigItems = delayConfigItems
        .where((item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    notifyListeners();
  }

  void setSelectedDir(String dir) {
    selectedDir = dir;
    notifyListeners();
  }

  void setSelectedFile(String file) {
    selectedFile = file;
    notifyListeners();
  }

  void setCurrentRouteIndex(int index) {
    currentRouteIndex = index;
    notifyListeners();
  }

  void start() {
    isRunning = true;
    startKeyboardHook();
    startMouseHook();
    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;
    if (hWnd != null) {
      setForegroundWindow(hWnd);
    }

    notifyListeners();
  }

  void stop() {
    isRunning = false;
    stopKeyboardHook();
    stopMouseHook();

    notifyListeners();
  }
}
