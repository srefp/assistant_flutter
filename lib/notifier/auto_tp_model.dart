import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/components/dialog.dart';
import 'package:assistant/components/win_text.dart';
import 'package:assistant/config/app_config.dart';
import 'package:assistant/config/game_key_config.dart';
import 'package:assistant/config/game_pos/game_pos_config.dart';
import 'package:assistant/cv/scan.dart';
import 'package:assistant/dao/crud.dart';
import 'package:assistant/model/tp_route.dart';
import 'package:assistant/util/route_util.dart';
import 'package:assistant/util/script_parser.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../components/bool_config_row.dart';
import '../components/int_config_row.dart';
import '../components/string_config_row.dart';
import '../config/auto_tp_config.dart';
import '../db/tp_route_db.dart';
import '../main.dart';
import '../manager/screen_manager.dart';
import '../util/js_executor.dart';
import '../util/search_utils.dart';
import '../win32/key_listen.dart';
import '../win32/message_pump.dart';
import '../win32/mouse_listen.dart';
import '../win32/window.dart';

/// 辅助功能开启/关闭配置
final helpConfigItems = [
  BoolConfigItem(
    title: '快捡',
    subTitle: '长按F变成快速连发F加滚轮',
    valueKey: AutoTpConfig.keyQuickPickEnabled,
    valueCallback: AutoTpConfig.to.isQuickPickEnabled,
  ),
  BoolConfigItem(
    title: '匀速冲刺',
    subTitle: '默认按 v 可以匀速冲刺；再按 v 停止匀速冲刺，但是还会往前走；按 w 人工接管。',
    valueKey: AutoTpConfig.keyDashEnabled,
    valueCallback: AutoTpConfig.to.isDashEnabled,
  ),
  BoolConfigItem(
    title: '记录快速吃药',
    subTitle: '双击b键，进入记录视频坐标模式，点击食品就记录成功，之后单击b完成记录。',
    valueKey: AutoTpConfig.keyFoodRecordEnabled,
    valueCallback: AutoTpConfig.to.isFoodRecordEnabled,
  ),
  BoolConfigItem(
    title: '快速吃药',
    subTitle: '默认按`键快速吃药',
    valueKey: AutoTpConfig.keyEatFoodEnabled,
    valueCallback: AutoTpConfig.to.isEatFoodEnabled,
  ),
  StringConfigItem(
    title: '快速吃药坐标',
    subTitle: '坐标列表',
    valueKey: AutoTpConfig.keyRecordedFoodPos,
    valueCallback: AutoTpConfig.to.getRecordedFoodPos,
  ),
];

/// 游戏键位配置
final gameKeyConfigItems = [
  StringConfigItem(
    title: '开图',
    subTitle: '打开/关闭地图的键位',
    valueKey: GameKeyConfig.keyOpenMapKey,
    valueCallback: GameKeyConfig.to.getOpenMapKey,
  ),
  StringConfigItem(
    title: '开书',
    subTitle: '打开/关闭书的键位',
    valueKey: GameKeyConfig.keyOpenBookKey,
    valueCallback: GameKeyConfig.to.getOpenBookKey,
  ),
  StringConfigItem(
    title: '联机',
    subTitle: '联机的键位',
    valueKey: GameKeyConfig.keyOnlineKey,
    valueCallback: GameKeyConfig.to.getOnlineKey,
  ),
  StringConfigItem(
    title: '冲刺',
    subTitle: '冲刺的键位',
    valueKey: GameKeyConfig.keyDashKey,
    valueCallback: GameKeyConfig.to.getDashKey,
  ),
  StringConfigItem(
    title: '背包',
    subTitle: '打开/关闭背包的键位',
    valueKey: GameKeyConfig.keyBagKey,
    valueCallback: GameKeyConfig.to.getBagKey,
  ),
  StringConfigItem(
    title: '前进',
    subTitle: '向前走的键位',
    valueKey: GameKeyConfig.keyForwardKey,
    valueCallback: GameKeyConfig.to.getForwardKey,
  ),
];

