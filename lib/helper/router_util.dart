import 'package:go_router/go_router.dart';

import '../app/windows_app.dart';

void goBack() {
  rootNavigatorKey.currentContext!.pop();
}
