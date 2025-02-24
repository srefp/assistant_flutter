import 'package:fluent_ui/fluent_ui.dart';

import '../model/tp_point.dart';

class AutoTpModel extends ChangeNotifier {
  String? selectedDir = null;
  String? selectedFile = null;
  int currentRouteIndex = 0;
  List<TpPoint> tpPoints = [];

  void setSelectedDir(String dir) {
    selectedDir = dir;
    notifyListeners();
  }

  void setSelectedFile(String file) {
    selectedFile = file;
    notifyListeners();
  }

  void setCurrentRouteIndex(int index) {
    currentRouteIndex = index;
    notifyListeners();
  }
}