import 'dart:io';

import 'package:assistant/db/macro_db.dart';
import 'package:assistant/model/macro.dart';
import 'package:excel/excel.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';

import '../app/windows_app.dart';
import '../components/dialog.dart';
import '../components/win_text.dart';
import '../constants/macro_trigger_type.dart';
import '../constants/profile_status.dart';
import '../util/date_utils.dart';
import '../util/search_utils.dart';

class MacroModel extends ChangeNotifier {
  final searchController = TextEditingController();
  String lightText = '';
  List<Macro> displayedMacroList = [];

  void searchDisplayedDelayConfigItems(String searchValue) {
    lightText = searchValue;
    if (searchValue.isEmpty) {
      displayedMacroList = macroList;
      notifyListeners();
      return;
    }
    final filteredList = macroList
        .where((item) => searchTextList(searchValue, [item.name, item.comment]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedMacroList = filteredList;
    }
    notifyListeners();
  }

  MacroModel() {
    loadMacroList();
  }

  loadMacroList() async {
    macroList = await loadAllMacro();
    displayedMacroList = macroList;
    notifyListeners();
  }

  List<Macro> macroList = [];

  Macro? editedMacro;

  final nameTextController = TextEditingController();
  final commentTextController = TextEditingController();

  final CodeLineEditingController scriptController =
      CodeLineEditingController();

  bool _isNew = false;

  bool get isNew => _isNew;

  set isNew(bool isNew) {
    _isNew = isNew;
    notifyListeners();
  }

  void deleteCurrentMacro() {
    showDialog(
      barrierDismissible: true,
      context: rootNavigatorKey.currentContext!,
      builder: (context) =>
          Consumer<MacroModel>(builder: (context, model, child) {
        return ContentDialog(
            title: WinText('删除宏'),
            content: WinText('确定要删除宏${editedMacro?.name ?? ''}吗？'),
            actions: [
              Button(
                child: const WinText('取消'),
                onPressed: () {
                  rootNavigatorKey.currentContext!.pop();
                },
              ),
              FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const WinText('确定'),
                  onPressed: () {
                    deleteMacroById(editedMacro!.id!).then((value) {
                      model.loadMacroList();
                      rootNavigatorKey.currentContext!.pop();
                      rootNavigatorKey.currentContext!.pop();
                    });
                  })
            ]);
      }),
    );
  }

  void saveThisMicro() async {
    editedMacro?.name = nameTextController.text;
    editedMacro?.comment = commentTextController.text;
    editedMacro?.script = scriptController.text;

    if (isNew) {
      addMacro(editedMacro!).then((res) => loadMacroList());
    } else {
      updateMacro(editedMacro!).then((res) => loadMacroList());
    }
    rootNavigatorKey.currentContext!.pop();
  }

  void onScriptChanged(String script) {}

  void changeTriggerKey(key) {
    editedMacro?.triggerKey = key;
    notifyListeners();
  }

  void toggleMacroStatus(Macro item) {
    item.status = item.status == ProfileStatus.active
        ? ProfileStatus.disabled
        : ProfileStatus.active;
  }

  void changeTriggerType(String value) {
    editedMacro?.triggerType = {
      MacroTriggerType.down.resourceId: MacroTriggerType.down,
      MacroTriggerType.up.resourceId: MacroTriggerType.up,
      MacroTriggerType.longDownCycle.resourceId: MacroTriggerType.longDownCycle,
      MacroTriggerType.toggle.resourceId: MacroTriggerType.toggle,
      MacroTriggerType.longDown.resourceId: MacroTriggerType.longDown,
      MacroTriggerType.doubleDown.resourceId: MacroTriggerType.doubleDown,
    }[value]!;

    notifyListeners();
  }

  void selectMacro(Macro value) {
    _isNew = false;

    editedMacro = value;
    nameTextController.text = value.name;
    commentTextController.text = value.comment ?? '';
    scriptController.text = value.script;
    notifyListeners();
  }

  void exportMacro() async {
    final fileSelector = FileSelectorWindows();

    // 获取保存路径（限制为xlsx格式）
    final savePath = await fileSelector.getSaveLocation(
      options: SaveDialogOptions(
        suggestedName: '宏导出_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      ),
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Excel文件',
          extensions: ['xlsx'],
        ),
      ],
    );

