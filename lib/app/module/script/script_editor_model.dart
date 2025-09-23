import 'package:assistant/component/dialog.dart';
import 'package:assistant/component/editor/editor.dart';
import 'package:assistant/helper/helper.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

import '../../../component/box/win_text_box.dart';
import '../../../component/text/win_text.dart';
import '../../../constant/enum_util.dart';
import '../../../constant/script_record_mode.dart';
import '../../../helper/auto_gui/system_control.dart';
import '../../../helper/js/js_executor.dart';
import '../../../helper/route/route_helper.dart';
import '../../../helper/screen/screen_manager.dart';
import '../../../helper/win32/window.dart';
import '../../config/app_config.dart';
import '../../config/auto_tp_config.dart';
import '../../config/config_storage.dart';
import '../../config/script_config.dart';
import '../../dao/db/crud.dart';
import '../../dao/tp_route_db.dart';
import '../../windows_app.dart';
import '../auto_tp/tp_route.dart';
import '../record/record_model.dart';

class ScriptEditorModel with ChangeNotifier {
  /// 选择的目录
  ScriptRecordMode? selectedScriptRecordMode;

  String? selectedDir;
  String? selectedFile;

  int currentRouteIndex = 0;
  List<BlockItem> tpPoints = [];
  String? currentRoute;
  List<TpRoute> routes = [];
  List<String> routeNames = [];
  String currentPos = '不在路线中';
  List<String> posList = ['不在路线中'];
  String? errorMessage;

  /// 选择的文件
  String? selectedScriptName;

  /// 文件列表
  List<String> scriptNameList = [];

  /// 文件内容
  String? scriptContent;

  /// 文件是否修改且未保存
  bool isUnsaved = false;

  /// 当前脚本
  TpRoute? currentScript;

  CodeLineEditingController controller = CodeLineEditingController();
  CodeLineEditingController variableController = CodeLineEditingController();

  late Function(dynamic) saveFileContent;

  bool isRecording = false;

  ScriptEditorModel() {
    loadRoutes();
    loadScripts();
    loadVariable();
  }

  void setSelectedDir(String dir) {
    selectedDir = dir;
    notifyListeners();
  }

