import 'dart:io';

import 'package:assistant/app/module/record/record_model.dart';
import 'package:excel/excel.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';
import 'package:ulid/ulid.dart';

import '../../../component/dialog.dart';
import '../../../component/text/win_text.dart';
import '../../../constant/macro_trigger_type.dart';
import '../../../constant/profile_status.dart';
import '../../../constant/script_record_mode.dart';
import '../../../helper/date_utils.dart';
import '../../../helper/router_util.dart';
import '../../../helper/search_utils.dart';
import '../../dao/macro_db.dart';
import '../../windows_app.dart';
import 'macro.dart';

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

  bool recoding = false;

  void startRecord() {
    RecordModel.instance.registerKeyMouseStream(scriptController,
        mode: ScriptRecordMode.autoScript);
    recoding = true;
    notifyListeners();
  }

  void stopRecord() {
    RecordModel.instance.unRegisterKeyMouseStream();
    recoding = false;
    notifyListeners();
  }

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
                  goBack();
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
                      goBack();
                      goBack();
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
    goBack();
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
    updateMacro(item);
  }

  void changeTriggerType(String value) {
    editedMacro?.triggerType = {
      MacroTriggerType.down.resourceId: MacroTriggerType.down,
      MacroTriggerType.downStoppable.resourceId: MacroTriggerType.downStoppable,
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
      final headers = [
        '编号',
        '名称',
        '触发键',
        '触发类型',
        '状态',
        '注释',
        '脚本内容',
        '创建时间',
        '更新时间'
      ].map((e) => TextCellValue(e)).toList();
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
          TextCellValue(macro.uniqueId),
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

      // 读取表头并建立列名映射（关键修改点1）
      final headerRow = sheet.row(0);
      final columnIndexMap = <String, int>{};
      for (int i = 0; i < headerRow.length; i++) {
        final columnName = headerRow[i]?.value?.toString().trim();
        if (columnName != null && columnName.isNotEmpty) {
          columnIndexMap[columnName] = i;
        }
      }

      // 通过列名获取对应索引
      final uniqueIdIndex = columnIndexMap['编号']!;
      final nameIndex = columnIndexMap['名称']!;
      final triggerKeyIndex = columnIndexMap['触发键']!;
      final triggerTypeIndex = columnIndexMap['触发类型']!;
      final statusIndex = columnIndexMap['状态']!;
      final commentIndex = columnIndexMap['注释']!;
      final scriptIndex = columnIndexMap['脚本内容']!;
      final createTimeIndex = columnIndexMap['创建时间']!;
      final updateTimeIndex = columnIndexMap['更新时间']!;

      // 遍历Excel行（跳过表头）
      for (var row in sheet.rows) {
        if (isHeaderRow) {
          isHeaderRow = false;
          continue;
        }

        if (row[nameIndex] == null || row[nameIndex]?.value == null) {
          continue;
        }

        // 解析行数据（按表头顺序）
        String uniqueId = row[uniqueIdIndex]?.value?.toString() ?? '';
        String name = row[nameIndex]?.value?.toString() ?? '';
        String triggerKey = row[triggerKeyIndex]?.value?.toString() ?? '';
        String triggerTypeId = row[triggerTypeIndex]?.value?.toString() ?? '';
        String statusName = row[statusIndex]?.value?.toString() ?? 'active';
        String comment = row[commentIndex]?.value?.toString() ?? '';
        String script = row[scriptIndex]?.value?.toString() ?? '';
        int? createdOn =
            parseDateTimeToMillis(row[createTimeIndex]?.value?.toString());
        int? updatedOn =
            parseDateTimeToMillis(row[updateTimeIndex]?.value?.toString());

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
          uniqueId: uniqueId,
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
      uniqueId: Ulid().toString(),
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
