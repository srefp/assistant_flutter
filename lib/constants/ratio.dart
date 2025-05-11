/// drag起手全部是往下面拖动一小段距离。
class Ratio {
  final String name;
  final int numerator;
  final int denominator;

  static final List<Ratio> ratios = [
    r169,
    r1610,
    r4318,
    r6427,
    r43,
    r54,
  ];

  static final Ratio r169 = Ratio(
    name: '16:9',
    numerator: 16,
    denominator: 9,
  );

  static final Ratio r1610 = Ratio(
    name: '16:10',
    numerator: 16,
    denominator: 10,
  );

  static final Ratio r4318 = Ratio(
    name: '43:18',
    numerator: 43,
    denominator: 18,
  );

  static final Ratio r6427 = Ratio(
    name: '64:27',
    numerator: 64,
    denominator: 27,
  );

  static final Ratio r43 = Ratio(
    name: '4:3',
    numerator: 4,
    denominator: 3,
  );

  static final Ratio r54 = Ratio(
    name: '5:4',
    numerator: 5,
    denominator: 4,
  );

  static final Ratio unknown = Ratio(
    name: 'unknown',
    numerator: 1,
    denominator: 1,
  );

  static Ratio fromWidthHeight(int width, int height) {
    for (var ratio in ratios) {
      if (ratio.match(width, height)) {
        return ratio;
      }
    }
    return unknown;
  }

  const Ratio({
    required this.name,
    required this.numerator,
    required this.denominator,
  });

  bool match(int width, int height) {
    return numerator * height == denominator * width;
  }
}
