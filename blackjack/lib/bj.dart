import 'package:meta/meta.dart';

import 'bj_common.dart';
import 'ss_util.dart';

@Immutable()
class Card {
  final int value;
  final int suit;

  Card({@required this.value, @required this.suit})
      : assert(value >= 1 && value <= 13),
        assert(suit >= 1 && suit <= 4);

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

  @override
  String toString() => name;
}

abstract class IHand {
  bool get isDealer;

  IList<Card> get cards;

  bool get canHit;

  int get size;

  String get name;

  int get points;

  bool get isStay;

  bool get is21;

  bool get isBust;

  bool get isDone;

  String get msg;

  @override
  String toString();
}

class Hand extends IHand {
  final bool isDealer;
  final List<Card> _cards = <Card>[];

  bool _stay = false;

  Hand({this.isDealer = false});

  IList<Card> get cards => IList(_cards);

  @Mutator()
  void clear() {
    _cards.clear();
    _stay = false;
  }

  @Mutator()
  void add(Card card) {
    _cards.add(card);
    if (!canHit) {
      _stay = true;
    }
  }

  @Mutator()
  void stay() => _stay = true;

  bool get _canHitPlayer => !_stay && points < 21;

  bool get _canHitDealer => !_stay && points < 17;

  bool get canHit => isDealer ? _canHitDealer : _canHitPlayer;

  int get size {
    return _cards.length;
  }

  String get name => isDealer ? "Dealer" : "Player";

  int get _points1 => _cards.fold(0, (prev, cur) => prev + cur.points);

  int get _points2 => _cards.total((c) => c.points);

  int get points {
    final p1 = _points1;
    final p2 = _points2;
    assert(p1 == p2);
    return p1;
  }

  bool get isStay => _stay;

  bool get is21 => points == 21;

  bool get isBust => points > 21;

  bool get isDone => _stay;

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
}

abstract class IDeck {
  IList<Card> get cards;

  bool get shuffle;

  int get size;
}

class Deck extends IDeck {
  final List<Card> _cards = [];
  final bool shuffle;

  Deck({bool shuffle = true}) : this.shuffle = shuffle {
    _populate(shuffle);
  }

  IList<Card> get cards => IList(_cards);

  int get size => _cards.length;

  @Mutator()
  Card take() {
    return _cards.removeAt(0);
  }

  void dump() {
    _cards.forEach((c) {
      print(c.name);
    });
    print("");
  }

  void _populate(bool shuffle) {
    _cards.clear();
    for (int s = 1; s <= 4; s++) {
      for (int v = 1; v <= 13; v++) {
        _cards.add(Card(value: v, suit: s));
      }
    }
    if (shuffle) {
      _cards.shuffle();
    }
  }

  @Mutator()
  void reset() {
    _populate(this.shuffle);
  }
}

abstract class IGame {
  static const reshuffleThreshold = 25;

  Deck get deck;

  Hand get ph;

  Hand get dh;

  bool get isGameOver;

  String get msg;

  Game cp();

  void dump();
}

class Game extends IGame {
  final Deck deck;
  final Hand ph;
  final Hand dh;

  Game._({@required this.deck, @required this.ph, @required this.dh, bool doDeal = false}) {
    if (doDeal) {
      deal();
    }
  }

  Game.mk({bool shuffle = true}) : this._(deck: Deck(shuffle: shuffle), ph: Hand(), dh: Hand(isDealer: true), doDeal: true);

  bool get isGameOver {
    return ph.isDone && dh.isDone;
  }

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

  Game cp() {
    return Game._(deck: this.deck, ph: this.ph, dh: this.dh);
  }

  @Mutator()
  void dealerHit() => dh.add(deck.take());

  @Mutator()
  void dealerAutoHit() {
    while (dh.canHit) {
      dealerHit();
    }
    dh.stay();
  }

  @Transform()
  Game playerHit() {
    ph.add(deck.take());
    if (ph.isBust) {
      ph.stay();
      dh.stay();
    }
    return this.cp();
  }

  @Transform()
  Game playerStay() {
    ph.stay();
    dealerAutoHit();
    return this.cp();
  }

  @Transform()
  Game deal() {
    if (deck.size < IGame.reshuffleThreshold) {
      deck.reset();
    }
    ph.clear();
    dh.clear();
    playerHit();
    dealerHit();
    playerHit();
    dealerHit();
    return this.cp();
  }

  @Transform()
  Game reducer(BjAction a) {
    Game g = this.cp();
    switch (a.event) {
      case BjEvent.deal:
        return g.deal();
      case BjEvent.hit:
        return g.playerHit();
      case BjEvent.stay:
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
