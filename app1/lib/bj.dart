import 'dart:math';

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
  final Deck deck;
  final Hand ph = Hand(isDealer: false);
  final Hand dh = Hand(isDealer: true);

  Game({bool shuffle = true}) : deck = Deck(shuffle: shuffle) {
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
    ph.stay();
    if (ph.points < 21) {
      while (dh.points < 17) {
        dh.add(deck.take());
      }
    }
    dh.stay();
  }

  bool get isGameOver {
    return ph.points >= 21 || ph.isStay && dh.isStay;
  }

  String get msg {
    if (!isGameOver) return "Press Hit or Stay";
    if (dh.points > 21) return "Player wins!";
    if (ph.points > 21) return "Dealer wins!";
    if (ph.points >= dh.points) return "Player wins!";
    return "Dealer wins!";
  }

  void dump() {
    print("Game");
    ph.dump();
    dh.dump();
    print(msg);
  }
}

class Deck {
  List<Card> _cards;
  bool shuffle;

  Deck({this.shuffle = true}) : _cards = _mkCards(shuffle);

  Card take() {
    if (_cards.length < 20) {
      _cards = _mkCards(this.shuffle);
    }
    return _cards.removeAt(0);
  }

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
  bool _stay = false;

  bool get isStay => _stay;

  final List<Card> _cards = <Card>[];

  Hand({@required this.isDealer}) : assert(isDealer != null);

  void add(Card card) => _cards.add(card);

  List<Card> get cards => List.unmodifiable(_cards);

  int get points => _cards.fold(0, (int v, Card c) => v + c.points);

  String get name => isDealer ? "Dealer" : "Player";

  String get title => "$name Hand";

  String get msg => "$points Points";

  void clear() {
    _cards.clear();
  }

  void stay() {
    this._stay = true;
  }

  void dump() {
    print("  $name Hand");
    for (Card c in cards) {
      print("  " + c.name);
    }
    print("  $points Points");
  }
}
