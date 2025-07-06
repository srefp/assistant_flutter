import 'dart:io';

import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/dialog.dart';
import 'package:assistant/components/win_text.dart';
import 'package:assistant/db/tp_route_db.dart';
import 'package:assistant/model/tp_route.dart';
import 'package:excel/excel.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide showDialog, FilledButton, ButtonStyle, Colors;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../app/windows_app.dart';
import '../util/date_utils.dart';
import '../util/db_helper.dart';

class ScriptManagementModel extends ChangeNotifier {
  final List<TpRoute> routes = [];

  ScriptManagementModel() {
    loadScripts();
  }

  void loadScripts() async {
    routes.clear();
    final List<Map<String, dynamic>> routeMaps =
        await db.query(TpRouteDb.tableName);
    final List<TpRoute> dbRoutes =
        routeMaps.map((e) => TpRoute.fromJson(e)).toList();
    routes.addAll(dbRoutes);
    notifyListeners();
  }

  List<DataRow> get rows {
    return routes
        .map((e) => DataRow(cells: [
              DataCell(WinText(e.scriptName)),
              DataCell(WinText(e.scriptType)),
              DataCell(WinText(e.ratio)),
              DataCell(WinText(e.videoUrl ?? '')),
              DataCell(WinText(e.author)),
              DataCell(WinText(
                  getFormattedDateFromMillis(e.createdOn ?? 0).toString())),
              DataCell(WinText(
                  getFormattedDateFromMillis(e.updatedOn ?? 0).toString())),
              DataCell(ButtonWithIcon(
                text: '删除',
                icon: Icons.delete,
                onPressed: () {
                  showDialog(
                    barrierDismissible: true,
                    context: rootNavigatorKey.currentContext!,
                    builder: (context) => Consumer<ScriptManagementModel>(
                        builder: (context, model, child) {
                      return ContentDialog(
                          title: WinText('删除脚本'),
                          content: WinText('确定要删除脚本${e.scriptName}吗？'),
                          actions: [
                            Button(
                              child: const WinText('取消'),
                              onPressed: () {
                                Navigator.pop(context); // 关闭模态框
                              },
                            ),
                            FilledButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.red),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.white),
                                ),
                                child: const WinText('确定'),
                                onPressed: () {
                                  db.delete(TpRouteDb.tableName,
                                      where: 'id = ?',
                                      whereArgs: [
                                        e.id
                                      ]).then((res) => loadScripts());
                                  Navigator.pop(context); // 关闭模态框
                                })
                          ]);
                    }),
                  );
                },
              )),
            ]))
        .toList();
  }

  void exportScript() async {
    final fileSelector = FileSelectorWindows();

    // 更新文件选择配置：扩展名改为xlsx，建议文件名带xlsx后缀
    final savePath = await fileSelector.getSaveLocation(
      options: SaveDialogOptions(
        suggestedName: '脚本导出_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      ),
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Excel文件',
          extensions: ['xlsx'], // 修改为xlsx扩展名
        ),
      ],
    );

    if (savePath != null) {
      try {
        // 创建Excel工作簿
        final excel = Excel.createExcel();
        // 添加工作表（名称自定义）
        final sheet = excel['Sheet1'];

        // 定义表头样式：加粗 + 居中
        final headerStyle = CellStyle(
          bold: true, // 加粗
          verticalAlign: VerticalAlign.Center, // 垂直居中
          backgroundColorHex: ExcelColor.blue400, // 背景色
        );

        final List<CellValue> headers = [
          '编号',
          '名称',
          '类型',
          '比例',
          '视频',
          '作者',
          '脚本',
          '创建时间',
          '更新时间'
        ].map((e) => TextCellValue(e)).toList();
        // 写入表头（对应数据表格的列顺序）
        sheet.appendRow(headers);

        sheet.setColumnWidth(7, 20); // 创建时间列
        sheet.setColumnWidth(8, 20); // 更新时间列

        for (int i = 0; i < headers.length; i++) {
          var cell = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.cellStyle = headerStyle;
        }

        // 写入数据行
        for (final route in routes) {
          sheet.appendRow(<CellValue>[
            TextCellValue(route.uniqueId),
            TextCellValue(route.scriptName),
            TextCellValue(route.scriptType),
            TextCellValue(route.ratio),
            TextCellValue(route.videoUrl ?? ''),
            TextCellValue(route.author),
            TextCellValue(route.content),
            TextCellValue(getFormattedDateTimeFromMillis(route.createdOn)),
            TextCellValue(getFormattedDateTimeFromMillis(route.updatedOn)),
          ]);
        }

        // 生成Excel字节数据
        final excelBytes = excel.encode();
        if (excelBytes != null) {
          // 写入文件（注意路径使用savePath.path）
          await File(savePath.path).writeAsBytes(excelBytes);
          dialog(title: '导出成功', content: '脚本已导出至：${savePath.path}');
        }
      } catch (e) {
        dialog(title: '导出失败', content: '导出脚本时出错: $e');
      }
    }
  }

  void importScript() async {
    final fileSelector = FileSelectorWindows();
    try {
      // 选择Excel文件
      final file = await fileSelector.openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'Excel文件',
            extensions: ['xlsx'],
          )
        ],
      );
      if (file == null) return; // 用户取消选择

      // 读取Excel文件内容
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Sheet1']; // 对应导出时的工作表名
      if (sheet == null) {
        dialog(title: '导入失败', content: '工作表"Sheet1"不存在');
        return;
      }

      // 读取表头并建立列名映射
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
      final typeIndex = columnIndexMap['类型']!;
      final ratioIndex = columnIndexMap['比例'];
      final videoIndex = columnIndexMap['视频'];
      final authorIndex = columnIndexMap['作者'];
      final contentIndex = columnIndexMap['脚本']!;
      final createTimeIndex = columnIndexMap['创建时间'];
      final updateTimeIndex = columnIndexMap['更新时间'];

      final List<String> uniqueIds = [];
      for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final row = sheet.row(rowIndex);
        if (row.isEmpty) break; // 遇到空行停止

        if (row[uniqueIdIndex] == null || row[uniqueIdIndex]?.value == null) {
          continue;
        }

        uniqueIds.add(row[uniqueIdIndex]?.value?.toString() ?? '');
      }

      final duplicateRows = await db.query(TpRouteDb.tableName,
          where: 'uniqueId in (${uniqueIds.map((e) => "'$e'").join(',')})');

      if (duplicateRows.isNotEmpty) {
        // TODO 导入时，存在重复的脚本编号，是否覆盖已有的脚本？
        dialog(title: '注意', content: '存在重复的脚本编号，是否覆盖已有的脚本？');
        return;
      }

      // 解析数据（跳过表头行，从第1行开始）
      final List<TpRoute> newRoutes = [];
      for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final row = sheet.row(rowIndex);
        if (row.isEmpty) break; // 遇到空行停止

        if (row[uniqueIdIndex] == null || row[uniqueIdIndex]?.value == null) {
          continue;
        }

        // 按列顺序解析（与导出时的表头顺序一致）
        newRoutes.add(TpRoute(
          uniqueId: row[uniqueIdIndex]?.value?.toString() ?? '',
          scriptName: row[nameIndex]?.value?.toString() ?? '',
          scriptType: row[typeIndex]?.value?.toString() ?? '',
          ratio: ratioIndex != null
              ? row[ratioIndex]?.value?.toString() ?? ''
              : '',
          videoUrl: videoIndex != null
              ? row[videoIndex]?.value?.toString() ?? ''
              : '',
          author: authorIndex != null
              ? row[authorIndex]?.value?.toString() ?? ''
              : '',
          content: row[contentIndex]?.value?.toString() ?? '',
          createdOn: createTimeIndex != null
              ? parseDateTimeToMillis(row[createTimeIndex]?.value?.toString())
              : currentMillis(),
          updatedOn: updateTimeIndex != null
              ? parseDateTimeToMillis(row[updateTimeIndex]?.value?.toString())
              : currentMillis(), // 更新时间（转换为毫秒）
        ));
      }

      // 插入数据库
      for (final route in newRoutes) {
        route.id = null;
        await db.insert(
          TpRouteDb.tableName,
          route.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore, // 冲突时忽略
        );
      }

      // 刷新数据并提示成功
      loadScripts(); // 重新加载数据
      dialog(title: '导入成功', content: '成功导入${newRoutes.length}条脚本');
    } catch (e) {
      dialog(title: '导入失败', content: '导入脚本时出错: $e');
    }
  }
}
