import 'package:assistant/components/win_text.dart';
import 'package:assistant/config/script_config.dart';
import 'package:assistant/constants/enum_util.dart';
import 'package:assistant/constants/script_record_mode.dart';
import 'package:assistant/db/tp_route_db.dart';
import 'package:assistant/model/tp_route.dart';
import 'package:assistant/util/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

import '../app/windows_app.dart';
import '../auto_gui/system_control.dart';
import '../components/win_text_box.dart';
import '../config/config_storage.dart';
import '../manager/screen_manager.dart';
import '../util/js_executor.dart';
import '../win32/window.dart';

class ScriptEditorModel with ChangeNotifier {
  /// 选择的目录
  ScriptRecordMode? selectedScriptRecordMode;

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
  late Function(dynamic) saveFileContent;

  ScriptEditorModel() {
    loadScripts();
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
    if (!WindowsApp.autoTpModel.isRunning) {
      WindowsApp.autoTpModel.start();
    }

    isRunning = true;
    notifyListeners();

    ScreenManager.instance.refreshWindowHandle();
    int? hWnd = ScreenManager.instance.hWnd;
    if (hWnd != 0) {
      setForegroundWindow(hWnd);
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
      await runScript(code);
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
    selectedScriptRecordMode = EnumUtil.fromResourceId(value, ScriptRecordMode.values);
    box.write(ScriptConfig.keySelectedScriptType, selectedScriptRecordMode!.code);

    // 加载目录下的文件
    if (selectedScriptRecordMode != null) {
      scriptNameList = await loadScriptsByType(selectedScriptRecordMode!.resourceId);
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

    WindowsApp.autoTpModel.selectRoute(value);

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
      scriptNameList = await loadScriptsByType(selectedScriptRecordMode!.resourceId);
      selectFirstFile(scriptNameList);
    }
  }

  Future<void> selectFirstDir() async {
    selectedScriptRecordMode = ScriptRecordMode.autoTp;

    // 加载目录下的文件
    scriptNameList = await loadScriptsByType(selectedScriptRecordMode!.resourceId);
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

    WindowsApp.autoTpModel.loadRoutes();
    notifyListeners();
  }

  /// 标记为未保存
  void markAsUnsaved() {
    isUnsaved = true;
    notifyListeners();
  }

  /// 显示脚本信息的模态框
  void showScriptInfo(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) =>
          Consumer<ScriptEditorModel>(builder: (context, model, child) {
        return ContentDialog(
          title: WinText('脚本信息'),
          content: Padding(
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
                      Expanded(
                          child: WinText(
                              WindowsApp.autoTpModel.errorMessage ?? '')),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          actions: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                showDeleteScriptModel(context);
              },
              child: const WinText('删除'),
            ),
            Button(
              child: const WinText('关闭'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }),
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

  void showDeleteScriptModel(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) =>
          Consumer<ScriptEditorModel>(builder: (context, model, child) {
        return ContentDialog(
            title: WinText('删除脚本'),
            content: WinText('确定要删除脚本${currentScript?.scriptName}吗？'),
            actions: [
              Button(
                child: const WinText('取消'),
                onPressed: () {
                  Navigator.pop(context); // 关闭模态框
                },
              ),
              FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const WinText('确定'),
                  onPressed: () {
                    model.deleteScript();
                    Navigator.pop(context); // 关闭模态框
                  })
            ]);
      }),
    );
  }
}