final delayConfigItems = [
  IntConfigItem(
    title: '自动冲刺间隔',
    subTitle: '',
    valueKey: AutoTpConfig.keyDashIntervalDelay,
    valueCallback: AutoTpConfig.to.getDashIntervalDelay,
  ),
  IntConfigItem(
    title: '半自动传送冷却',
    subTitle: '',
    valueKey: AutoTpConfig.keyTpcCooldown,
    valueCallback: AutoTpConfig.to.getTpcCooldown,
  ),
  IntConfigItem(
    title: '半自动传送延迟',
    subTitle: '半自动传送时，点击锚点后，需要等待的毫秒数',
    valueKey: AutoTpConfig.keyTpcDelay,
    valueCallback: AutoTpConfig.to.getTpcDelay,
  ),
  IntConfigItem(
    title: '半自动传送鼠标重试延迟',
    subTitle: '半自动传送时，副本锚点响应慢，需要等待一定的毫秒后，再次重试点击确认按钮',
    valueKey: AutoTpConfig.keyTpcRetryDelay,
    valueCallback: AutoTpConfig.to.getTpcBackDelay,
  ),
  IntConfigItem(
    title: '半自动传送鼠标归位延迟',
    subTitle: '半自动传送时，点击确认按钮后，归位需要等待的毫秒数',
    valueKey: AutoTpConfig.keyTpcBackDelay,
    valueCallback: AutoTpConfig.to.getTpcBackDelay,
  ),
  IntConfigItem(
    title: '自动传送冷却时间',
    subTitle: '点击完传送按钮后经过冷却时间才可以再次点击传送',
    valueKey: AutoTpConfig.keyTpCooldown,
    valueCallback: AutoTpConfig.to.getTpCooldown,
  ),
  IntConfigItem(
    title: '关闭开书后Boss抽屉的延迟',
    subTitle: '开书后Boss抽屉关不上，需要手动关闭',
    valueKey: AutoTpConfig.keyBossDrawerDelay,
    valueCallback: AutoTpConfig.to.getBossDrawerDelay,
  ),
  IntConfigItem(
    title: '吃药冷却时间',
    subTitle: '完成整个吃药流程后需要经过冷却时间才可以再次吃药',
    valueKey: AutoTpConfig.keyFoodCooldown,
    valueCallback: AutoTpConfig.to.getFoodCooldown,
  ),
  IntConfigItem(
    title: 'qm冲刺',
    subTitle: 'qm冲刺时间',
    valueKey: AutoTpConfig.keyQmDashDelay,
    valueCallback: AutoTpConfig.to.getQmDashDelay,
  ),
  IntConfigItem(
    title: 'qm大招',
    subTitle: 'qm时放出大招后需要等待的时间',
    valueKey: AutoTpConfig.keyQmQDelay,
    valueCallback: AutoTpConfig.to.getQmQDelay,
  ),
  IntConfigItem(
    title: '选区',
    subTitle: '选区延迟',
    valueKey: AutoTpConfig.keySelectAreaDelay,
    valueCallback: AutoTpConfig.to.getSelectAreaDelay,
  ),
  IntConfigItem(
    title: '单击',
    subTitle: '单击延迟',
    valueKey: AutoTpConfig.keyClickDelay,
    valueCallback: AutoTpConfig.to.getClickDelay,
  ),
  IntConfigItem(
    title: '单击食物',
    subTitle: '单击食物的延迟',
    valueKey: AutoTpConfig.keyClickFoodDelay,
    valueCallback: AutoTpConfig.to.getClickFoodDelay,
  ),
  IntConfigItem(
    title: '确认吃食物',
    subTitle: '确认吃食物的延迟',
    valueKey: AutoTpConfig.keyEatFoodDelay,
    valueCallback: AutoTpConfig.to.getEatFoodDelay,
  ),
  IntConfigItem(
    title: '开地图',
    subTitle: '直接开地图等待的时间',
    valueKey: AutoTpConfig.keyOpenMapDelay,
    valueCallback: AutoTpConfig.to.getOpenMapDelay,
  ),
  IntConfigItem(
    title: '切换区域',
    subTitle: '切换区域的等待时间',
    valueKey: AutoTpConfig.keySwitchAreaDelay,
    valueCallback: AutoTpConfig.to.getSwitchAreaDelay,
  ),
  IntConfigItem(
    title: '开书',
    subTitle: '开书延迟',
    valueKey: AutoTpConfig.keyOpenBookDelay,
    valueCallback: AutoTpConfig.to.getOpenBookDelay,
  ),
  IntConfigItem(
    title: '开书后追踪Boss开地图',
    subTitle: '点击追踪按钮后，需要等待开地图的时间',
    valueKey: AutoTpConfig.keyBookOpenMapDelay,
    valueCallback: AutoTpConfig.to.getBookOpenMapDelay,
  ),
  IntConfigItem(
    title: '快捡',
    subTitle: '快捡等待时间',
    valueKey: AutoTpConfig.keyPickDelay,
    valueCallback: AutoTpConfig.to.getPickDelay,
  ),
  IntConfigItem(
    title: '讨伐',
    subTitle: '讨伐等待时间',
    valueKey: AutoTpConfig.keyCrusadeDelay,
    valueCallback: AutoTpConfig.to.getCrusadeDelay,
  ),
  IntConfigItem(
    title: '清空滚动条',
    subTitle: '清空滚动条需要长按，长按的时间',
    valueKey: AutoTpConfig.keyLongPressDelay,
    valueCallback: AutoTpConfig.to.getLongPressDelay,
  ),
  IntConfigItem(
    title: '滚轮',
    subTitle: '滚轮滚动间隔时间',
    valueKey: AutoTpConfig.keyWheelIntervalDelay,
    valueCallback: AutoTpConfig.to.getWheelIntervalDelay,
  ),
  IntConfigItem(
    title: '滚轮完成',
    subTitle: '滚轮完成后需要等待的时间',
    valueKey: AutoTpConfig.keyWheelCompleteDelay,
    valueCallback: AutoTpConfig.to.getWheelCompleteDelay,
  ),
  IntConfigItem(
    title: '锚点多选',
    subTitle: '锚点多选等待时间',
    valueKey: AutoTpConfig.keyMultiSelectDelay,
    valueCallback: AutoTpConfig.to.getMultiSelectDelay,
  ),
  IntConfigItem(
    title: '拖动操作（移动到初始位置）',
    subTitle: '移动到初始位置的后摇',
    valueKey: AutoTpConfig.keyDragMoveToStartDelay,
    valueCallback: AutoTpConfig.to.getDragMoveToStartDelay,
  ),
  IntConfigItem(
    title: '拖动操作（按下鼠标左键）',
    subTitle: '按下鼠标左键的后摇',
    valueKey: AutoTpConfig.keyDragMouseDownDelay,
    valueCallback: AutoTpConfig.to.getDragMouseDownDelay,
  ),
  IntConfigItem(
    title: '拖动操作（移动一小段距离）',
    subTitle: '移动一小段距离的后摇',
    valueKey: AutoTpConfig.keyDragShortMoveDelay,
    valueCallback: AutoTpConfig.to.getDragShortMoveDelay,
  ),
  IntConfigItem(
    title: '拖动操作（移动到终止位置）',
    subTitle: '移动到终止位置的后摇',
    valueKey: AutoTpConfig.keyDragMoveToEndDelay,
    valueCallback: AutoTpConfig.to.getDragMoveToEndDelay,
  ),
  IntConfigItem(
    title: '拖动操作（松开鼠标）',
    subTitle: '松开鼠标的后摇',
    valueKey: AutoTpConfig.keyDragMouseUpDelay,
    valueCallback: AutoTpConfig.to.getDragMouseUpDelay,
  ),
  IntConfigItem(
    title: '快捡操作（总时长）',
    subTitle: '一个快捡操作周期的总时长',
    valueKey: AutoTpConfig.keyPickTotalDelay,
    valueCallback: AutoTpConfig.to.getPickTotalDelay,
  ),
  IntConfigItem(
    title: '快捡操作（按下F）',
    subTitle: '按下F的后摇',
    valueKey: AutoTpConfig.keyPickDownDelay,
    valueCallback: AutoTpConfig.to.getPickDownDelay,
  ),
  IntConfigItem(
    title: '快捡操作（松开F）',
    subTitle: '松开F的后摇',
    valueKey: AutoTpConfig.keyPickUpDelay,
    valueCallback: AutoTpConfig.to.getPickUpDelay,
  ),
];

