class MouseEvent {
  final int x;
  final int y;
  final String name;
  final bool down;
  final MouseEventType type;

  MouseEvent(this.x, this.y, this.name, this.down, this.type);
}

enum MouseEventType {
  leftButtonUp,
  leftButtonDown,
  rightButtonUp,
  rightButtonDown,
  x1ButtonDown,
  x1ButtonUp,
  x2ButtonDown,
  x2ButtonUp,
  middleButtonDown,
  middleButtonUp,
  wheelUp,
  wheelDown,
}
