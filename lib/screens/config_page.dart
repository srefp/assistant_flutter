import 'package:assistant/notifier/config_model.dart';
import 'package:assistant/screens/auto_tp.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../components/win_text.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigModel>(builder: (context, model, child) {
      return CustomScrollView(
        slivers: [
          CustomSliverBox(
            child: const SizedBox(
              height: 12,
            ),
          ),
          CustomSliverBox(
            child: WinText(
              '快捷键（这个功能还在开发中）',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          CustomSliverBox(child: SizedBox(height: 16)),
          CustomSliverBox(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 400,
                    height: 34,
                    child: TextBox(
                      controller: model.searchController,
                      placeholder: '搜索快捷键',
                      style: TextStyle(fontFamily: fontFamily),
                      onChanged: (value) =>
                          model.searchConfigItems(value),
                    ),
                  )
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: ListView.builder(
              itemCount: model.displayedConfigItems.length,
              itemBuilder: (context, index) {
                final item = model.displayedConfigItems[index];
                return HotkeyConfigRow(
                  item: item,
                  lightText: model.lightText,
                );
              },
              shrinkWrap: true,
            ),
          )
        ],
      );
    });
  }
}