final recordDelayConfigItems = [
  IntConfigItem(
    title: '开图操作',
    subTitle: '开图操作的延迟',
    valueKey: AutoTpConfig.keyMapRecordDelay,
    valueCallback: AutoTpConfig.to.getMapRecordDelay,
  ),
  IntConfigItem(
    title: '点击操作',
    subTitle: '点击操作的延迟',
    valueKey: AutoTpConfig.keyClickRecordDelay,
    valueCallback: AutoTpConfig.to.getClickRecordDelay,
  ),
  IntConfigItem(
    title: '开书操作',
    subTitle: '开书延迟',
    valueKey: AutoTpConfig.keyClickRecordDelay,
    valueCallback: AutoTpConfig.to.getClickRecordDelay,
  ),
  IntConfigItem(
    title: '拖动操作',
    subTitle: '拖动操作的后摇（完成拖动后的延迟）',
    valueKey: AutoTpConfig.keyDragRecordDelay,
    valueCallback: AutoTpConfig.to.getDragRecordDelay,
  ),
  IntConfigItem(
    title: '拖动第一步的一小段移动距离',
    subTitle: '拖动需要先移动一小段距离',
    valueKey: AutoTpConfig.keyShortMoveRecord,
    valueCallback: AutoTpConfig.to.getShortMoveRecord,
  ),
];

