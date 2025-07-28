import 'package:fluent_ui/fluent_ui.dart';

import '../db/efficient_db.dart';
import '../model/efficient.dart';
import '../util/search_utils.dart';

class EfficientModel extends ChangeNotifier {
  final searchController = TextEditingController();
  String lightText = '';
  List<Efficient> displayedEfficientList = [];
  List<Efficient> efficientList = [];

  loadEfficientList() async {
    efficientList = await loadAllEfficient();
    displayedEfficientList = efficientList;
    notifyListeners();
  }


  void searchDisplayedDelayConfigItems(String searchValue) {
    lightText = searchValue;
    if (searchValue.isEmpty) {
      displayedEfficientList = efficientList;
      notifyListeners();
      return;
    }
    final filteredList = efficientList
        .where((item) => searchTextList(searchValue, [item.name, item.comment]))
        .toList();
    if (filteredList.isNotEmpty) {
      displayedEfficientList = filteredList;
    }
    notifyListeners();
  }

  void createNewEfficient() {}

  void toggleEfficientStatus(Efficient item) {}


  void selectEfficient(Efficient value) {
  }

  void exportEfficient() {}

  void importEfficient() {}
}
