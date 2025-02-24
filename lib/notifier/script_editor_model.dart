import 'dart:io';

import 'package:assistant/app/windows_app.dart';
import 'package:assistant/config/script_config.dart';
import 'package:assistant/util/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

import 'log_model.dart';

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

  /// js运行时
  late JavascriptRuntime jsRuntime;

  late CodeLineEditingController controller;
  late Function(dynamic) saveFileContent;
  List<String> directories = [];

  ScriptEditorModel() {
    jsRuntime = getJavascriptRuntime();
    jsRuntime.onMessage('log', (params) {
      WindowsApp.logModel.append(params['info']);
    });

    directories = loadDirectories(ScriptEditorModel.directoryPath);

    // 自动选择上次选项，如果没有，则默认选择第一个
    autoSelectDir(directories);
    autoSelectFile();

    controller = CodeLineEditingController();
    controller.text = fileContent ?? '';
    saveFileContent = debounce(
      (_) => saveFile(controller.text),
      seconds: 2,
    );
  }

  /// 运行js代码
  void runJs() {
    String code = controller.selectedText;
    if (code.isEmpty) {
      code = controller.text;
    }
    code = '''
    function log(info) {
        sendMessage('log', JSON.stringify({'info': info}));
    }
    $code
    ''';
    jsRuntime.evaluate(code);
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
      } catch (_) {}
    }
  }

  /// 保存文件
  saveFile(String text) {
    print('保存文件了');
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
