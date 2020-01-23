import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import 'ss_util.dart';

class BJ {
  static const reshuffleThreshold = 25;
}

@sealed
class BjAction {
  final String type;

  const BjAction(this.type);

  static const BjAction deal = BjAction("deal");
  static const BjAction hit = BjAction("hit");
  static const BjAction stay = BjAction("stay");
}

@Immutable()
class Card {
  final int value;
  final int suit;

  Card({@required this.value, @required this.suit})
      : assert(value >= 1 && value <= 13),
        assert(suit >= 1 && suit <= 4);

  int get index => (suit - 1) * 13 + (value - 1);

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

  String get valueNameLong {
    if (value == 1)
      return "Ace";
    else if (value >= 2 && value <= 10)
      return value.toString();
    else if (value == 11)
      return "Jack";
    else if (value == 12)
      return "Queen";
    else if (value == 13)
      return "King";
    else
      throw StateError("Bad value: $value");
  }

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

  String get name => "$valueName of $suitName";

  int get points {
    if (value == 1)
      return 1;
    else if (value >= 2 && value <= 10)
      return value;
    else if (value > 10 && value <= 13) {
      return 10;
    } else {
      throw StateError("Bad value: $value");
    }
  }

  String get imageName {
    String vChar = value != 10 ? valueName[0] : "t";
    String sChar = suitName[0];
    return "$vChar$sChar.gif".toLowerCase();
  }

//  int get index => ((suit - 1) * 4) + value;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Card && index == other.index;

  @override
  int get hashCode => index;
}

abstract class IHand {
  const IHand();

  bool get isDealer;

  List<Card> get cards;

  int get size;

  String get name;

  int get points;

  bool get is21;

  bool get isBust;

  String get msg;
}

abstract class IDeck {
  List<Card> get cards;

  bool get shuffle;

  int get size;
}

abstract class IGame {
  IDeck get deck;

  IHand get ph;

  IHand get dh;

  bool get isGameOver;

  String get msg;

  void dump();
}

//class Cards {
//  final List<Card> cards;
//  final bool shuffle;
//
//  @override
//  final int hashCode;
//
//  Cards._(this.cards, this.shuffle, this.hashCode);
//
//  factory Cards(bool shuffle) {
//    final a = _mkCards(shuffle);
//    final hash = shuffle ? hashCodeList(a) : 0;
//    return Cards._(a, shuffle, hash);
//  }
//
//  static List<Card> _mkCards(bool shuffle) {
//    final a = List(52);
//    for (int s = 1; s <= 4; s++) {
//      for (int v = 1; v <= 13; v++) {
//        int index = (s - 1) * 13 + (v - 1);
//        a[index] = Card(value: v, suit: s);
//        a.add(Card(value: v, suit: s));
//      }
//    }
//    if (shuffle) {
//      a.shuffle();
//    }
//    return List.unmodifiable(a);
//  }
//
////  @override
////  bool operator ==(Object other) => ListEquality().equals(a, other.)
//}

//void test1() {
//  final Hash h = Hash();
//}

class Hand extends IHand {
  final bool isDealer;
  final List<Card> _cards;
  bool _stay;

  Hand._({List<Card> cards, bool stay, bool isDealer})
      : this._cards = cards ?? [],
        this._stay = stay ?? false,
        this.isDealer = isDealer ?? false {
    ensure(_cards);
    ensure(_stay);
  }

  factory Hand({bool isDealer = false}) => Hand._(isDealer: isDealer);

  List<Card> cpCards() {
    return List.from(_cards);
  }

  Hand cp({List<Card> cards, bool stay}) {
    return Hand._(cards: cards ?? cpCards(), stay: stay ?? this._stay);
  }

  String get name => isDealer ? "Dealer" : "Player";

  IList<Card> get cards => IList(_cards);

  @Mutator()
  void clear() {
    _cards.clear();
    _stay = false;
  }

  @Mutator()
  void stay() => _stay = true;

  bool get canHit {
    if (isStay) return false;
    final int pMax = isDealer ? 17 : 21;
    return points <= pMax;
  }

  @Mutator()
  void add(Card card) {
    if (!canHit) {
      throw ArgumentError();
    }
    this._cards.add(card);
  }

  int get size => _cards.length;

  int get points => _cards.total((c) => c.points);

  bool get is21 => points == 21;

  bool get isBust => points > 21;

  bool get isStay => _stay;

  @override
  String toString() {
    return "$name Hand";
  }

  String get msg {
    return "$points Points";
  }

  @Effect()
  void dump() {
    print("$name Hand");
    cards.forEach((c) {
      print(c.name);
    });
    print("$points points");
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Hand) {
      return isDealer == other.isDealer && _stay == other._stay && _cards == other._cards;
      ;
    } else {
      return false;
    }

//    }
//        other is Hand &&
//            runtimeType == other.runtimeType && isDealer == other.isDealer && _cards == other._cards && _stay == other._stay;
  }

  @override
  int get hashCode => isDealer.hashCode ^ _cards.hashCode ^ _stay.hashCode;
}

class Deck extends IDeck {
  final List<Card> cards;
  int index;
  final bool shuffle;

  Deck._({@required this.cards, @required this.index, @required this.shuffle});

  factory Deck({bool shuffle = true}) => Deck._(cards: mkCards(), index: 0, shuffle: shuffle);

  int get size => 52 - index;

  @Mutator()
  Card take() => cards[index++];

