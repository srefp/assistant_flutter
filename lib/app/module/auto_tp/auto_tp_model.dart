import 'package:assistant/component/config_row/coded_enum_config_row.dart';
import 'package:assistant/component/config_row/double_config_row.dart';
import 'package:assistant/component/model/config_item.dart';
import 'package:assistant/constant/script_engine.dart';
import 'package:assistant/helper/cv/scan.dart';
import 'package:assistant/helper/win32/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

import '../../../component/config_row/bool_config_row.dart';
import '../../../component/config_row/hotkey_config_row.dart';
import '../../../component/config_row/int_config_row.dart';
import '../../../component/config_row/string_config_row.dart';
import '../../../component/dialog.dart';
import '../../../component/text/win_text.dart';
import '../../../helper/auto_gui/system_control.dart';
import '../../../helper/isolate/win32_event_listen.dart';
import '../../../helper/js/js_executor.dart';
import '../../../helper/key_mouse/hot_key.dart';
import '../../../helper/screen/screen_manager.dart';
import '../../../helper/search_utils.dart';
import '../../../helper/toast/message_pump_helper.dart';
import '../../../helper/win32/window.dart';
import '../../../main.dart';
import '../../config/app_config.dart';
import '../../config/auto_tp_config.dart';
import '../../config/hotkey_config.dart';
import '../../config/process_key_config.dart';
import '../../config/process_pos/process_pos_config.dart';
import '../../windows_app.dart';
import '../config/config_model.dart';
import 'eula.dart';

