import 'dart:io';

import 'package:assistant/components/win_text.dart';
import 'package:assistant/config/script_config.dart';
import 'package:assistant/constants/ratio.dart';
import 'package:assistant/constants/script_type.dart';
import 'package:assistant/db/tp_route_db.dart';
import 'package:assistant/model/tp_route.dart';
import 'package:assistant/notifier/script_record_model.dart';
import 'package:assistant/util/db_helper.dart';
import 'package:assistant/util/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

import '../app/windows_app.dart';
import '../auto_gui/system_control.dart';
import '../manager/screen_manager.dart';
import '../util/js_executor.dart';
import '../win32/window.dart';

class ScriptEditorModel with ChangeNotifier {
  /// 选择的目录
  String? selectedScriptType;

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
    await autoSelectDir(scriptTypes);
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

  String get ratio {
    final rect = SystemControl.getCaptureRect(ScreenManager.instance.hWnd);
    return Ratio.fromWidthHeight(rect.width, rect.height).name;
  }

  /// 运行js代码
  void runJs(BuildContext context) async {
    // if (!WindowsApp.autoTpModel.isRunning) {
    //   appNotRunning(context);
    //   return;
    // }

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

    if (selectedScriptType == autoTp) {
      var autoTpCode = '';
      for (var element in code.split('\n')) {
        if (element.trim().isEmpty) {
          continue;
        }
        autoTpCode += 'await tp({${element.trim()}});\n';
      }
      await runScript(autoTpCode, addAwait: false);
    } else if (selectedScriptType == autoScript) {
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
  void selectScriptType(value) async {
    selectedScriptType = value;
    ScriptConfig.to.box
        .write(ScriptConfig.keySelectedScriptType, selectedScriptType);

    // 加载目录下的文件
    if (selectedScriptType != null) {
      scriptNameList = await loadScriptsByType(selectedScriptType!);
    }

    selectFirstFile(scriptNameList);
    ScriptConfig.to.box
        .write(ScriptConfig.keySelectedScript, selectedScriptName);

    notifyListeners();
  }

  /// 选择文件
  void selectScript(value) async {
    selectedScriptName = value;
    ScriptConfig.to.box
        .write(ScriptConfig.keySelectedScript, selectedScriptName);

    if (selectedScriptType != null && selectedScriptName != null) {
      currentScript = await loadScriptByNameAndType(
          selectedScriptType!, selectedScriptName!);
      scriptContent = currentScript?.content;
      controller.text = scriptContent ?? '';
    }

    notifyListeners();
  }

  Future<void> autoSelectDir(List<String> directories) async {
    selectedScriptType =
        ScriptConfig.to.box.read(ScriptConfig.keySelectedScriptType);
    if (selectedScriptType == null) {
      selectFirstDir(directories);
    } else {
      scriptNameList = await loadScriptsByType(selectedScriptType!);
      selectFirstFile(scriptNameList);
    }
  }

  Future<void> selectFirstDir(List<String> directories) async {
    if (directories.isNotEmpty) {
      selectedScriptType = directories.first;
    }

    // 加载目录下的文件
    if (selectedScriptType != null) {
      scriptNameList = await loadScriptsByType(selectedScriptType!);
    }
  }

  Future<void> autoSelectFile() async {
    selectedScriptName =
        ScriptConfig.to.box.read(ScriptConfig.keySelectedScript);
    if (selectedScriptName == null) {
      selectFirstFile(scriptNameList);
    }

    if (selectedScriptType != null && selectedScriptName != null) {
      try {
        currentScript = await loadScriptByNameAndType(
            selectedScriptType!, selectedScriptName!);
        scriptContent = currentScript?.content;
        controller.text = scriptContent ?? '';
      } catch (_) {}
    }
  }

  void selectFirstFile(List<String> files) async {
    if (files.isNotEmpty) {
      selectedScriptName = files.first;
    }

    if (selectedScriptType != null && selectedScriptName != null) {
      try {
        currentScript = await loadScriptByNameAndType(
            selectedScriptType!, selectedScriptName!);
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
    await updateScript(selectedScriptType!, selectedScriptName!, content);
    isUnsaved = false;
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
      context: context,
      builder: (context) =>
          Consumer<ScriptEditorModel>(builder: (context, model, child) {
        return ContentDialog(
          title: WinText('脚本信息'),
          content: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 108,
              child: Column(children: [
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
                                    child: TextBox(
                                        controller: model.nameController)),
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
                                Expanded(child: WinText(model.ratio)),
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
    await addScript(selectedScriptType!, scriptName, '');
    scriptNameList.add(scriptName);
    selectScript(scriptName);
  }

  /// 删除脚本
  void deleteScript() async {
    await deleteScriptByNameAndType(selectedScriptType!, selectedScriptName!);
    scriptNameList.remove(selectedScriptName);
    selectFirstFile(scriptNameList);
    ScriptConfig.to.box
        .write(ScriptConfig.keySelectedScript, selectedScriptName);
    notifyListeners();
  }

  void showDeleteScriptModel(BuildContext context) {
    showDialog(
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

List<String> loadDirectories(String directoryPath) {
  final List<String> files = [];
  Directory directory = Directory(directoryPath);
  if (!(directory.existsSync())) {
    directory.createSync(recursive: true);
  }
  if (directory.existsSync()) {
    // 列出目录下的所有实体
    final entities = directory.listSync(recursive: false);
    for (var entity in entities) {
      if (entity is Directory) {
        files.add(basename(entity.path));
      }
    }
  }
  return files;
}

Future<List<String>> loadScriptsByType(String selectedScriptType) async {
  // 加载脚本类别下的所有脚本名称
  final List<Map<String, Object?>> scriptNameList = await db.query(
      TpRouteDb.tableName,
      columns: ['scriptName'],
      where: 'scriptType = ?',
      whereArgs: [selectedScriptType]);
  return scriptNameList.map((e) => e['scriptName'] as String).toList();
}

/// 根据名称和类型加载脚本
Future<TpRoute> loadScriptByNameAndType(
    String scriptType, String scriptName) async {
  final List<Map<String, Object?>> scriptNameList = await db.query(
      TpRouteDb.tableName,
      where: 'scriptName = ? and scriptType = ?',
      whereArgs: [scriptName, scriptType]);
  return TpRoute.fromJson(scriptNameList.first);
}

/// 删除脚本
Future<void> deleteScriptByNameAndType(
    String scriptType, String scriptName) async {
  await db.delete(TpRouteDb.tableName,
      where: 'scriptName = ? and scriptType = ?',
      whereArgs: [scriptName, scriptType]);
}

Future<void> updateScript(
  String selectedScriptType,
  String selectedScriptName,
  String content,
) {
  return db.update(
    TpRouteDb.tableName,
    {
      'content': content,
      'updatedOn': DateTime.now().millisecondsSinceEpoch,
    },
    where: 'scriptName = ? and scriptType = ?',
    whereArgs: [selectedScriptName, selectedScriptType],
  );
}

Future<void> addScript(
  String scriptType,
  String scriptName,
  String content,
) {
  return db.insert(
    TpRouteDb.tableName,
    {
      'scriptName': scriptName,
      'scriptType': scriptType,
      'content': content,
      'ratio': '16:9',
      'remark': '',
      'author': 'srefp',
      'orderNum': 1,
      'createdOn': DateTime.now().millisecondsSinceEpoch,
      'updatedOn': DateTime.now().millisecondsSinceEpoch,
    },
  );
}
