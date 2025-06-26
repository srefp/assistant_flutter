import 'package:assistant/components/button_with_icon.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/win_text.dart';
import '../notifier/script_management_model.dart';
import 'auto_tp_page.dart';

class ScriptManagementPage extends StatelessWidget {
  const ScriptManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Consumer<ScriptManagementModel>(builder: (context, model, child) {
        return CustomScrollView(
          slivers: [
            CustomSliverBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: WinText(
                  '脚本管理',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            CustomSliverBox(
              child: SizedBox(height: 16),
            ),
            CustomSliverBox(
              child: Material(
                child: SizedBox(
                  height: 720,
                  child: DataTable2(
                    columns: [
                      DataColumn2(label: WinText('名称')),
                      DataColumn2(
                        label: WinText('类型'),
                        fixedWidth: 100,
                      ),
                      DataColumn2(
                        label: WinText('比例'),
                        fixedWidth: 90,
                      ),
                      DataColumn2(
                        label: WinText('视频'),
                        fixedWidth: 90,
                      ),
                      DataColumn2(label: WinText('作者')),
                      DataColumn2(
                        label: WinText('创建时间'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: WinText('更新时间'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: WinText('操作'),
                      ),
                    ],
                    rows: model.rows,
                  ),
                ),
              ),
            ),
            CustomSliverBox(
              child: SizedBox(height: 16),
            ),
            CustomSliverBox(
              child: Row(
                children: [
                  ButtonWithIcon(
                    text: '导出',
                    icon: Icons.output,
                    onPressed: () {
                      model.exportScript();
                    },
                  ),
                  SizedBox(width: 16), // 按钮间距
                  // 新增导入按钮
                  ButtonWithIcon(
                    text: '导入',
                    icon: Icons.input,
                    onPressed: () => model.importScript(),
                  ),
                ],
              ),
            )
          ],
        );
      });
    });
  }
}