/// 辅助功能开启/关闭配置
final helpConfigItems = [
  HotkeyConfigItem(
    type: global,
    title: '耕地机开关',
    subTitle: '启动/关闭耕地机',
    valueKey: HotkeyConfig.keyStartStopKey,
    valueCallback: HotkeyConfig.to.getStartStopKey,
    keyItemCallback: HotkeyConfig.to.getStartStopKeyItem,
    keyDownHandler: (hotKey) {
      startOrStopDebounce(() => WindowsApp.autoTpModel.startOrStop(tip: false));
    },
  ),
  HotkeyConfigItem(
    type: global,
    title: '重启耕地机',
    subTitle: '重启耕地机',
    valueKey: HotkeyConfig.keyRestartKey,
    valueCallback: HotkeyConfig.to.getRestartKey,
    keyItemCallback: HotkeyConfig.to.getRestartKeyItem,
    keyDownHandler: (hotKey) {
      restartApp();
    },
  ),
  HotkeyConfigItem(
    title: '录制（暂时不可用）',
    subTitle: '开始/结束录制',
    enabledKey: HotkeyConfig.keyToggleRecordEnabled,
    enabledCallback: HotkeyConfig.to.isToggleRecordEnabled,
    valueKey: HotkeyConfig.keyToggleRecord,
    valueCallback: HotkeyConfig.to.getToggleRecordKey,
  ),
  HotkeyConfigItem(
    title: '标点',
    subTitle: '显示并复制当前鼠标坐标',
    enabledKey: HotkeyConfig.keyShowCoordsEnabled,
    enabledCallback: HotkeyConfig.to.isShowCoordsEnabled,
    valueKey: HotkeyConfig.keyShowCoordsKey,
    valueCallback: HotkeyConfig.to.getShowCoordsKey,
  ),
  HotkeyConfigItem(
    title: '半自动传送',
    subTitle: '点锚点并点确认键，然后复位',
    enabledKey: HotkeyConfig.keyHalfTpEnabled,
    enabledCallback: HotkeyConfig.to.isHalfTpEnabled,
    valueKey: HotkeyConfig.keyHalfTp,
    valueCallback: HotkeyConfig.to.getHalfTp,
  ),
  HotkeyConfigItem(
    title: '上一个点位',
    subTitle: '上一个点位（不传送）',
    enabledKey: HotkeyConfig.keyToPrevEnabled,
    enabledCallback: HotkeyConfig.to.isToPrevEnabled,
    valueKey: HotkeyConfig.keyToPrev,
    valueCallback: HotkeyConfig.to.getToPrev,
  ),
  HotkeyConfigItem(
    title: '下一个点位',
    subTitle: '下一个点位（不传送）',
    enabledKey: HotkeyConfig.keyToNextEnabled,
    enabledCallback: HotkeyConfig.to.isToNextEnabled,
    valueKey: HotkeyConfig.keyToNext,
    valueCallback: HotkeyConfig.to.getToNext,
  ),
  HotkeyConfigItem(
    title: '全自动传送',
    subTitle: '按照路线传送到下一个点位',
    enabledKey: AutoTpConfig.keyAutoTpEnabled,
    enabledCallback: AutoTpConfig.to.isAutoTpEnabled,
    valueKey: HotkeyConfig.keyTpNext,
    valueCallback: HotkeyConfig.to.getTpNext,
  ),
  HotkeyConfigItem(
    title: 'qm全自动传送',
    subTitle: '开大招，然后按照路线传送到下一个点位',
    enabledKey: HotkeyConfig.keyQmAutoTpEnabled,
    enabledCallback: HotkeyConfig.to.isQmAutoTpEnabled,
    valueKey: HotkeyConfig.keyQmTpNext,
    valueCallback: HotkeyConfig.to.getQmTpNext,
  ),
  HotkeyConfigItem(
    title: '快捡',
    subTitle: '长按F变成快速连发F加滚轮',
    enabledKey: AutoTpConfig.keyQuickPickEnabled,
    enabledCallback: AutoTpConfig.to.isQuickPickEnabled,
    valueKey: HotkeyConfig.keyQuickPickKey,
    valueCallback: HotkeyConfig.to.getQuickPickKey,
  ),
  HotkeyConfigItem(
    title: '开启/关闭快捡',
    subTitle: '快速开启/关闭快捡。',
    enabledKey: AutoTpConfig.keyToggleQuickPickEnabled,
    enabledCallback: AutoTpConfig.to.isToggleQuickPickEnabled,
    valueKey: HotkeyConfig.keyToggleQuickPickKey,
    valueCallback: HotkeyConfig.to.getToggleQuickPickKey,
  ),
  HotkeyConfigItem(
    title: '匀速冲刺',
    subTitle: '默认按 v 可以匀速冲刺；再按 v 停止匀速冲刺，但是还会往前走；按 w 人工接管。',
    enabledKey: AutoTpConfig.keyDashEnabled,
    enabledCallback: AutoTpConfig.to.isDashEnabled,
    valueKey: HotkeyConfig.keyTimerDashKey,
    valueCallback: HotkeyConfig.to.getTimerDashKey,
  ),
  HotkeyConfigItem(
    title: '快速吃药',
    subTitle: '默认按`键快速吃药',
    enabledKey: AutoTpConfig.keyEatFoodEnabled,
    enabledCallback: AutoTpConfig.to.isEatFoodEnabled,
    valueKey: HotkeyConfig.keyEatFoodKey,
    valueCallback: HotkeyConfig.to.getEatFoodKey,
  ),
  BoolConfigItem(
    title: '记录快速吃药',
    subTitle: '双击b键，进入记录视频坐标模式，点击食品就记录成功，之后单击b完成记录。',
    valueKey: AutoTpConfig.keyFoodRecordEnabled,
    valueCallback: AutoTpConfig.to.isFoodRecordEnabled,
  ),
  BoolConfigItem(
    title: 'qm时是否冲刺',
    subTitle: 'qm时是否冲刺',
    valueKey: AutoTpConfig.keyQmDash,
    valueCallback: AutoTpConfig.to.isQmDash,
  ),
  BoolConfigItem(
    title: '连锄模式',
    subTitle: '连续锄地模式，如果传送到路线最后一个点位，下一次会传送到第二个点位。',
    valueKey: AutoTpConfig.keyContinuousMode,
    valueCallback: AutoTpConfig.to.isContinuousMode,
  ),
  StringConfigItem(
    title: '快速吃药坐标',
    subTitle: '坐标列表',
    valueKey: AutoTpConfig.keyRecordedFoodPos,
    valueCallback: AutoTpConfig.to.getRecordedFoodPos,
  ),
];

