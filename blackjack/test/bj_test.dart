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

    expect(() => new Card(value: 1, suit: 5), throwsA(TypeMatcher<AssertionError>()));
    expect(() => new Card(value: 14, suit: 1), throwsA(TypeMatcher<AssertionError>()));
  });

  test('Hand test', () {
    var h1 = Hand(isDealer: false);
    h1.add(Card(value: 1, suit: 1));
    h1.add(Card(value: 13, suit: 4));

    var h2 = Hand(isDealer: true);
    h2.add(Card(value: 1, suit: 1));
    h2.add(Card(value: 2, suit: 1));
    h2.add(Card(value: 3, suit: 1));

    expect(h1.name, "Player");
    expect(h1.points, 11);
    expect(h1.size, 2);

    expect(h2.name, "Dealer");
    expect(h2.points, 6);
    expect(h2.size, 3);
  });

  test('Deck test', () {
    var d1 = Deck(shuffle: false);
    expect(d1.size, 52);

    var c1 = d1.take();
    expect(c1.name, "A of Spades");
    expect(d1.size, 51);

    var c2 = d1.take();
    expect(c2.name, "2 of Spades");
    expect(d1.size, 50);
  });

  test('Game test', () {
    var g = Game.mk(shuffle: false);

    expect(g.deck.size, 48);
    expect(g.ph.size, 2);
    expect(g.dh.size, 2);
    expect(g.ph.points, 1 + 3);
    expect(g.dh.points, 2 + 4);
    expect(g.isGameOver, false);
//    expect(g.msg, "Press Hit or Stay");

    g.playerHit();

    expect(g.deck.size, 47);
    expect(g.ph.size, 3);
    expect(g.dh.size, 2);
    expect(g.ph.points, 1 + 3 + 5);
    expect(g.dh.points, 2 + 4);
    expect(g.isGameOver, false);
    expect(g.msg, "Press Hit or Stay");

    g.playerHit();
    expect(g.deck.size, 46);
    expect(g.ph.size, 4);
    expect(g.dh.size, 2);
    expect(g.ph.points, 1 + 3 + 5 + 6);
    expect(g.dh.points, 2 + 4);
    expect(g.isGameOver, false);
    expect(g.msg, "Press Hit or Stay");

    g.playerStay();

    expect(g.deck.size, 44);
    expect(g.ph.size, 4);
    expect(g.dh.size, 4);
    expect(g.ph.points, 1 + 3 + 5 + 6);
    expect(g.dh.points, 2 + 4 + 7 + 8);
    expect(g.isGameOver, true);
    expect(g.msg, "Dealer Wins!");

    g.deal();
    expect(g.deck.size, 40);
    expect(g.ph.size, 2);
    expect(g.dh.size, 2);
    expect(g.ph.points, 9 + 10);
    expect(g.dh.points, 10 + 10);
    expect(g.isGameOver, false);
    expect(g.msg, "Press Hit or Stay");

    g.playerHit();
    expect(g.ph.points, 29);
    expect(g.isGameOver, true);
    expect(g.msg, "Dealer Wins!");

    g.deal();
    g.deal();
    g.playerHit();
    g.playerStay();

    expect(g.isGameOver, true);
    expect(g.msg, "Player Wins!");

    for (int i = 0; i < 100; i++) {
      g.deal();
      while (g.ph.points < 19) {
        g.playerHit();
      }
      if (!g.isGameOver) {
        g.playerStay();
      }
      expect(g.ph.points > 0, true);
      expect(g.dh.points > 0, true);
    }
  });
}