final coordsConfigItems = [
  StringConfigItem(
    title: '讨伐',
    subTitle: '讨伐按钮的位置',
    valueKey: AutoTpConfig.keyCrusadePos,
    valueCallback: AutoTpConfig.to.getCrusadePos,
  ),
  StringConfigItem(
    title: '确认',
    subTitle: '确认按钮的位置',
    valueKey: GamePosConfig.keyConfirmPos,
    valueCallback: GamePosConfig.to.getConfirmPos,
  ),
  StringConfigItem(
    title: '重置拖动条',
    subTitle: '书上将拖动条置于最上方的位置',
    valueKey: AutoTpConfig.keyBookDragStartPos,
    valueCallback: AutoTpConfig.to.getBookDragStartPos,
  ),
  StringConfigItem(
    title: '三列Boss的不同横坐标',
    subTitle: '开书Boss，每次都会拖动到第一行',
    valueKey: AutoTpConfig.keyBossXAxis,
    valueCallback: AutoTpConfig.to.getBossXAxis,
  ),
  StringConfigItem(
    title: 'Boss的纵坐标',
    subTitle: '开书Boss，每次都会拖动到第一行，纵坐标相同',
    valueKey: AutoTpConfig.keyBossYAxis,
    valueCallback: AutoTpConfig.to.getBossYAxis,
  ),
  StringConfigItem(
    title: '缩小地图',
    subTitle: '缩小地图按钮的位置',
    valueKey: AutoTpConfig.keyNarrowPos,
    valueCallback: AutoTpConfig.to.getNarrowPos,
  ),
  StringConfigItem(
    title: '放大地图',
    subTitle: '放大地图按钮的位置',
    valueKey: AutoTpConfig.keyEnlargePos,
    valueCallback: AutoTpConfig.to.getEnlargePos,
  ),
  StringConfigItem(
    title: '追踪Boss',
    subTitle: '开书后追踪Boss按钮的位置',
    valueKey: AutoTpConfig.keyTrackBossPos,
    valueCallback: AutoTpConfig.to.getTrackBossPos,
  ),
  StringConfigItem(
    title: '关闭Boss抽屉',
    subTitle: '关闭Boss抽屉按钮的位置',
    valueKey: AutoTpConfig.keyCloseBossDrawerPos,
    valueCallback: AutoTpConfig.to.getCloseBossDrawerPos,
  ),
  StringConfigItem(
    title: '食物',
    subTitle: '食物按钮的位置',
    valueKey: GamePosConfig.keyFoodPos,
    valueCallback: GamePosConfig.to.getFoodPos,
  ),
  StringConfigItem(
    title: '锚点多选一',
    subTitle: '锚点多选一按钮的位置',
    valueKey: AutoTpConfig.keySelectPos,
    valueCallback: AutoTpConfig.to.getSelectPos,
  ),
  StringConfigItem(
    title: '区域',
    subTitle: '选择区域的点击位置',
    valueKey: AutoTpConfig.keySelectAreaPos,
    valueCallback: AutoTpConfig.to.getSelectAreaPos,
  ),
  StringConfigItem(
    title: '第一个区域',
    subTitle: '第一个区域的位置',
    valueKey: AutoTpConfig.keyFirstAreaPos,
    valueCallback: AutoTpConfig.to.getFirstAreaPos,
  ),
  StringConfigItem(
    title: '区域行间距',
    subTitle: '每行区域中心点的间距',
    valueKey: AutoTpConfig.keyAreaRowSpacing,
    valueCallback: AutoTpConfig.to.getAreaRowSpacing,
  ),
  StringConfigItem(
    title: '区域列间距',
    subTitle: '每列区域中心点的间距',
    valueKey: AutoTpConfig.keyAreaColSpacing,
    valueCallback: AutoTpConfig.to.getAreaColSpacing,
  ),
];

