import 'package:flutter/material.dart' hide Card;

import 'bj.dart';

class HandsVu extends StatelessWidget {
  final Game g;

  const HandsVu(this.g);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[HandVu(g.ph), HandVu(g.dh)],
    );
  }
}

class HandVu extends StatelessWidget {
  final Hand hand;

  const HandVu(this.hand);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(hand.title), CardsVu(hand.cards), Text(hand.msg)]);
  }
}

class CardsVu extends StatelessWidget {
  final List<Card> cards;

  CardsVu(this.cards);

  @override
  Widget build(BuildContext context) {
    Widget cardToWidget(Card c) => Text(c.name);

    List<Widget> widgets = cards.map(cardToWidget).toList();
    print("cards.length[${cards.length}]");
    print("widgets.length[${widgets.length}]");

    return Column(children: widgets);
  }
}
