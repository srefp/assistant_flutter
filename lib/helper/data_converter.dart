List<int> convertDynamicListToIntList(List<dynamic> list) {
  List<int> intList = [];
  for (var item in list) {
    if (item is int) {
      intList.add(item);
    }
  }
  return intList;
}