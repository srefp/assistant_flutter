import 'dart:io';

import 'package:assistant/components/highlight_combo_box.dart';
import 'package:assistant/components/win_text.dart';
import 'package:assistant/config/script_config.dart';
import 'package:assistant/util/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

import '../manager/screen_manager.dart';
import '../util/js_executor.dart';
import '../win32/window.dart';

class ScriptEditorModel with ChangeNotifier {
  static final String directoryPath =
      'D:/srefp/file_management/data/flutter_assets/assets/routes';

  /// 选择的目录
  String? selectedDir;

  /// 选择的文件
  String? selectedFile;

  /// 文件列表
  List<String> files = [];

  /// 文件内容
  String? fileContent;

  /// 文件是否修改且未保存
  bool isUnsaved = false;

  late CodeLineEditingController controller;
  late Function(dynamic) saveFileContent;
  List<String> directories = [];

  ScriptEditorModel() {
    directories = loadDirectories(ScriptEditorModel.directoryPath);

    // 自动选择上次选项，如果没有，则默认选择第一个
    autoSelectDir(directories);
    autoSelectFile();

    controller = CodeLineEditingController();
    controller.text = fileContent ?? '';

    controller.addListener(() {
      if (controller.text == fileContent) {
        return;
      }
      fileContent = controller.text;
      markAsUnsaved();
      saveFileContent(fileContent);
    });

    saveFileContent = debounce(
      (_) => saveFile(controller.text),
      seconds: 2,
    );
  }

  var fileType = 'lua';

  TextEditingController nameController = TextEditingController();

  bool isRunning = false;

  /// 运行js代码
  void runJs() async {
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

    // 将code中的异步函数添加await
    await runScript(code);

    isRunning = false;
    notifyListeners();
  }

  stopJs() {
    isRunning = false;
    notifyListeners();
  }

  /// 选择目录
  void selectDir(value) async {
    // 选择目录
    selectedDir = value;
    ScriptConfig.to.box.write(ScriptConfig.keySelectedDir, selectedDir);

    // 加载目录下的文件
    if (selectedDir != null) {
      files = loadFiles(directoryPath, selectedDir!);
    }

    selectFirstFile(files);
    ScriptConfig.to.box.write(ScriptConfig.keySelectedFile, selectedFile);

    notifyListeners();
  }

  /// 选择文件
  void selectFile(value) {
    selectedFile = value;
    ScriptConfig.to.box.write(ScriptConfig.keySelectedFile, selectedFile);

    if (selectedFile != null && selectedFile != null) {
      fileContent = File(join(directoryPath, selectedDir!, selectedFile!))
          .readAsStringSync();
      controller.text = fileContent ?? '';
    }

    notifyListeners();
  }

  void autoSelectDir(List<String> directories) {
    selectedDir = ScriptConfig.to.box.read(ScriptConfig.keySelectedDir);
    if (selectedDir == null) {
      selectFirstDir(directories);
    } else {
      files = loadFiles(directoryPath, selectedDir!);
      selectFirstFile(files);
    }
  }

  void selectFirstDir(List<String> directories) {
    if (directories.isNotEmpty) {
      selectedDir = directories.first;
    }

    // 加载目录下的文件
    if (selectedDir != null) {
      files = loadFiles(directoryPath, selectedDir!);
    }
  }

  void autoSelectFile() {
    selectedFile = ScriptConfig.to.box.read(ScriptConfig.keySelectedFile);
    if (selectedFile == null) {
      selectFirstFile(files);
    }

    if (selectedFile != null && selectedFile != null) {
      try {
        fileContent = File(join(directoryPath, selectedDir!, selectedFile!))
            .readAsStringSync();
        controller.text = fileContent ?? '';
      } catch (_) {}
    }
  }

  void selectFirstFile(List<String> files) {
    if (files.isNotEmpty) {
      selectedFile = files.first;
    }

    if (selectedFile != null && selectedFile != null) {
      try {
        fileContent = File(join(directoryPath, selectedDir!, selectedFile!))
            .readAsStringSync();
        controller.text = fileContent ?? '';
      } catch (_) {}
    }
  }

  /// 保存文件
  saveFile(String text) {
    File(join(directoryPath, selectedDir!, selectedFile!))
        .writeAsStringSync(text);
    isUnsaved = false;
    notifyListeners();
  }

  /// 标记为未保存
  void markAsUnsaved() {
    isUnsaved = true;
    notifyListeners();
  }

  /// 显示添加文件的模态框
  void showAddFileModel(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) =>
            Consumer<ScriptEditorModel>(builder: (context, model, child) {
              return ContentDialog(
                title: WinText('新建文件'),
                content: SizedBox(
                  height: 160,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 8),
                        child: Row(
                          children: [
                            WinText('类型：'),
                            Expanded(
                                child: HighlightComboBox(
                                    value: model.fileType,
                                    items: ['lua', 'js'])),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 8),
                        child: Row(
                          children: [
                            WinText('名称：'),
                            Expanded(
                                child:
                                    TextBox(controller: model.nameController)),
                          ],
                        ),
                      ),
                    ],
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
                    child: const WinText('确定'),
                    onPressed: () {
                      model.createFile();
                      // 处理添加文件的逻辑
                      Navigator.pop(context); // 关闭模态框
                    },
                  ),
                ],
              );
            }));
  }

  /// 创建文件
  void createFile() {
    final fileName = '${nameController.text}.$fileType';
    final filePath = join(directoryPath, selectedDir!, fileName);
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
      files.add(fileName);
      selectFile(fileName);
    }
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

List<String> loadFiles(String directoryPath, String selectedDir) {
  final List<String> files = [];
  Directory directory = Directory(join(directoryPath, selectedDir));
  if (directory.existsSync()) {
    // 列出目录下的所有实体
    final entities = directory.listSync(recursive: false);
    for (var entity in entities) {
      if (entity is File) {
        files.add(basename(entity.path));
      }
    }
  }
  return files;
}
