class KeyboardEvent {
  final String name;
  final bool down;
  final bool mocked;
  final List<String> modifiers;

  KeyboardEvent(this.name, this.down, this.mocked, this.modifiers);

  @override
  String toString() {
    if (modifiers.isNotEmpty) {
      return '${modifiers.join(' + ')} + $name';
    }
    return name;
  }

  static fromString(String str) {
    if (str.contains(' + ')) {
      final parts = str.split(' + ');
      return KeyboardEvent(
        parts[parts.length - 1],
        true,
        false,
        parts.sublist(0, parts.length - 1),
      );
    }
  }

}
