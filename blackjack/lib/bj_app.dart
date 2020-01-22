import 'package:flutter/material.dart' hide Card, Action;

import 'bj.dart';
import 'bj_action.dart';
import 'bj_app_vu.dart';
import 'bj_ui_common.dart';

class BjApp extends StatefulWidget {
  final bool shuffle;

  BjApp({this.shuffle = true}) {
    print("BjApp shuffle: $shuffle");
  }

  @override
  State<BjApp> createState() => BjAppState();
}

class BjAppState extends State<BjApp> {
  Game game;

  ACtx aCtx;

  @override
  void initState() {
    super.initState();
    this.game = Game(shuffle: widget.shuffle);

    this.aCtx = ACtx((Object action) {
      print("dispatch called: $action");
      if (action is Page) {
        if (this.aCtx.page != action) {
          setState(() {
            this.aCtx = this.aCtx.cp(action);
          });
        }
      } else if (action is BjAction) {
        final g2 = Game.reducer(this.game, action);
        if (this.game != g2) {
          setState(() {
            this.game = g2;
          });
        }
      } else {
        throw StateError("Bad Action: $action");
      }
    }, Page.home);

    print("initState game: (${identityHashCode(game)})  aCtx: $aCtx");
  }

  @override
  Widget build(BuildContext context) {
    print("build game: $game  (${identityHashCode(game)})  aCtx: $aCtx");
    return AppCtx(aCtx: aCtx, child: BjAppVu(game: game, a: aCtx));
  }
}
