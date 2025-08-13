import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:assistant/model/pic_record.dart';
import 'package:excel/excel.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:provider/provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../app/windows_app.dart';
import '../components/dialog.dart';
import '../components/win_text.dart';
import '../db/pic_record_db.dart';
import '../util/date_utils.dart';
import '../util/router_util.dart';
import '../util/search_utils.dart';

class PicModel extends ChangeNotifier {
  Uint8List? imageFile;
  int? width;
  int? height;

  final searchController = TextEditingController();
  String lightText = '';
  List<PicRecord> displayedPicList = [];

  void search(String searchValue) {
    lightText = searchValue;
    if (searchValue.isEmpty) {
      displayedPicList = picList;
      notifyListeners();
      return;
    }
    final filteredList = picList
        .where((item) => searchTextList(searchValue, [item.picName]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedPicList = filteredList;
    }
    notifyListeners();
  }

  PicModel() {
    loadPicList();
  }

  loadPicList() async {
    picList = await loadAllPicRecord();
    for (var item in picList) {
      // 将base64字符串解码为Uint8List
      final bytes = base64Decode(item.image);
      // 使用OpenCV解码图片
      final mat = cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
      item.mat = mat;
    }
    displayedPicList = picList;
    notifyListeners();
  }

  List<PicRecord> picList = [];

  PicRecord? editedPic;

  bool _isNew = false;

  bool get isNew => _isNew;

  final nameTextController = TextEditingController();
  final keyTextController = TextEditingController();
  final commentTextController = TextEditingController();

  void selectPic(PicRecord value) {
    _isNew = false;

    editedPic = value;
    nameTextController.text = value.picName;
    keyTextController.text = value.key;
    commentTextController.text = value.comment;
    imageFile = base64Decode(value.image);
    width = value.width;
    height = value.height;
    notifyListeners();
  }

  void exportPic() async {
    final fileSelector = FileSelectorWindows();

    // 获取保存路径（限制为xlsx格式）
    final savePath = await fileSelector.getSaveLocation(
      options: SaveDialogOptions(
        suggestedName: '图片导出_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

      // 表头字段（与Pic属性对应）
      final headers = [
        '名称',
        '键',
        '注释',
        '图片',
        '宽度',
        '高度',
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

      // 写入图片数据
      for (final pic in picList) {
        sheet.appendRow([
          TextCellValue(pic.picName),
          TextCellValue(pic.key),
          TextCellValue(pic.comment),
          TextCellValue(pic.image),
          TextCellValue(pic.width.toString()),
          TextCellValue(pic.height.toString()),
          TextCellValue(getFormattedDateTimeFromMillis(pic.createdOn)),
          TextCellValue(getFormattedDateTimeFromMillis(pic.updatedOn)),
        ].map((e) => e as CellValue).toList());
      }

      // 保存文件
      final fileBytes = excel.encode()!;
      await File(savePath.path).writeAsBytes(fileBytes);
      dialog(title: '导出成功', content: '图片已导出至：${savePath.path}');
    } catch (e) {
      dialog(title: '导出失败', content: '导出图片时出错: $e');
    }
  }

  void importPic() async {
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

      List<PicRecord> newPics = [];
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
      final nameIndex = columnIndexMap['名称']!;
      final keyIndex = columnIndexMap['键']!;
      final commentIndex = columnIndexMap['注释']!;
      final imageIndex = columnIndexMap['图片']!;
      final widthIndex = columnIndexMap['宽度']!;
      final heightIndex = columnIndexMap['高度']!;
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
        String name = row[nameIndex]?.value?.toString() ?? '';
        String key = row[keyIndex]?.value?.toString() ?? '';
        String comment = row[commentIndex]?.value?.toString() ?? '';
        String image = row[imageIndex]?.value?.toString() ?? '';
        int width = int.parse(row[widthIndex]?.value?.toString() ?? '0');
        int height = int.parse(row[heightIndex]?.value?.toString() ?? '0');
        int? createdOn =
            parseDateTimeToMillis(row[createTimeIndex]?.value?.toString());
        int? updatedOn =
            parseDateTimeToMillis(row[updateTimeIndex]?.value?.toString());

        newPics.add(PicRecord(
          picName: name,
          key: key,
          comment: comment,
          image: image,
          width: width,
          height: height,
          createdOn: createdOn,
          updatedOn: updatedOn,
        ));
      }

      // 批量导入到数据库（假设pic_db支持批量添加）
      for (var pic in newPics) {
        // 将base64字符串解码为Uint8List
        final bytes = base64Decode(pic.image);
        // 使用OpenCV解码图片
        final mat = cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
        pic.mat = mat;
        await savePickRecord(pic); // 调用现有数据库添加方法
      }

      loadPicList(); // 刷新图片列表
      dialog(title: '导入成功', content: '成功导入${newPics.length}条图片');
    } catch (e) {
      dialog(title: '导入失败', content: '导入图片时出错: $e');
    }
  }

  void createNewPic() async {
    _isNew = true;

    PicRecord value = PicRecord(
      picName: '',
      key: '',
      comment: '',
      image: '',
      width: 0,
      height: 0,
    );

    editedPic = value;
    nameTextController.text = value.picName;
    keyTextController.text = value.key;
    commentTextController.text = value.comment;
    imageFile = null;
    width = null;
    height = null;
    notifyListeners();
  }

  void saveThisPic() async {
    if (editedPic != null && imageFile != null) {
      editedPic!.image = base64Encode(imageFile!);
      editedPic!.width = width!;
      editedPic!.height = height!;
      editedPic!.createdOn = DateTime.now().millisecondsSinceEpoch;
      editedPic!.updatedOn = DateTime.now().millisecondsSinceEpoch;
      editedPic!.picName = nameTextController.text;
      editedPic!.key = keyTextController.text;
      editedPic!.comment = commentTextController.text;
      await savePickRecord(editedPic!);
    }
    goBack();
    loadPicList();
  }

  void capturePic() async {
    await screenCapturer.capture(
      mode: CaptureMode.region,
      copyToClipboard: false,
    );

    await Future.delayed(Duration(milliseconds: 300));
    final imageBytes = await screenCapturer.readImageFromClipboard();

    final image = await decodeImageFromList(imageBytes!);
    width = image.width;
    height = image.height;

    imageFile = imageBytes;
    notifyListeners();
  }

  void deleteCurrentPic() async {
    showDialog(
      barrierDismissible: true,
      context: rootNavigatorKey.currentContext!,
      builder: (context) =>
          Consumer<PicModel>(builder: (context, model, child) {
        return ContentDialog(
            title: WinText('删除图片'),
            content: WinText('确定要删除图片${editedPic?.picName ?? ''}吗？'),
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
                    deletePickRecord(editedPic!).then((value) {
                      model.loadPicList();
                      goBack();
                      goBack();
                    });
                  })
            ]);
      }),
    );
  }
}
