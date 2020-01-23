import 'package:flutter/material.dart';

import 'bj.dart';
import 'bj_vu.dart';

Game reducer(Game g1, BjAction a) {
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

class GameController extends StatefulWidget {
  final bool shuffle;

  GameController({this.shuffle = true});

  @override
  State createState() => GameControllerState();
}

class GameControllerState extends State<GameController> {
  Game g;

  @override
  void initState() {
    super.initState();
    g = Game(shuffle: widget.shuffle);
  }

  void dispatch(BjAction action) {
    final Game g2 = reducer(g, action);

    setState(() {
      g = g2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameVu(g, dispatch);
  }
}
