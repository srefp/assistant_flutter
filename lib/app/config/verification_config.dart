import 'config_storage.dart';

class VerificationConfig with ConfigStorage {
  static VerificationConfig to = VerificationConfig();
  static const keyVerificationServer = 'verificationServer';

  String verificationServer() =>
      box.read(keyVerificationServer) ?? '8.137.95.155';
}
