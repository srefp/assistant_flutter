import 'dart:io';

import 'package:assistant/component/box/win_text_box.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final String placeholder;

  const SearchBox({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Platform.isWindows ? 400 : 260,
      height: 34,
      child: WinTextBox(
        controller: searchController,
        placeholder: placeholder,
        onChanged: onChanged,
      ),
    );
  }
}
