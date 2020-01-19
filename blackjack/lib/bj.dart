import 'package:meta/meta.dart';

import 'bj_actions.dart' show BjAction, BjEvent;
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

  bool get canHit => !isDone;

  int get size;

  String get name;

  int get points;

  bool get is21;

  bool get isBust;

  bool get isDone;

  String get msg;

  @override
  String toString();
}

T ensure<T>(T v) {
  if (v == null) {
    throw ArgumentError("ensure failed");
  }
  return v;
}

abstract class Hand extends IHand {
  final List<Card> _cards;
  bool _stay;

  Hand({List<Card> cards, bool stay = false})
      : this._cards = cards ?? [],
        this._stay = stay ?? false {
    ensure(_cards);
    ensure(_stay);
  }

  List<Card> cpCards() {
    return List.from(_cards);
  }

  Hand mk({List<Card> cards, bool stay});

  Hand cp({List<Card> cards, bool stay}) {
    return mk(cards: cards ?? cpCards(), stay: stay ?? this._stay);
  }

  bool get isDealer;

  IList<Card> get cards => IList(_cards);

  @Mutator()
  void clear() {
    _cards.clear();
    _stay = false;
  }

  @Mutator()
  void stay() => _stay = true;

  @Mutator()
  void add(Card card) {
    if (!canHit) {
      throw ArgumentError();
    }
    this._cards.add(card);
    if (isDone) {
      stay();
    }
  }

  bool get isDone;

  bool get canHit => !isDone;

  int get size => _cards.length;

  String get name;

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
}

class PlayerHand extends Hand {
  PlayerHand({List<Card> cards, bool stay}) : super(cards: cards, stay: stay);

  @override
  PlayerHand mk({List<Card> cards, bool stay}) {
    return PlayerHand(cards: cards, stay: stay);
  }

  bool get isDealer => false;

  bool get isDone => isStay || points >= 21;

  String get name => "Player";
}

class DealerHand extends Hand {
  DealerHand({List<Card> cards, bool stay}) : super(cards: cards, stay: stay);

  @override
  DealerHand mk({List<Card> cards, bool stay}) {
    return DealerHand(cards: cards, stay: stay);
  }

  bool get isDealer => true;

  bool get isDone => isStay || points >= 17;

  String get name => "Dealer";
}

abstract class IDeck {
  IList<Card> get cards;

  bool get shuffle;

  int get size;
}

class Deck extends IDeck {
  final List<Card> _cards;
  final bool shuffle;

  Deck._({List<Card> cards, bool shuffle = true})
      : this._cards = cards ?? [],
        this.shuffle = shuffle;

  Deck.mk({bool shuffle = true})
      : this._cards = _populate([], shuffle),
        this.shuffle = shuffle;

  List<Card> cpCards() => List.from(_cards);

  IList<Card> get cards => IList(_cards);

  int get size => _cards.length;

  Card take() => _cards.removeAt(0);

  @Mutator()
  List<Card> takeCards([int n = 1]) {
    final List<Card> a = _cards.sublist(0, n);
    _cards.removeRange(0, n);
    return a;
  }

  void dump() {
    _cards.forEach((c) {
      print(c.name);
    });
    print("");
  }

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

abstract class IGame {
  static const reshuffleThreshold = 25;

  IDeck get deck;

  IHand get ph;

  IHand get dh;

  bool get isGameOver;

  String get msg;

  IGame cp();

  void dump();
}

class Game extends IGame {
  final Deck deck;
  final PlayerHand ph;
  final DealerHand dh;

  Game._({@required this.deck, @required this.ph, @required this.dh, bool doDeal = false}) {
    if (doDeal) {
      deal();
    }
  }

  Game.mk({bool shuffle = true}) : this._(deck: Deck.mk(shuffle: shuffle), ph: PlayerHand(), dh: DealerHand(), doDeal: true);

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

  @Transform()
  Game cp({Deck deck, Hand ph, Hand dh}) {
    return Game._(deck: deck ?? this.deck.cp(), ph: ph ?? this.ph.cp(), dh: dh ?? this.dh.cp());
  }

  @Transform()
  Game hitPlayer() {
    ph.add(deck.take());
    if (ph.isBust || ph.is21) {
      ph.stay();
      dh.stay();
    }
    return cp();
  }

  @Transform()
  Game playerStay() {
    ph.stay();
    if (ph.is21 || ph.isBust) {
      dh.stay();
    }
    while (!dh.isDone) {
      dh.add(deck.take());
    }
    dh.stay();
    return cp();
  }

  @Transform()
  Game deal() {
    ph.clear();
    dh.clear();
    if (deck.size < IGame.reshuffleThreshold) {
      deck.reset();
    }
    ph.add(deck.take());
    dh.add(deck.take());
    ph.add(deck.take());
    dh.add(deck.take());

    return cp();
  }

  @Transform()
  Game reducer(BjAction a) {
    switch (a.event) {
      case BjEvent.deal:
        return deal();
      case BjEvent.hit:
        return hitPlayer();
      case BjEvent.stay:
        return playerStay();
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
