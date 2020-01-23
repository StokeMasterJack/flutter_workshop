import 'package:meta/meta.dart';

@Immutable()
class Card {
  final int value;
  final int suit;

  Card({@required this.value, @required this.suit})
      : assert(value != null),
        assert(suit != null),
        assert(value >= 1 && value <= 13),
        assert(value >= 1 && value <= 13),
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

  @override
  bool operator ==(Object other) => identical(this, other) || other is Card && value == other.value && suit == other.suit;

  @override
  int get hashCode => index;
}

abstract class IHand {
  bool get isDealer;

  List<Card> get cards;

  int get size;

  String get name;

  int get points;

  bool get is21;

  bool get isBust;

  String get msg;
}

abstract class IGame {
  IDeck get deck;

  IHand get ph;

  IHand get dh;

  bool get isGameOver;

  String get msg;

  void dump();
}

class Hand implements IHand {
  final bool isDealer;
  final List<Card> _cards = <Card>[];
  bool _stay;

  Hand({@required this.isDealer}) : assert(isDealer != null);

  void add(Card card) => _cards.add(card);

  void stay() => _stay = true;

  List<Card> get cards => List.unmodifiable(_cards);

  int get points => _cards.fold(0, (int v, Card c) => v + c.points);

  String get name => isDealer ? "Dealer" : "Player";

  String get title => "$name Hand";

  String get msg => "$points Points";

  int get size => _cards.length;

  bool get is21 => points == 21;

  bool get isBust => points > 21;

  bool get isStay => _stay;

  void clear() {
    _cards.clear();
    _stay = false;
  }

  void dump() {
    print("  $name Hand");
    for (Card c in cards) {
      print("  " + c.name);
    }
    print("  $points Points");
  }
}

abstract class IDeck {
  int get size;
}

class Deck implements IDeck {
  List<Card> cards;
  int index;
  final bool shuffle;

  Deck._({@required this.cards, @required this.index, @required this.shuffle});

  Deck({bool shuffle = true}) : this._(cards: _mkCards(shuffle), index: 0, shuffle: shuffle);

  @override
  int get size => 52 - index;

  Card take() => cards[index++];

  void dump() => cards.forEach((c) => print(c.name));

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

  void reset() {
    cards = _mkCards(shuffle);
    index = 0;
  }
}

class Game extends IGame {
  static const reshuffleThreshold = 25;

  final Hand ph;
  final Hand dh;

  Deck _deck;

  @override
  IDeck get deck => _deck;

  Game({bool shuffle: false})
      : _deck = Deck(shuffle: shuffle),
        ph = Hand(isDealer: false),
        dh = Hand(isDealer: true) {
    deal();
  }

  bool get isGameOver {
    return ph.isStay && dh.isStay;
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

  void hit() {
    ph.add(_deck.take());
    if (ph.isBust || ph.is21) {
      ph.stay();
      dh.stay();
    }
  }

  void stay() {
    ph.stay();
    if (ph.points < 21) {
      while (dh.points <= 17) {
        dh.add(_deck.take());
      }
    }
    dh.stay();
  }

  void deal() {
    ph.clear();
    dh.clear();
    if (_deck.size < reshuffleThreshold) {
      _deck.reset();
    }
    ph.add(_deck.take());
    dh.add(_deck.take());
    ph.add(_deck.take());
    dh.add(_deck.take());
  }

  void dump() {
    ph.dump();
    print("");
    dh.dump();
    print("isGameOver: $isGameOver");
  }
}
