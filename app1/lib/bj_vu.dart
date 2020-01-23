import 'package:flutter/material.dart' hide Card;

import 'bj.dart';

enum BjAction { deal, hit, stay }

typedef BjDispatch = void Function(BjAction action);

class HandsVu extends StatelessWidget {
  final Game g;

  const HandsVu(this.g);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[HandVu(g.ph), HandVu(g.dh)],
    );
  }
}

class HandVu extends StatelessWidget {
  final Hand hand;

  const HandVu(this.hand);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Text(hand.title), CardsVu(hand.cards), Text(hand.msg)]);
  }
}

class CardVu extends StatelessWidget {
  final Card c;

  const CardVu(this.c);

  @override
  Widget build(BuildContext context) => Text(c.name);
}

class CardsVu extends StatelessWidget {
  final List<Card> cards;

  CardsVu(this.cards);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = cards.map((c) => CardVu(c)).toList();
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}

class BjButton extends StatelessWidget {
  final String text;
  final BjAction action;
  final BjDispatch dispatch;
  final bool isDisabled;

  BjButton(this.text, this.action, this.dispatch, {this.isDisabled})
      : assert(text != null),
        assert(action != null),
        assert(dispatch != null);

  @override
  Widget build(BuildContext context) {
    final onPressed = () => dispatch(action);

    return Padding(
        padding: EdgeInsets.all(10),
        child: RaisedButton(
            child:
            Text(text.toUpperCase()),
            onPressed: isDisabled ? null : onPressed
        )
    );
  }
}

class ButtonsVu extends StatelessWidget {
  final BjDispatch dispatch;
  final bool isGameOver;

  const ButtonsVu(this.dispatch, this.isGameOver);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        BjButton("Deal", BjAction.deal, dispatch, isDisabled: !isGameOver),
        BjButton("Hit", BjAction.hit, dispatch, isDisabled: isGameOver),
        BjButton("Stay", BjAction.stay, dispatch, isDisabled: isGameOver)
      ],
    );
  }
}

class GameMsgVu extends StatelessWidget {
  final String gameMsg;

  const GameMsgVu(this.gameMsg);

  @override
  Widget build(BuildContext context) {
    return Text(gameMsg);
  }
}

class GameVu extends StatelessWidget {
  final Game g;
  final BjDispatch dispatch;

  GameVu(this.g, this.dispatch);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.home),
              tooltip: "Go to Home screen",
              onPressed: () {
                print("home pressed");
              },
            ),
            title: const Text("Blackjack"),
          ),
          body: Column(children: [ButtonsVu(dispatch, g.isGameOver), HandsVu(g), GameMsgVu(g.msg)]),
        ));
  }
}
