import 'package:test/test.dart';

import '../lib/bj.dart';

void main() {
  test('Card test', () {
    var c1 = Card(value: 1, suit: 1);
    var c2 = Card(value: 13, suit: 4);

    expect(c1.value, 1);
    expect(c1.suit, 1);
    expect(c1.suitName, "Spades");
    expect(c1.valueName, "A");
    expect(c1.name, "A of Spades");
    expect(c1.points, 1);

    expect(c2.value, 13);
    expect(c2.suit, 4);
    expect(c2.suitName, "Diamonds");
    expect(c2.valueName, "K");
    expect(c2.name, "K of Diamonds");
    expect(c2.points, 10);

    expect(() => Card(value: 1, suit: 5), throwsA(TypeMatcher<AssertionError>()));
    expect(() => Card(value: 14, suit: 1), throwsA(TypeMatcher<AssertionError>()));
  });

  test('Game test', () {
    final g = Game(shuffle: false);
    g.dump();
    print("");
    g.hit();
    g.dump();
  });
}
