import 'package:fluent_ui/fluent_ui.dart';
import 'package:postgres/postgres.dart';

import '../../../helper/win32/toast.dart';
import '../../config/db_config.dart';

class CodeGenModel extends ChangeNotifier {
  late Connection connection;
  bool isConnecting = false;

  void testConnection() async {
    isConnecting = true;
    notifyListeners();
    try {
      connection = await Connection.open(
        Endpoint(
          host: DbConfig.to.getHost(),
          database: DbConfig.to.getDatabase(),
          username: DbConfig.to.getUsername(),
          password: DbConfig.to.getPassword(),
          port: DbConfig.to.getPort(),
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );
      await connection.close();
      showToast('数据库连接成功');
    } catch (e) {
      debugPrint(e.toString());
      showToast('数据库连接失败');
    } finally {
      isConnecting = false;
      notifyListeners();
    }
  }
}
