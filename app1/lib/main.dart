import 'package:flutter/material.dart';

import 'bj.dart';
import 'hands.dart';

void main() => runApp(GameController());

class GameController extends StatefulWidget {
  @override
  State createState() => GameControllerState();
}

class GameControllerState extends State<GameController> {
  Game g;

  @override
  void initState() {
    super.initState();
    g = Game();
  }


  void dispatch(BjAction action) {
    final Game g2 = Game.reduce(g, action);

    setState(() {
      g = g2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameVu(g, dispatch);
  }
}




enum BjAction { deal, hit, stay }

T ensure<T>(T v) {
  if (v == null) {
    throw ArgumentError("fff");
  }
  return v;
}

typedef BjDispatch = void Function(BjAction action);

class BjButton extends StatelessWidget {
  final String text;
  final BjAction action;
  final BjDispatch dispatch;

  BjButton(this.text, this.action, this.dispatch)
      : assert(text != null),
        assert(action != null),
        assert(dispatch != null);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10), child: RaisedButton(child: Text(text.toUpperCase()), onPressed: () => dispatch(action)));
  }
}

class ButtonsVu extends StatelessWidget {
  final BjDispatch dispatch;

  const ButtonsVu(this.dispatch);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[BjButton("Deal", BjAction.deal, dispatch), BjButton("Hit", BjAction.hit, dispatch), BjButton("Stay", BjAction.stay, dispatch)],
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
          body: Column(children: [ButtonsVu(dispatch), HandsVu(g), GameMsgVu(g.msg)]),
        ));
  }
}
