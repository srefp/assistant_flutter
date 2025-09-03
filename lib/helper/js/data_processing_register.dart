import 'js_executor.dart';

void registerDataProcessing() {
  jsRuntime.onMessage('OffsetDateTime', offsetDateTime);
}

DateTime offsetDateTime(params) {
  final DateTime dateTime = DateTime.parse(params[0]);
  return dateTime;
}
