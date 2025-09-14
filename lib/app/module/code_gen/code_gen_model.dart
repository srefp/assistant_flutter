import 'package:fluent_ui/fluent_ui.dart';
import 'package:postgres/postgres.dart';

import '../../../helper/win32/toast.dart';
import '../../config/db_config.dart';

class CodeGenModel extends ChangeNotifier {
  Connection? _connection;
  Future<Connection> get connection async {
    if (_connection != null) {
      return _connection!;
    }
    _connection = await Connection.open(
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
    return _connection!;
  }

  bool isConnecting = false;

  void testConnection() async {
    isConnecting = true;
    notifyListeners();
    try {
      _connection = await Connection.open(
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
      await _connection!.close();
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