/// 窗口键位配置
final processKeyConfigItems = [
  StringConfigItem(
    title: '开图',
    subTitle: '打开/关闭地图的键位',
    valueKey: ProcessKeyConfig.keyOpenMapKey,
    valueCallback: ProcessKeyConfig.to.getOpenMapKey,
  ),
  StringConfigItem(
    title: '开书',
    subTitle: '打开/关闭书的键位',
    valueKey: ProcessKeyConfig.keyOpenBookKey,
    valueCallback: ProcessKeyConfig.to.getOpenBookKey,
  ),
  StringConfigItem(
    title: '联机',
    subTitle: '联机的键位',
    valueKey: ProcessKeyConfig.keyOnlineKey,
    valueCallback: ProcessKeyConfig.to.getOnlineKey,
  ),
  StringConfigItem(
    title: '冲刺',
    subTitle: '冲刺的键位',
    valueKey: ProcessKeyConfig.keyDashKey,
    valueCallback: ProcessKeyConfig.to.getDashKey,
  ),
  StringConfigItem(
    title: '背包',
    subTitle: '打开/关闭背包的键位',
    valueKey: ProcessKeyConfig.keyBagKey,
    valueCallback: ProcessKeyConfig.to.getBagKey,
  ),
  StringConfigItem(
    title: '前进',
    subTitle: '向前走的键位',
    valueKey: ProcessKeyConfig.keyForwardKey,
    valueCallback: ProcessKeyConfig.to.getForwardKey,
  ),
  StringConfigItem(
    title: '捡东西',
    subTitle: '捡东西的键位',
    valueKey: ProcessKeyConfig.keyPickKey,
    valueCallback: ProcessKeyConfig.to.getPickKey,
  ),
  StringConfigItem(
    title: '放大招',
    subTitle: '放大招的键位',
    valueKey: ProcessKeyConfig.keyQKey,
    valueCallback: ProcessKeyConfig.to.getQKey,
  ),
];

