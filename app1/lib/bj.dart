import 'dart:math';

import 'package:app1/main.dart';
import 'package:meta/meta.dart';

class Card {
  final int value; //1-13
  final int suit; //1-4

  const Card({@required this.value, @required this.suit})
      : assert(value != null, "value is a required parameter"),
        assert(suit != null, "suit is a required parameter"),
        assert(value >= 1 && value <= 13, "Bad value: $value"),
        assert(suit >= 1 && suit <= 4, "Bad suit: $suit");

  String get valueName {
    if (value == 1)
      return "A";
    else if (value >= 2 && value <= 10)
      return value.toString();
    else if (value == 11)
      return "J";
    else if (value == 12)
      return "Q";
    else if (value == 13)
      return "K";
    else
      throw StateError("Bad value: $value");
  }

  String get suitName {
    switch (suit) {
      case 1:
        return "Spades";
      case 2:
        return "Hearts";
      case 3:
        return "Clubs";
      case 4:
        return "Diamonds";
      default:
        throw StateError("Bad suit: $suit");
    }
  }

  String get name => "$valueName of $suitName";

  int get points => min(value, 10);
}

class Game {
  final Deck deck = Deck();
  final Hand ph = Hand(isDealer: false);
  final Hand dh = Hand(isDealer: true);

  Game() {
    deal();
  }

  void deal() {
    ph.clear();
    dh.clear();
    ph.add(deck.take());
    dh.add(deck.take());
    ph.add(deck.take());
    dh.add(deck.take());
  }

  void hit() {
    ph.add(deck.take());
  }

  void stay() {
    while (dh.points < 17) {
      dh.add(deck.take());
    }
  }

  static Game reduce(Game g1, BjAction a) {
    if (a == BjAction.deal) {
      g1.deal();
    } else if (a == BjAction.hit) {
      g1.hit();
    } else if (a == BjAction.stay) {
      g1.stay();
    } else {
      throw StateError("");
    }
    return g1;
  }

  final String msg = "Press Hit or Stay";

  void dump() {
    print("Game");
    ph.dump();
    dh.dump();
    print(msg);
  }
}

class Deck {
  final List<Card> _cards;

  Deck({bool shuffle = true}) : _cards = _mkCards(shuffle);

  Card take() => _cards.removeAt(0);

  static List<Card> _mkCards(bool shuffle) {
    final a = <Card>[];
    for (int s = 1; s <= 4; s++) {
      for (int v = 1; v <= 13; v++) {
        a.add(Card(value: v, suit: s));
      }
    }
    if (shuffle) {
      a.shuffle();
    }
    return a;
  }
}

class Hand {
  final bool isDealer;

  final List<Card> _cards = <Card>[];

  Hand({@required this.isDealer}) : assert(isDealer != null);

  void add(Card card) => _cards.add(card);

  List<Card> get cards => List.unmodifiable(_cards);

//  List<Card> get cards => _cards;

  int get points => _cards.fold(0, (int v, Card c) => v + c.points);

  String get name => isDealer ? "Dealer" : "Player";

  String get title => "$name Hand";

  String get msg => "$points Points";

  void clear() {
    _cards.clear();
  }

  void dump() {
    print("  $name Hand");
    for (Card c in cards) {
      print("  " + c.name);
    }
    print("  $points Points");
  }
}
