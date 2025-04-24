import 'package:fluent_ui/fluent_ui.dart';

class AppModel with ChangeNotifier {
  void changeMenu() {
    notifyListeners();
  }
}