final matchConfigItems = <ConfigItem>[
  DoubleConfigItem(
    title: '匹配阈值',
    subTitle: '匹配分数范围0 - 1，越接近1越匹配',
    valueKey: AutoTpConfig.keyMatchThreshold,
    valueCallback: AutoTpConfig.to.getMatchThreshold,
  ),
  BoolConfigItem(
    title: '是否开启识图半自动',
    subTitle: '识图半自动通过识图进行半自动传送',
    valueKey: AutoTpConfig.keyTpDetectEnabled,
    valueCallback: AutoTpConfig.to.isTpDetectEnabled,
  ),
  DoubleConfigItem(
    title: '识图半自动 - 匹配阈值',
    subTitle: '匹配分数范围0 - 1，越接近1越匹配',
    valueKey: AutoTpConfig.keyTpDetectThreshold,
    valueCallback: AutoTpConfig.to.getTpDetectThreshold,
  ),
  IntConfigItem(
    title: '识图半自动 - 匹配间隔',
    subTitle: '识图半自动匹配间隔，单位毫秒',
    valueKey: AutoTpConfig.keyTpDetectInterval,
    valueCallback: AutoTpConfig.to.getTpDetectInterval,
  ),
  StringConfigItem(
    title: '识图半自动 - 匹配区域',
    subTitle: '识图半自动匹配区域，格式：x1, y1, x2, y2',
    valueKey: AutoTpConfig.keyTpDetectArea,
    valueCallback: AutoTpConfig.to.getTpDetectArea,
    width: 220,
  ),
  BoolConfigItem(
    title: '识图半自动 - 是否开启大世界检测',
    subTitle: '识图半自动通过识图进行半自动传送',
    valueKey: AutoTpConfig.keyWorldDetectEnabled,
    valueCallback: AutoTpConfig.to.isWorldDetectEnabled,
  ),
  DoubleConfigItem(
    title: '识图半自动 - 大世界检测匹配阈值',
    subTitle: '匹配分数范围0 - 1，越接近1越匹配',
    valueKey: AutoTpConfig.keyWorldDetectThreshold,
    valueCallback: AutoTpConfig.to.getWorldDetectThreshold,
  ),
  IntConfigItem(
    title: '识图半自动 - 大世界匹配间隔',
    subTitle: '识图半自动 - 大世界匹配间隔，单位毫秒',
    valueKey: AutoTpConfig.keyWorldDetectInterval,
    valueCallback: AutoTpConfig.to.getWorldDetectInterval,
  ),
  StringConfigItem(
    title: '识图半自动 - 大世界检测匹配区域',
    subTitle: '识图半自动 - 大世界检测匹配区域，格式：x1, y1, x2, y2',
    valueKey: AutoTpConfig.keyWorldDetectArea,
    valueCallback: AutoTpConfig.to.getWorldDetectArea,
    width: 220,
  ),
  BoolConfigItem(
    title: '识图半自动 - 是否开启锚点多选检测',
    subTitle: '识图半自动通过识图进行半自动传送',
    valueKey: AutoTpConfig.keyMultiTpDetectEnabled,
    valueCallback: AutoTpConfig.to.isMultiTpDetectEnabled,
  ),
  DoubleConfigItem(
    title: '识图半自动 - 锚点多选匹配阈值',
    subTitle: '匹配分数范围0 - 1，越接近1越匹配',
    valueKey: AutoTpConfig.keyMultiTpDetectThreshold,
    valueCallback: AutoTpConfig.to.getMultiTpDetectThreshold,
  ),
  IntConfigItem(
    title: '识图半自动 - 锚点多选匹配间隔',
    subTitle: '识图半自动 - 锚点多选匹配间隔，单位毫秒',
    valueKey: AutoTpConfig.keyMultiTpDetectInterval,
    valueCallback: AutoTpConfig.to.getMultiTpDetectInterval,
  ),
  StringConfigItem(
    title: '识图半自动 - 锚点多选检测匹配区域',
    subTitle: '识图半自动 - 锚点多选检测匹配区域，格式：x1, y1, x2, y2',
    valueKey: AutoTpConfig.keyMultiTpDetectArea,
    valueCallback: AutoTpConfig.to.getMultiTpDetectArea,
    width: 220,
  ),
  // StringConfigItem(
  //   title: '大世界匹配区域',
  //   valueKey: AutoTpConfig.keyWorldRect,
  //   valueCallback: AutoTpConfig.to.getWorldString,
  // ),
  // StringConfigItem(
  //   title: '锚点匹配区域',
  //   valueKey: AutoTpConfig.keyAnchorRect,
  //   valueCallback: AutoTpConfig.to.getAnchorString,
  // ),
];

final scriptConfigItems = [
  BoolConfigItem(
    title: '运行脚本时自动启动',
    subTitle: '运行脚本时自动键鼠监听，如果不是运行键鼠操作相关函数，可关闭',
    valueKey: AppConfig.keyStartWhenRunScript,
    valueCallback: AppConfig.to.isStartWhenRunScript,
  ),
  BoolConfigItem(
    title: '允许引入外部脚本',
    subTitle: '引入外部脚本 // import lib ...',
    valueKey: AppConfig.keyAllowImportScript,
    valueCallback: AppConfig.to.isAllowImportScript,
  ),
  CodedEnumConfigItem(
    title: '默认脚本引擎',
    subTitle: '默认使用的脚本引擎',
    items: ScriptEngine.values,
    valueKey: AppConfig.keyDefaultScriptEngine,
    valueCallback: AppConfig.to.getDefaultScriptEngine,
  ),
];

