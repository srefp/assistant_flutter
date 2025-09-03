// 假设 TpPoint 类定义如下
import 'package:assistant/helper/script_parser.dart';

class TpPoint {
  String? id;
  List<int>? boss;
  int? delayBook;
  int? delayTrack;
  int? delayMap;
  int? delayTp;
  int? delayConfirm;
  bool? domain;
  bool? temporary;
  String? script;
  List<int>? posD;
  int? narrowD;
  List<int>? posA;
  List<int>? pos;
  int? narrow;
  bool? select;
  bool? flower;
  List<int>? drag;
  int? selectD;
  bool? flowerD;
  List<int>? dragD;
  List<int>? area;
  int? narrowA;
  int? selectA;
  bool? flowerA;
  List<int>? dragA;
  String? name;
  String? comment;

  TpPoint();

  @override
  String toString() {
    return 'TpPoints{Id: $id, '
        'Boss: $boss, '
        'DelayBook: $delayBook, '
        'DelayTrack: $delayTrack, '
        'DelayMap: $delayMap, '
        'DelayTp: $delayTp, '
        'DelayConfirm: $delayConfirm, '
        'Domain: $domain, '
        'Temporary: $temporary, '
        'Script: $script, '
        'PosD: $posD, '
        'NarrowD: $narrowD, '
        'PosA: $posA, '
        'Pos: $pos, '
        'Narrow: $narrow, '
        'Select: $select, '
        'Flower: $flower, '
        'Drag: $drag, '
        'SelectD: $selectD, '
        'FlowerD: $flowerD, '
        'DragD: $dragD, '
        'Area: $area, '
        'NarrowA: $narrowA, '
        'SelectA: $selectA, '
        'FlowerA: $flowerA, '
        'DragA: $dragA, '
        'Name: $name, '
        'Comment: $comment}';
  }
}

/// 路线文件的key
class RouteKeys {
  static const String id = "id";
  static const String name = "name";
  static const String comment = "comment";
  static const String delayBoss = "delayBoss";
  static const String delayTrack = "delayTrack";
  static const String delayMap = "delayMap";
  static const String delayTp = "delayTp";
  static const String delayConfirm = "delayConfirm";
  static const String domain = "domain";
  static const String qm = "qm";
  static const String temporary = "temporary";
  static const String script = "script";
  static const String scriptD = "scriptD";

  /// F2 传送
  static const String boss = "boss";
  static const String pos = "pos";
  static const String narrow = "narrow";
  static const String select = "select";
  static const String flower = "flower";
  static const String drag = "drag";
  static const String wheel = "wheel";

  /// 直接传送
  static const String posD = "posD";
  static const String narrowD = "narrowD";
  static const String selectD = "selectD";
  static const String flowerD = "flowerD";
  static const String dragD = "dragD";
  static const String wheelD = "wheelD";

  /// 选地区传送
  static const String area = "area";
  static const String posA = "posA";
  static const String narrowA = "narrowA";
  static const String selectA = "selectA";
  static const String flowerA = "flowerA";
  static const String dragA = "dragA";
  static const String wheelA = "wheelA";
}

class RouteUtil {
  static final RegExp keyValuePairRegex = RegExp(
      r'(\w+):\s*((?:"[^"]*")|(?:\[.*?\])|(?:-?\d+(?:\.\d+)?))'
  );

  static final Map<String, List<int>> bossMap = {
    'wxzl': [1, 1],
    'wxzf': [1, 2],
    'jds': [1, 3],
    'bfdwhbldlz': [2, 1],
    'lw': [2, 1],
    'wxzy': [2, 2],
    'csjl': [2, 3],
    'bys': [3, 1],
    'gylx': [3, 2],
    'wxzb': [3, 3],
    'mojg': [4, 1],
    'wxzh': [4, 2],
    'hcjgzl': [4, 3],
    'wxzt': [4, 3],
    'wxzs': [5, 1],
    'lyqx': [5, 2],
    'hjws': [5, 3],
    'shlxzq': [6, 1],
    // ... 其他 BossMap 项
  };

  static final Map<String, List<int>> taskMap = {
    'lx': [6, 1],
    'yjjs': [6, 2],
    'cds': [6, 3],
    'clkx': [7, 1],
    'clkq': [7, 1],
    'zzyjls': [7, 2],
    'byhtxjz': [7, 3],
    'wxzc': [8, 1],
    'fssc': [8, 2],
    'szjlz': [8, 3],
    'bfzq': [9, 1],
    'tjrhdh': [9, 2],
    'syxclfszz': [9, 3],
    'qnzzjl': [10, 1],
    'sxhr': [10, 2],
    'ysns': [10, 3],
    'mxdj': [11, 1],
    'tsnylsw': [11, 2],
    'jyrylbj': [11, 3],
    'myjbgxx': [12, 1],
    'sspjz': [12, 2],
    'ljyxdmz': [12, 3],
    'ryhlx': [13, 1],
  };

  static final Map<String, List<int>> areaMap = {
    'mengde': [1, 1],
    'md': [1, 1],
    'liyue': [1, 2],
    'ly': [1, 2],
    'daoqi': [2, 1],
    'dq': [2, 1],
    'xumi': [2, 2],
    'xm': [2, 2],
    'fengdan': [3, 1],
    'fd': [3, 1],
    'nata': [3, 2],
    'nt': [3, 2],
    'yuanxiagong': [4, 1],
    'yxg': [4, 1],
    'cengyanjuyuan': [4, 2],
    'cyjy': [4, 2],
    'cy': [4, 2],
  };

  static List<BlockItem> parseFile(String content) {
    return extractTopLevelBlocks(content);
  }

  static bool stringToBool(String str) {
    return bool.parse(str.trim());
  }

  static String stringToString(String str) {
    return str.replaceAll('"', '').trim();
  }

  static int stringToInt(String str) {
    return int.parse(str.trim());
  }

  static List<int> stringToIntList(String str) {
    List<int> res = [];
    str = str.replaceAll('[', '').replaceAll(']', '');
    List<String> tmpValues = str.split(RegExp(r', *'));
    List<String> numbers = tmpValues.where((s) => s.isNotEmpty).toList();
    for (String number in numbers) {
      res.add(int.parse(number.trim()));
    }
    return res;
  }
}