  void setSelectedFile(String file) {
    selectedFile = file;
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

  void selectPos(String value) {
    currentPos = value;
    AutoTpConfig.to.save(AutoTpConfig.keyRouteIndex, posList.indexOf(value));
    notifyListeners();
  }

  /// 解析路线内容
  List<BlockItem> parseTpPoints(String content) {
    return RouteUtil.parseFile(content);
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

  void loadScripts() async {
    // 自动选择上次选项，如果没有，则默认选择第一个
    await autoSelectDir();
    await autoSelectFile();

    controller.text = scriptContent ?? '';

    controller.addListener(() {
      if (controller.text == scriptContent) {
        return;
      }
      scriptContent = controller.text;
      markAsUnsaved();
      saveFileContent(scriptContent);
    });

    saveFileContent = debounce(
      (_) => saveScript(controller.text),
      seconds: 2,
    );
    notifyListeners();
  }

  TextEditingController nameController = TextEditingController();

  bool isRunning = false;

  /// 运行js代码
  void runJs(BuildContext context) async {
    if (AppConfig.to.isStartWhenRunScript() &&
        !WindowsApp.autoTpModel.isRunning) {
      startOrStopDebounce(() => WindowsApp.autoTpModel.start());
    }

    isRunning = true;
    notifyListeners();

    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;
    if (hWnd != 0) {
      if (AppConfig.to.getToWindowAfterStarted()) {
        setForegroundWindow(hWnd);
      }
    }

    String code = controller.selectedText;
    if (code.isEmpty) {
      code = controller.text;
    }

    if (selectedScriptRecordMode == ScriptRecordMode.autoTp) {
      var autoTpCode = '';
      for (var element in code.split('\n')) {
        if (element.trim().isEmpty) {
          continue;
        }
        autoTpCode += 'await tp({${element.trim()}});\n';
      }
      await runScript(autoTpCode, addAwait: false);
    } else if (selectedScriptRecordMode == ScriptRecordMode.autoScript) {
      // 将code中的异步函数添加await
      await runScript(code, libEnabled: AppConfig.to.isAllowImportScript());
    }

    isRunning = false;
    notifyListeners();
  }

  stopJs() {
    isRunning = false;
    notifyListeners();
  }

  /// 选择脚本类型
  void selectScriptType(String value) async {
    selectedScriptRecordMode =
        EnumUtil.fromResourceId(value, ScriptRecordMode.values);
    box.write(
        ScriptConfig.keySelectedScriptType, selectedScriptRecordMode!.code);
    RecordModel.instance.scriptRecordMode = selectedScriptRecordMode!;

    // 加载目录下的文件
    if (selectedScriptRecordMode != null) {
      scriptNameList =
          await loadScriptsByType(selectedScriptRecordMode!.resourceId);
    }

    selectFirstFile(scriptNameList);
    box.write(ScriptConfig.keySelectedScript, selectedScriptName);

    notifyListeners();
  }

  /// 选择文件
  void selectScript(value) async {
    selectedScriptName = value;
    box.write(ScriptConfig.keySelectedScript, selectedScriptName);

    if (selectedScriptRecordMode != null && selectedScriptName != null) {
      currentScript = await loadScriptByNameAndType(
          selectedScriptRecordMode!.resourceId, selectedScriptName!);
      scriptContent = currentScript?.content;
      controller.text = scriptContent ?? '';
      controller.clearHistory();
    }

    selectRoute(value);
    loadRoutes();

    notifyListeners();
  }

  Future<void> autoSelectDir() async {
    selectedScriptRecordMode = EnumUtil.fromCode(
      box.read(ScriptConfig.keySelectedScriptType) ??
          ScriptRecordMode.autoTp.code,
      ScriptRecordMode.values,
    );
    if (selectedScriptRecordMode == null) {
      selectFirstDir();
    } else {
      RecordModel.instance.scriptRecordMode = selectedScriptRecordMode!;
      scriptNameList =
          await loadScriptsByType(selectedScriptRecordMode!.resourceId);
      selectFirstFile(scriptNameList);
    }
  }

  Future<void> selectFirstDir() async {
    selectedScriptRecordMode = ScriptRecordMode.autoTp;
    RecordModel.instance.scriptRecordMode = selectedScriptRecordMode!;

    // 加载目录下的文件
    scriptNameList =
        await loadScriptsByType(selectedScriptRecordMode!.resourceId);
  }

  Future<void> autoSelectFile() async {
    selectedScriptName = box.read(ScriptConfig.keySelectedScript);
    if (selectedScriptName == null) {
      selectFirstFile(scriptNameList);
    }

    if (selectedScriptRecordMode != null && selectedScriptName != null) {
      try {
        currentScript = await loadScriptByNameAndType(
            selectedScriptRecordMode!.resourceId, selectedScriptName!);
        scriptContent = currentScript?.content;
        controller.text = scriptContent ?? '';
      } catch (_) {}
    }
  }

  void selectFirstFile(List<String> files) async {
    if (files.isNotEmpty) {
      selectedScriptName = files.first;
    }

    if (selectedScriptRecordMode != null && selectedScriptName != null) {
      try {
        currentScript = await loadScriptByNameAndType(
            selectedScriptRecordMode!.resourceId, selectedScriptName!);
        scriptContent = currentScript?.content;
        controller.text = scriptContent ?? '';
      } catch (_) {}
    }
  }

  /// 保存脚本
  saveScript(String text) async {
    var content = text;
    if (content.isNotEmpty && !content.endsWith('\n')) {
      content += '\n';
      controller.text = content;

      // 设置光标位置到末尾
      controller.selection = CodeLineSelection.collapsed(
        index: controller.codeLines.length - 1,
        offset: controller.codeLines.last.length,
      );
    }
    await updateScript(
        selectedScriptRecordMode!.resourceId, selectedScriptName!, content);
    isUnsaved = false;

    await loadRoutes();
    tpPoints = parseTpPoints(content);
    posList = ['不在路线中'];
    for (var i = 0; i < tpPoints.length; i++) {
      posList.add(tpPoints[i].name ?? '点位${i + 1}');
    }
    notifyListeners();
  }

  /// 标记为未保存
  void markAsUnsaved() {
    isUnsaved = true;
    notifyListeners();
  }

  /// 显示变量
  void showVariable() {
    loadVariable();
    dialog(
      barrierDismissible: false,
      title: '预定义变量',
      width: 500,
      height: 400,
      child: SizedBox(
        child: Editor(controller: variableController),
      ),
      actions: [
        Button(
          child: const WinText('取消'),
          onPressed: () {
            goBack();
          },
        ),
        FilledButton(
          child: const WinText('保存'),
          onPressed: () {
            saveVariable();
          },
        ),
      ],
    );
  }

  /// 加载变量
  void loadVariable() {
    variableController.text = ScriptConfig.to.getVariable();
  }

  /// 保存变量
  void saveVariable() {
    box.write(ScriptConfig.keyVariable, variableController.text);

    // 重新注册预定义变量
    jsRuntime.evaluate(ScriptConfig.to.getVariable());
    back();
  }

  /// 显示脚本信息的模态框
  void showScriptInfo() {
    dialog(
      barrierDismissible: true,
      title: '脚本信息',
      actions: [
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.red),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          onPressed: () {
            back();
            showDeleteScriptModel();
          },
          child: const WinText('删除'),
        ),
        Button(
          child: const WinText('关闭'),
          onPressed: () {
            back();
          },
        ),
      ],
      child: Consumer<ScriptEditorModel>(
        builder: (context, model, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 200,
              child: ListView(children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      WinText('名称'),
                      const SizedBox(
                        width: 12,
                      ),
                      WinText(currentScript?.scriptName ?? ''),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      WinText('比例'),
                      const SizedBox(
                        width: 12,
                      ),
                      WinText(currentScript?.ratio ?? ''),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Row(
                    children: [
                      WinText('错误信息'),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(child: WinText(errorMessage ?? '无')),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  /// 显示添加脚本的模态框
  void showAddScriptModel(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) =>
            Consumer<ScriptEditorModel>(builder: (context, model, child) {
              return ContentDialog(
                title: WinText('新建脚本'),
                content: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 108,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: SizedBox(
                            height: 34,
                            child: Row(
                              children: [
                                WinText('名称'),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: WinTextBox(
                                      controller: model.nameController),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: SizedBox(
                            height: 34,
                            child: Row(
                              children: [
                                WinText('比例'),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                    child: WinText(SystemControl.ratio.name)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Button(
                    child: const WinText('取消'),
                    onPressed: () {
                      Navigator.pop(context); // 关闭模态框
                    },
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    child: const WinText('确定'),
                    onPressed: () {
                      model.createScript();
                      // 处理添加文件的逻辑
                      Navigator.pop(context); // 关闭模态框
                    },
                  ),
                ],
              );
            }));
  }

  /// 创建脚本
  void createScript() async {
    final scriptName = nameController.text;
    await addScript(selectedScriptRecordMode!.resourceId, scriptName, '');
    scriptNameList.add(scriptName);
    selectScript(scriptName);
  }

  /// 删除脚本
  void deleteScript() async {
    await deleteScriptByNameAndType(
        selectedScriptRecordMode!.resourceId, selectedScriptName!);
    scriptNameList.remove(selectedScriptName);
    selectFirstFile(scriptNameList);
    box.write(ScriptConfig.keySelectedScript, selectedScriptName);
    notifyListeners();
  }

  void showDeleteScriptModel() {
    dialog(
      title: '删除脚本',
      barrierDismissible: true,
      actions: [
        Button(
          child: const WinText('取消'),
          onPressed: () {
            back();
          },
        ),
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.red),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: const WinText('确定'),
          onPressed: () {
            deleteScript();
            back();
          },
        ),
      ],
      child: WinText('确定要删除脚本${currentScript?.scriptName}吗？'),
    );
  }

  /// 开始录制
  void startRecord(BuildContext context) {
    if (!WindowsApp.autoTpModel.isRunning) {
      bool started = false;
      startOrStopDebounce(() {
        started = WindowsApp.autoTpModel.start();
      });
      if (!started) {
        return;
      }
    }

    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;
    if (hWnd != 0) {
      setForegroundWindow(hWnd);
    }

    isRecording = true;

    WindowsApp.logModel
        .registerKeyMouseStream(controller, mode: selectedScriptRecordMode!);
    notifyListeners();
  }

  /// 停止录制
  void stopRecord() {
    // 停止键盘监听
    isRecording = false;

    WindowsApp.logModel.unRegisterKeyMouseStream();
    notifyListeners();
  }
}
