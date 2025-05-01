import 'package:assistant/components/dialog.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../components/coords_config_row.dart';
import '../components/delay_config_row.dart';
import '../config/auto_tp_config.dart';
import '../manager/screen_manager.dart';
import '../model/tp_point.dart';
import '../util/search_utils.dart';
import '../win32/game_listen.dart';
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
    title: '自动传送冷却时间',
    subTitle: '点击完传送按钮后经过冷却时间才可以再次点击传送',
    valueKey: AutoTpConfig.keyTpCooldown,
    valueCallback: AutoTpConfig.to.getTpCooldown,
  ),
  DelayConfigItem(
    title: '关闭开书后Boss抽屉的延迟',
    subTitle: '开书后Boss抽屉关不上，需要手动关闭',
    valueKey: AutoTpConfig.keyBossDrawerDelay,
    valueCallback: AutoTpConfig.to.getBossDrawerDelay,
  ),
  DelayConfigItem(
    title: '吃药冷却时间',
    subTitle: '完成整个吃药流程后需要经过冷却时间才可以再次吃药',
    valueKey: AutoTpConfig.keyFoodCooldown,
    valueCallback: AutoTpConfig.to.getFoodCooldown,
  ),
  DelayConfigItem(
    title: 'qm冲刺',
    subTitle: 'qm冲刺时间',
    valueKey: AutoTpConfig.keyQmDashDelay,
    valueCallback: AutoTpConfig.to.getQmDashDelay,
  ),
  DelayConfigItem(
    title: 'qm大招',
    subTitle: 'qm时放出大招后需要等待的时间',
    valueKey: AutoTpConfig.keyQmQDelay,
    valueCallback: AutoTpConfig.to.getQmQDelay,
  ),
  DelayConfigItem(
    title: '选区',
    subTitle: '选区延迟',
    valueKey: AutoTpConfig.keySelectAreaDelay,
    valueCallback: AutoTpConfig.to.getSelectAreaDelay,
  ),
  DelayConfigItem(
    title: '单击',
    subTitle: '单击延迟',
    valueKey: AutoTpConfig.keyClickDelay,
    valueCallback: AutoTpConfig.to.getClickDelay,
  ),
  DelayConfigItem(
    title: '单击食物',
    subTitle: '单击食物的延迟',
    valueKey: AutoTpConfig.keyClickFoodDelay,
    valueCallback: AutoTpConfig.to.getClickFoodDelay,
  ),
  DelayConfigItem(
    title: '确认吃食物',
    subTitle: '确认吃食物的延迟',
    valueKey: AutoTpConfig.keyEatFoodDelay,
    valueCallback: AutoTpConfig.to.getEatFoodDelay,
  ),
  DelayConfigItem(
    title: '开地图',
    subTitle: '直接开地图等待的时间',
    valueKey: AutoTpConfig.keyOpenMapDelay,
    valueCallback: AutoTpConfig.to.getOpenMapDelay,
  ),
  DelayConfigItem(
    title: '切换区域',
    subTitle: '切换区域的等待时间',
    valueKey: AutoTpConfig.keySwitchAreaDelay,
    valueCallback: AutoTpConfig.to.getSwitchAreaDelay,
  ),
  DelayConfigItem(
    title: '开书',
    subTitle: '开书延迟',
    valueKey: AutoTpConfig.keyOpenBookDelay,
    valueCallback: AutoTpConfig.to.getOpenBookDelay,
  ),
  DelayConfigItem(
    title: '开书后追踪Boss开地图',
    subTitle: '点击追踪按钮后，需要等待开地图的时间',
    valueKey: AutoTpConfig.keyBookOpenMapDelay,
    valueCallback: AutoTpConfig.to.getBookOpenMapDelay,
  ),
  DelayConfigItem(
    title: '快捡',
    subTitle: '快捡等待时间',
    valueKey: AutoTpConfig.keyPickDelay,
    valueCallback: AutoTpConfig.to.getPickDelay,
  ),
  DelayConfigItem(
    title: '讨伐',
    subTitle: '讨伐等待时间',
    valueKey: AutoTpConfig.keyCrusadeDelay,
    valueCallback: AutoTpConfig.to.getCrusadeDelay,
  ),
  DelayConfigItem(
    title: '清空滚动条',
    subTitle: '清空滚动条需要长按，长按的时间',
    valueKey: AutoTpConfig.keyLongPressDelay,
    valueCallback: AutoTpConfig.to.getLongPressDelay,
  ),
  DelayConfigItem(
    title: '滚轮',
    subTitle: '滚轮滚动间隔时间',
    valueKey: AutoTpConfig.keyWheelIntervalDelay,
    valueCallback: AutoTpConfig.to.getWheelIntervalDelay,
  ),
  DelayConfigItem(
    title: '滚轮完成',
    subTitle: '滚轮完成后需要等待的时间',
    valueKey: AutoTpConfig.keyWheelCompleteDelay,
    valueCallback: AutoTpConfig.to.getWheelCompleteDelay,
  ),
  DelayConfigItem(
    title: '锚点多选',
    subTitle: '锚点多选等待时间',
    valueKey: AutoTpConfig.keyMultiSelectDelay,
    valueCallback: AutoTpConfig.to.getMultiSelectDelay,
  ),
];

