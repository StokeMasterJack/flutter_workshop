import 'package:flutter/material.dart' hide Card, Action;

import 'bj.dart';
import 'bj_common.dart';
import 'bj_views.dart';

class BjPage extends StatefulWidget {
  final bool shuffle;
  final UI ui;

  BjPage({this.shuffle = true, this.ui = UI.ui1});

  @override
  State createState() => BjPageState();
}

class BjPageState extends State<BjPage> {
  Game g;

  @override
  void initState() {
    super.initState();
    g = Game(shuffle: widget.shuffle);
  }

  void dispatch(BjAction a) {
    if (a == BjAction.deal) g.deal();
    if (a == BjAction.hit) g.hit();
    if (a == BjAction.stay) g.stay();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BjCtx(dispatch: dispatch, ui: widget.ui, child: BjPageVu(game: g, ui: widget.ui));
  }
}

class BjPageVu extends StatelessWidget {
  final IGame game;
  final UI ui;

  BjPageVu({Key key, @required this.game, @required this.ui})
      : assert(game != null),
        super(key: key);

  String get pageTitle {
    String s = ui.toString();
    String n = s[s.length - 1];
    return "Blackjack - UI $n";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
        ),
        body: SafeArea(
//            minimum: EdgeInsets.fromLTRB(0.0, 20.0, 20.0, 0.0),
            child: GameVu(g: game)));
  }
}
