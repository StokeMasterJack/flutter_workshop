import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card, Action;

import 'bj.dart';
import 'bj_app_vu.dart';
import 'bj_common.dart';

class BjApp extends StatefulWidget {
  final bool shuffle;
  final TargetPlatform targetPlatform;

  BjApp({this.shuffle = true}) : this.targetPlatform = defaultTargetPlatform;

  @override
  BjAppState createState() => BjAppState();
}

class BjAppState extends State<BjApp> {
  Page page = Page.home;
  Game game;

  BjAppState() {
    this.game = Game.mk(shuffle: widget.shuffle);
  }

  void dispatch(Action action) {
    if (action is NavAction) {
      setState(() {
        this.page = action.page;
      });
    } else if (action is BjAction) {
      setState(() {
        this.game = game.reducer(action);
      });
    } else {
      throw StateError("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BjAppVu(page, game, dispatch, widget.targetPlatform);
  }
}
