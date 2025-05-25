import 'package:fluent_ui/fluent_ui.dart';
import 'package:hid_listener/hid_listener.dart';

void keyListener(RawKeyEvent event) {
  //TODO
}

void mouseListener(MouseEvent event) {

}

var _listenerBackend;
initListener() {
  _listenerBackend = getListenerBackend()!;
  _listenerBackend.addKeyboardListener(keyListener);
  _listenerBackend.addMouseListener(mouseListener);
}