final coordsConfigItems = [
  CoordsConfigItem(
    title: '讨伐',
    subTitle: '讨伐按钮的位置',
    valueKey: AutoTpConfig.keyCrusadePos,
    valueCallback: AutoTpConfig.to.getCrusadePos,
  ),
  CoordsConfigItem(
    title: '确认',
    subTitle: '确认按钮的位置',
    valueKey: AutoTpConfig.keyConfirmPos,
    valueCallback: AutoTpConfig.to.getConfirmPos,
  ),
  CoordsConfigItem(
    title: '重置拖动条',
    subTitle: '书上将拖动条置于最上方的位置',
    valueKey: AutoTpConfig.keyBookDragStartPos,
    valueCallback: AutoTpConfig.to.getBookDragStartPos,
  ),
  CoordsConfigItem(
    title: '三列Boss的不同横坐标',
    subTitle: '开书Boss，每次都会拖动到第一行',
    valueKey: AutoTpConfig.keyBossXAxis,
    valueCallback: AutoTpConfig.to.getBossXAxis,
  ),
  CoordsConfigItem(
    title: 'Boss的纵坐标',
    subTitle: '开书Boss，每次都会拖动到第一行，纵坐标相同',
    valueKey: AutoTpConfig.keyBossYAxis,
    valueCallback: AutoTpConfig.to.getBossYAxis,
  ),
  CoordsConfigItem(
    title: '缩小地图',
    subTitle: '缩小地图按钮的位置',
    valueKey: AutoTpConfig.keyNarrowPos,
    valueCallback: AutoTpConfig.to.getNarrowPos,
  ),
  CoordsConfigItem(
    title: '放大地图',
    subTitle: '放大地图按钮的位置',
    valueKey: AutoTpConfig.keyEnlargePos,
    valueCallback: AutoTpConfig.to.getEnlargePos,
  ),
  CoordsConfigItem(
    title: '追踪Boss',
    subTitle: '开书后追踪Boss按钮的位置',
    valueKey: AutoTpConfig.keyTrackBossPos,
    valueCallback: AutoTpConfig.to.getTrackBossPos,
  ),
  CoordsConfigItem(
    title: '关闭Boss抽屉',
    subTitle: '关闭Boss抽屉按钮的位置',
    valueKey: AutoTpConfig.keyCloseBossDrawerPos,
    valueCallback: AutoTpConfig.to.getCloseBossDrawerPos,
  ),
  CoordsConfigItem(
    title: '食物',
    subTitle: '食物按钮的位置',
    valueKey: AutoTpConfig.keyFoodPos,
    valueCallback: AutoTpConfig.to.getFoodPos,
  ),
  CoordsConfigItem(
    title: '锚点多选一',
    subTitle: '锚点多选一按钮的位置',
    valueKey: AutoTpConfig.keySelectPos,
    valueCallback: AutoTpConfig.to.getSelectPos,
  ),
  CoordsConfigItem(
    title: '区域',
    subTitle: '选择区域的点击位置',
    valueKey: AutoTpConfig.keySelectAreaPos,
    valueCallback: AutoTpConfig.to.getSelectAreaPos,
  ),
  CoordsConfigItem(
    title: '区域蒙德',
    subTitle: '第一个区域蒙德的位置',
    valueKey: AutoTpConfig.keyFirstAreaPos,
    valueCallback: AutoTpConfig.to.getFirstAreaPos,
  ),
  CoordsConfigItem(
    title: '区域行间距',
    subTitle: '每行区域中心点的间距',
    valueKey: AutoTpConfig.keyAreaRowSpacing,
    valueCallback: AutoTpConfig.to.getAreaRowSpacing,
  ),
  CoordsConfigItem(
    title: '区域列间距',
    subTitle: '每列区域中心点的间距',
    valueKey: AutoTpConfig.keyAreaColSpacing,
    valueCallback: AutoTpConfig.to.getAreaColSpacing,
  ),
];

class AutoTpModel extends ChangeNotifier {
  String? selectedDir;
  String? selectedFile;
  int currentRouteIndex = 0;
  List<TpPoint> tpPoints = [];
  bool isRunning = false;

  var delayLightText = '';
  var displayedDelayConfigItems = delayConfigItems;
  final delaySearchController = TextEditingController();

  void searchDisplayedDelayConfigItems(String searchValue) {
    delayLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedDelayConfigItems = delayConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = delayConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedDelayConfigItems = filteredList;
    }
    notifyListeners();
  }

  var coordsLightText = '';
  var displayedCoordsConfigItems = coordsConfigItems;
  final coordsSearchController = TextEditingController();

  final scrollController = ScrollController();

  void searchDisplayedCoordsConfigItems(String searchValue) {
    coordsLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedCoordsConfigItems = coordsConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = coordsConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedCoordsConfigItems = filteredList;
    }

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

  void start(BuildContext context) {
    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;

    if (hWnd == 0) {
      dialog(context, title: '错误', content: '游戏窗口未启动!');
      return;
    }

    isRunning = true;
    startKeyboardHook();
    startMouseHook();

    setForegroundWindow(hWnd);
    detectWindow();

    notifyListeners();
  }

  void stop() {
    isRunning = false;
    stopKeyboardHook();
    stopMouseHook();

    notifyListeners();
  }
}