  void dump() {
    for (Card c in cards) {
      print(c.name);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Deck && runtimeType == other.runtimeType && _cards == other._cards && shuffle == other.shuffle;

  @override
  int get hashCode => _cards.hashCode ^ shuffle.hashCode;

  static List<Card> _populate(List<Card> a, bool shuffle) {
    assert(a != null);
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

  @Mutator()
  void reset() {
    _cards.clear();
    _populate(_cards, this.shuffle);
  }

  cp({List<Card> cards, bool shuffle}) {
    return Deck._(cards: cards ?? cpCards(), shuffle: shuffle ?? this.shuffle);
  }
}

//todo - inomplete
//class Deck2 extends IDeck {
//  final IList<Card> _cards;
//  final bool shuffle;
//  final int index;
//
//  Deck2._({IList<Card> cards, int index, bool shuffle = true})
//      : this._cards = ensure(cards),
//        this.index = ensure(index),
//        this.shuffle = shuffle;
//
//  factory Deck2({bool shuffle = true}) {
//    final a = <Card>[];
//    final IList ff = mkCards(shuffle);
//    return Deck2._(cards: ff, index: 0, shuffle: shuffle);
//  }
//
//  IList<Card> get cards => _cards;
//
//  int get size => _cards.length;
//
//  Card take() => _cards.removeAt(0);
//
//  @Mutator()
//  List<Card> takeCards([int n = 1]) {
//    final List<Card> a = _cards.sublist(0, n);
//    _cards.removeRange(0, n);
//    return a;
//  }
//
//  void dump() {
//    _cards.forEach((c) {
//      print(c.name);
//    });
//    print("");
//  }
//
//  @override
//  bool operator ==(Object other) =>
//      identical(this, other) || other is Deck && runtimeType == other.runtimeType && _cards == other._cards && shuffle == other.shuffle;
//
//  @override
//  int get hashCode => _cards.hashCode ^ shuffle.hashCode;
//

//
//    int hash;
//    if (shuffle) {
//      a.shuffle();//  static IList<Card> mkCards(bool shuffle) {
////    final a = <Card>[];
////    for (int s = 1; s <= 4; s++) {
////      for (int v = 1; v <= 13; v++) {
////        a.add(Card(value: v, suit: s));
////      }
////    }
//      hash = hashCodeList(a);
//    } else {
//      hash = 99999;
//    }
//    return IList(a);
//  }

//@Mutator()
//IDeck reset() {
//  return Deck2(shuffle: this.shuffle);
//}
//
//IDeck cp({IList<Card> cards, int index, bool shuffle}) {
//  return Deck2._(cards: cards ?? cpCards(), index: index ?? this.index, shuffle: shuffle ?? this.shuffle);
//}}
//
//
//}

class Game extends IGame {
  final Deck _deck;
  final Hand ph;
  final Hand dh;

  Game._({@required Deck deck, @required this.ph, @required this.dh, bool doDeal = false}) : _deck = deck {
    if (doDeal) {
      deal();
    }
  }

  factory Game({bool shuffle = true, bool deal = true}) {
    final deck = Deck(shuffle: shuffle);
    final ph = Hand(isDealer: false);
    final dh = Hand(isDealer: true);
    Game g = Game._(deck: deck, ph: ph, dh: dh);
    return deal ? g.deal() : g;
  }

  bool get isGameOver {
    return ph.isStay && dh.isStay;
  }

  IDeck get deck => _deck;

  String get msg {
    if (!isGameOver) {
      return "Press Hit or Stay";
    } else if (ph.isBust && !dh.isBust) {
      return "Dealer Wins!";
    } else if (dh.isBust && !ph.isBust) {
      return "Player Wins!";
    } else if (ph.points >= dh.points) {
      return "Player Wins!";
    } else {
      return "Dealer Wins!";
    }
  }

  @Transform()
  Game cp({Deck deck, Hand ph, Hand dh}) {
    return Game._(deck: deck ?? this._deck.cp(), ph: ph ?? this.ph.cp(), dh: dh ?? this.dh.cp());
  }

  @Transform()
  Game hitPlayer() {
    ph.add(_deck.take());
    if (ph.isBust || ph.is21) {
      ph.stay();
      dh.stay();
    }
    return cp();
  }

  /*

    if (ph2.is21 || ph2.isBust) {
      return cp(g, ph: ph2.stay(), dh: dh2.stay());
    }
   */
  @Transform()
  Game playerStay() {
    ph.stay();
    if (ph.is21 || ph.isBust) {
      dh.stay();
      return cp();
    }

    while (dh.points <= 17) {
      dh.add(_deck.take());
    }
    dh.stay();
    return cp();
  }

  @Transform()
  Game deal() {
    ph.clear();
    dh.clear();
    if (_deck.size < BJ.reshuffleThreshold) {
      _deck.reset();
    }
    ph.add(_deck.take());
    dh.add(_deck.take());
    ph.add(_deck.take());
    dh.add(_deck.take());

    return cp();
  }

  @Transform()
  static Game reducer(Game g, BjAction a) {
    switch (a) {
      case BjAction.deal:
        return g.deal();
      case BjAction.hit:
        return g.hitPlayer();
      case BjAction.stay:
        return g.playerStay();
      default:
        throw StateError("");
    }
  }

  void dump() {
    ph.dump();
    print("");
    dh.dump();
    print("isGameOver: $isGameOver");
  }
}