    if (savePath == null) return; // 用户取消选择

    try {
      // 创建Excel工作簿
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1']; // 工作表名称

      // 定义表头样式（加粗+居中）
      final headerStyle = CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: ExcelColor.blue400,
      );

      // 表头字段（与Macro属性对应）
      final headers = ['名称', '触发键', '触发类型', '状态', '注释', '脚本内容', '创建时间', '更新时间']
          .map((e) => TextCellValue(e))
          .toList();
      sheet.appendRow(headers);

      // 设置表头样式
      for (int i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = headerStyle;
      }

      // 写入宏数据
      for (final macro in macroList) {
        sheet.appendRow([
          TextCellValue(macro.name),
          TextCellValue(macro.triggerKey),
          TextCellValue(macro.triggerType.resourceId), // 触发类型标识
          TextCellValue(macro.status.name), // 状态名称（active/disabled）
          TextCellValue(macro.comment ?? ''),
          TextCellValue(macro.script),
          TextCellValue(getFormattedDateTimeFromMillis(macro.createdOn)),
          TextCellValue(getFormattedDateTimeFromMillis(macro.updatedOn)),
        ].map((e) => e as CellValue).toList());
      }

      // 保存文件
      final fileBytes = excel.encode()!;
      await File(savePath.path).writeAsBytes(fileBytes);
      dialog(title: '导出成功', content: '宏已导出至：${savePath.path}');
    } catch (e) {
      dialog(title: '导出失败', content: '导出宏时出错: $e');
    }
  }

  void importMacro() async {
    final fileSelector = FileSelectorWindows();

    // 获取导入文件（限制为xlsx格式）
    final files = await fileSelector.openFiles(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Excel文件',
          extensions: ['xlsx'],
        ),
      ],
    );

    if (files.isEmpty) return; // 用户取消选择

    try {
      final file = files.first;
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first; // 读取第一个工作表

      List<Macro> newMacros = [];
      bool isHeaderRow = true;

      // 遍历Excel行（跳过表头）
      for (var row in sheet.rows) {
        if (isHeaderRow) {
          isHeaderRow = false;
          continue;
        }

        if (row[1] == null || row[1]?.value == null) {
          continue;
        }

        // 解析行数据（按表头顺序）
        String name = row[0]?.value?.toString() ?? '';
        String triggerKey = row[1]?.value?.toString() ?? '';
        String triggerTypeId = row[2]?.value?.toString() ?? '';
        String statusName = row[3]?.value?.toString() ?? 'active';
        String comment = row[4]?.value?.toString() ?? '';
        String script = row[5]?.value?.toString() ?? '';
        int? createdOn = parseDateTimeToMillis(row[6]?.value?.toString());
        int? updatedOn = parseDateTimeToMillis(row[7]?.value?.toString());

        // 转换触发类型（与现有枚举映射）
        MacroTriggerType triggerType = MacroTriggerType.values.firstWhere(
          (t) => t.resourceId == triggerTypeId,
          orElse: () => MacroTriggerType.down, // 默认值
        );

        // 转换状态（与现有枚举映射）
        ProfileStatus status = ProfileStatus.values.firstWhere(
          (s) => s.name == statusName,
          orElse: () => ProfileStatus.active, // 默认值
        );

        newMacros.add(Macro(
          name: name,
          triggerKey: triggerKey,
          triggerType: triggerType,
          status: status,
          comment: comment,
          script: script,
          createdOn: createdOn,
          updatedOn: updatedOn,
        ));
      }

      // 批量导入到数据库（假设macro_db支持批量添加）
      for (var macro in newMacros) {
        await addMacro(macro); // 调用现有数据库添加方法
      }

      loadMacroList(); // 刷新宏列表
      dialog(title: '导入成功', content: '成功导入${newMacros.length}条宏');
    } catch (e) {
      dialog(title: '导入失败', content: '导入宏时出错: $e');
    }
  }

  void createNewMacro() {
    _isNew = true;
    Macro value = Macro(
      name: '',
      triggerType: MacroTriggerType.down,
      triggerKey: '',
      comment: '',
      status: ProfileStatus.active,
      script: '',
    );

    editedMacro = value;
    nameTextController.text = value.name;
    commentTextController.text = value.comment ?? '';
    scriptController.text = value.script;
    notifyListeners();
  }
}