final delayConfigItems = [
  IntConfigItem(
    title: '包传送的半自动传送，第一个延迟，点击锚点后，需要等待的毫秒数',
    subTitle: '',
    valueKey: AutoTpConfig.keyTpcPlusFirstDelay,
    valueCallback: AutoTpConfig.to.getTpcPlusFirstDelay,
  ),
  IntConfigItem(
    title: '包传送的半自动传送，第二个延迟，点击传送按钮后，需要等待的毫秒数',
    subTitle: '',
    valueKey: AutoTpConfig.keyTpcPlusSecondDelay,
    valueCallback: AutoTpConfig.to.getTpcPlusSecondDelay,
  ),
  IntConfigItem(
    title: '包传送的半自动传送，第三个延迟，点击锚点后，需要等待的毫秒数',
    subTitle: '',
    valueKey: AutoTpConfig.keyTpcPlusThirdDelay,
    valueCallback: AutoTpConfig.to.getTpcPlusThirdDelay,
  ),
  IntConfigItem(
    title: '包传送的半自动传送，第四个延迟，点击弹出的选项后，需要等待的毫秒数',
    subTitle: '',
    valueKey: AutoTpConfig.keyTpcPlusFourthDelay,
    valueCallback: AutoTpConfig.to.getTpcPlusFourthDelay,
  ),
  IntConfigItem(
    title: '批量点击间隔',
    subTitle: '',
    valueKey: AutoTpConfig.keyBatchClickInterval,
    valueCallback: AutoTpConfig.to.getBatchClickInterval,
  ),
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
    title: '半自动传送延迟',
    subTitle: '半自动传送时，移动到右下方按钮后，需要等待的毫秒数',
    valueKey: AutoTpConfig.keyMoveToConfirmDelay,
    valueCallback: AutoTpConfig.to.getMoveToConfirmDelay,
  ),
  IntConfigItem(
    title: '半自动传送鼠标重试延迟',
    subTitle: '半自动传送时，副本锚点响应慢，需要等待一定的毫秒后，再次重试点击确认按钮',
    valueKey: AutoTpConfig.keyTpcRetryDelay,
    valueCallback: AutoTpConfig.to.getTpcRetryDelay,
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
    title: '打开背包',
    subTitle: '打开背包的延迟',
    valueKey: AutoTpConfig.keyOpenBagDelay,
    valueCallback: AutoTpConfig.to.getOpenBagDelay,
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
    valueKey: AutoTpConfig.keyBookRecordDelay,
    valueCallback: AutoTpConfig.to.getBookRecordDelay,
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
    valueKey: ProcessPosConfig.keyConfirmPos,
    valueCallback: ProcessPosConfig.to.getConfirmPos,
  ),
  StringConfigItem(
    title: '锚点多选',
    subTitle: '多个锚点离得比较近时，点击后弹出的第一个选项的位置',
    valueKey: ProcessPosConfig.keySelectPos,
    valueCallback: ProcessPosConfig.to.getSelectPos,
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
    valueKey: ProcessPosConfig.keyFoodPos,
    valueCallback: ProcessPosConfig.to.getFoodPos,
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
      windowManager.destroy();
    });
    dialog(
      title: '通知',
      content: '请下载新版本的耕地机，该版本已停止使用!',
      barrierDismissible: false,
    );
    return;
  } else {
    if (!AppConfig.to.getEulaNotificationDisabled()) {
      dialog(
        title: '注意',
        child: OutOfDateNotification(),
        barrierDismissible: false,
        actions: [
          Row(
            children: [
              NoMoreNotification(),
              SizedBox(
                width: 8,
              ),
              WinText('不再提醒'),
            ],
          ),
          FilledButton(
            child: const WinText('同意并开始使用'),
            onPressed: () {
              Navigator.pop(rootNavigatorKey.currentContext!); // 关闭模态框
            },
          ),
        ],
      );
    }
  }
}

class NoMoreNotification extends StatefulWidget {
  const NoMoreNotification({super.key});

  @override
  State<NoMoreNotification> createState() => _NoMoreNotificationState();
}

class _NoMoreNotificationState extends State<NoMoreNotification> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      checked: AppConfig.to.getEulaNotificationDisabled(),
      onChanged: (value) {
        setState(() {
          AppConfig.to.save(AppConfig.keyEulaNotificationDisabled, value);
        });
      },
    );
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
      height: 320,
      child: ListView(
        children: [
          WinText(
              '该版本耕地机为预览版本，到${DateFormat('yyyy-MM-dd HH:mm:ss').format(outDate)}停止使用!\n'
              ''),
          WinText(eula),
        ],
      ),
    );
  }
}

const String curScreen = '当前屏幕';
const String targetWindow = '指定窗口';
const String windowHandle = '窗口句柄';

