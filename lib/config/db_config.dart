import 'config_storage.dart';

class DbConfig with ConfigStorage {
  static DbConfig to = DbConfig();
  static const prefix = 'db.';
  static const keyHost = '${prefix}host';
  static const keyDatabase = '${prefix}database';
  static const keyUsername = '${prefix}username';
  static const keyPassword = '${prefix}password';
  static const keyPort = '${prefix}port';

  String getHost() => box.read(keyHost) ?? 'localhost';

  String getDatabase() => box.read(keyDatabase) ?? 'postgres';

  String getUsername() => box.read(keyUsername) ?? 'postgres';

  String getPassword() => box.read(keyPassword) ?? 'postgres';

  int getPort() => box.read(keyPort) ?? 5432;

}