showOutDate() {
  if (DateTime.now().isAfter(outDate)) {
    Future.delayed(const Duration(seconds: 5), () {
      windowManager.hide();
      trayManager.destroy();
      windowManager.destroy();
    });
    dialog(
      title: '通知',
      content: '请下载新版本的耕地机，该版本已停止使用!',
      barrierDismissible: false,
    );
    return;
  } else {
    if (!AppConfig.to.getOutDateNotificationDisabled()) {
      dialog(
        title: '注意',
        child: OutOfDateNotification(),
      );
    }
  }
}

class OutOfDateNotification extends StatefulWidget {
  const OutOfDateNotification({
    super.key,
  });

  @override
  State<OutOfDateNotification> createState() => _OutOfDateNotificationState();
}

class _OutOfDateNotificationState extends State<OutOfDateNotification> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          WinText(
              '该版本耕地机为预览版本，到${DateFormat('yyyy-MM-dd HH:mm:ss').format(outDate)}停止使用!'),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Checkbox(
                checked: AppConfig.to.getOutDateNotificationDisabled(),
                onChanged: (value) {
                  setState(() {
                    AppConfig.to
                        .save(AppConfig.keyOutDateNotificationDisabled, value);
                  });
                },
              ),
              SizedBox(
                width: 8,
              ),
              WinText('不再提醒'),
            ],
          ),
        ],
      ),
    );
  }
}

const String curScreen = '当前屏幕';
const String targetWindow = '指定窗口';

class AutoTpModel extends ChangeNotifier {
  String? selectedDir;
  String? selectedFile;
  int currentRouteIndex = 0;
  List<BlockItem> tpPoints = [];
  bool isRunning = false;
  String? currentRoute;
  List<TpRoute> routes = [];
  List<String> routeNames = [];
  String currentPos = '不在路线中';
  List<String> posList = ['不在路线中'];
  String? errorMessage;
  var tasks = ScreenManager.getWindowTasks();

  AutoTpModel() {
    // 加载js函数
    Future.delayed(Duration(milliseconds: 10), () {
      loadJsFunction();
      registerJsFunc();
      loadRoutes();
      messagePump();
      detectWorldRole();
      loadTasks();
    });
  }

  bool active() {
    return isRunning &&
        (validType == curScreen || ScreenManager.instance.isGameActive());
  }

  loadTasks() {
    tasks = ScreenManager.getWindowTasks();
    anchorWindowList = tasks.map((e) => e.name).toList();
    notifyListeners();
  }

  loadRoutes() async {
    routes =
        (await queryDb(TpRouteDb.tableName)).map(TpRoute.fromJson).toList();
    routeNames = routes.map((e) => e.scriptName).toList();
    currentRoute = AutoTpConfig.to.getCurrentRoute();

    if (currentRoute != null) {
      for (var element in routes) {
        if (element.scriptName == currentRoute) {
          try {
            tpPoints = parseTpPoints(element.content);
            errorMessage = null;
          } catch (e) {
            errorMessage = e.toString();
          }
          posList = ['不在路线中'];
          for (var i = 0; i < tpPoints.length; i++) {
            posList.add(tpPoints[i].name ?? '点位${i + 1}');
          }
        }
      }
    }

    if (posList.isNotEmpty) {
      final index = AutoTpConfig.to.getRouteIndex();
      if (index < posList.length) {
        currentPos = posList[index];
      } else {
        currentPos = posList[0];
      }
    }
    notifyListeners();
  }