class AutoTpModel extends ChangeNotifier {
  bool isRunning = false;
  var tasks = ScreenManager.getWindowTasks();

  AutoTpModel() {
    // 加载js函数
    Future.delayed(Duration(milliseconds: 10), () {
      registerJsFunc();
      loadTasks();

      validType = AutoTpConfig.to.getValidType();
    });
  }

  bool active() {
    return isRunning &&
        (validType == curScreen || ScreenManager.instance.isWindowActive());
  }

  loadTasks() {
    tasks = ScreenManager.getWindowTasks();
    anchorWindowList = tasks.map((e) => e.name).toList();
    notifyListeners();
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

  var scriptLightText = '';
  var displayedScriptConfigItems = scriptConfigItems;
  final scriptSearchController = TextEditingController();

  void searchDisplayedScriptConfigItems(String searchValue) {
    scriptLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedScriptConfigItems = scriptConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = scriptConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedScriptConfigItems = filteredList;
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

  var matchLightText = '';
  var displayedMatchConfigItems = matchConfigItems;
  final matchSearchController = TextEditingController();

  void searchDisplayedMatchConfigItems(String searchValue) {
    matchLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedMatchConfigItems = matchConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = matchConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedMatchConfigItems = filteredList;
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

  var processKeyLightText = '';
  var displayedProcessKeyConfigItems = processKeyConfigItems;
  final processKeySearchController = TextEditingController();
  final windowHandleController = TextEditingController(
    text: ScreenManager.instance.foregroundWindowHandle.toString(),
  );

  String? anchorWindow = AutoTpConfig.to.getAnchorWindow();

  List<String> anchorWindowList = [];

  String validType = curScreen;

  List<String> validTypeList = [curScreen, targetWindow, windowHandle];

  void searchProcessKeyConfigItems(String searchValue) {
    processKeyLightText = searchValue;
    if (searchValue.isEmpty) {
      displayedProcessKeyConfigItems = processKeyConfigItems;
      notifyListeners();
      return;
    }
    final filteredList = processKeyConfigItems
        .where(
            (item) => searchTextList(searchValue, [item.title, item.subTitle]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedProcessKeyConfigItems = filteredList;
    }

    notifyListeners();
  }

  void startOrStop({bool tip = false}) {
    if (isRunning) {
      stop(tip: tip);
    } else {
      start(tip: tip);
    }
  }

  int keyListerId = 0;
  int mouseListerId = 0;

  bool start({bool tip = false}) {
    if (AutoTpConfig.to.getValidType() == targetWindow) {
      final String? windowTitle = AutoTpConfig.to.getAnchorWindow();
      ScreenManager.instance.refreshWindowHandle(windowTitle: windowTitle);
    }

    int hWnd = ScreenManager.instance.hWnd;
    SystemControl.refreshRect();

    if (validType == targetWindow && hWnd == 0) {
      dialog(title: '错误', content: '进程窗口未启动!');
      return false;
    }

    if (SystemControl.rect.width <= 0 || SystemControl.rect.height <= 0) {
      dialog(title: '错误', content: '窗口识别异常，请重试!');
      return false;
    }

    isRunning = true;

    startKeyMouseListen();

    if (validType == targetWindow || validType == windowHandle && hWnd != 0) {
      if (AppConfig.to.getToWindowAfterStarted()) {
        setForegroundWindow(hWnd);
      }

      if (validType == targetWindow &&
          ScreenManager.instance.hWnd != 0 &&
          ScreenManager.instance.task != null) {
        startListenWindow(
            ScreenManager.instance.hWnd, ScreenManager.instance.task!.pid);
      } else if (validType == windowHandle && hWnd != 0) {
        startListenWindow(hWnd, getPidByWindowHandle(hWnd));
      }
    }

    startWorldDetect();
    if (tip) {
      showToast('耕地机已启动', duration: 800);
    }

    notifyListeners();
    return true;
  }

  void stop({bool tip = false}) {
    isRunning = false;
    stopListenWindow();
    stopKeyMouseListen();

    if (tip) {
      showToast('耕地机已停止', duration: 800);
    }
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