  selectRoute(final String routeName) {
    for (var element in routes) {
      if (element.scriptName == routeName) {
        currentRoute = element.scriptName;
        tpPoints = parseTpPoints(element.content);
        AutoTpConfig.to.save(AutoTpConfig.keyCurrentRoute, routeName);
        posList = ['不在路线中'];
        for (var i = 0; i < tpPoints.length; i++) {
          posList.add(tpPoints[i].name ?? '点位${i + 1}');
        }

        if (posList.isNotEmpty) {
          AutoTpConfig.to.save(AutoTpConfig.keyRouteIndex, 0);
          currentPos = posList[0];
        }
        notifyListeners();
      }
    }
  }

  void selectPos(String value) {
    currentPos = value;
    AutoTpConfig.to.save(AutoTpConfig.keyRouteIndex, posList.indexOf(value));
    notifyListeners();
  }

  /// 解析路线内容
  List<BlockItem> parseTpPoints(String content) {
    return RouteUtil.parseFile(content);
  }

  var helpLightText = '';
  var displayedHelpConfigItems = helpConfigItems;
  final helpSearchController = TextEditingController();

  void searchDisplayedHelpConfigItems(String searchValue) {
    helpLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedHelpConfigItems = helpConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = helpConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedHelpConfigItems = filteredList;
    }
    notifyListeners();
  }

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

  var recordDelayLightText = '';
  var displayedRecordDelayConfigItems = recordDelayConfigItems;
  final recordDelaySearchController = TextEditingController();

  void searchDisplayedRecordDelayConfigItems(String searchValue) {
    recordDelayLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedRecordDelayConfigItems = recordDelayConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = recordDelayConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedRecordDelayConfigItems = filteredList;
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

  var gameKeyLightText = '';
  var displayedGameKeyConfigItems = gameKeyConfigItems;
  final gameKeySearchController = TextEditingController();

  String? anchorWindow = AutoTpConfig.to.getAnchorWindow();

  List<String> anchorWindowList = [];

  String validType = AutoTpConfig.to.getValidType();

  List<String> validTypeList = [curScreen, targetWindow];

  void searchGameKeyConfigItems(String searchValue) {
    gameKeyLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedGameKeyConfigItems = gameKeyConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = gameKeyConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedGameKeyConfigItems = filteredList;
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

  void startOrStop() {
    if (isRunning) {
      stop();
    } else {
      start();
    }
  }

  int keyListerId = 0;
  int mouseListerId = 0;

  bool start() {
    final String? windowTitle = AutoTpConfig.to.getAnchorWindow();

    ScreenManager.instance.refreshWindowHandle(windowTitle: windowTitle);
    int hWnd = ScreenManager.instance.hWnd;
    SystemControl.refreshRect();

    if (validType == targetWindow && hWnd == 0) {
      dialog(title: '错误', content: '游戏窗口未启动!');
      return false;
    }

    isRunning = true;

    if (validType == targetWindow && hWnd != 0) {
      setForegroundWindow(hWnd);
      ScreenManager.instance.startListen();
    }

    // keyListerId = listenerBackend.addKeyboardListener(keyboardListener)!;
    // mouseListerId = listenerBackend.addMouseListener(mouseListener)!;

    notifyListeners();
    return true;
  }

  void stop() {
    isRunning = false;
    ScreenManager.instance.stopListen();
    // listenerBackend.removeKeyboardListener(keyListerId);
    // listenerBackend.removeMouseListener(mouseListerId);

    notifyListeners();
  }

  String getScreen() {
    return SystemControl.rect.getWidthAndHeight();
  }

  void fresh() {
    notifyListeners();
  }

  void selectAnchorWindow(String value) {
    anchorWindow = value;
    AutoTpConfig.to.save(AutoTpConfig.keyAnchorWindow, value);
    notifyListeners();
  }

  void selectValidType(String value) {
    validType = value;
    AutoTpConfig.to.save(AutoTpConfig.keyValidType, value);
    notifyListeners();
  }
}
