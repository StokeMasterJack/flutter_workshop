import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bj.dart' show IGame;
import 'bj_action.dart';
import 'bj_ui_common.dart';
import 'bj_views.dart' show GamePageVu;
import 'home_page.dart' show HomePageVu;
import 'ss_themes.dart' show ThemeDataExt;

class BjAppVu extends StatelessWidget {
  final IGame game;
  final ACtx a;

  BjAppVu({this.game, this.a})
      : assert(game != null),
        assert(a != null);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeDataExt.mkThemeForPlatform(defaultTargetPlatform);

    return MaterialApp(title: "Blackjack Flutter", theme: themeData, home: SwitchWidget(a, game));
  }
}

class SwitchWidget extends StatelessWidget {
  final ACtx aCtx;
  final IGame game;

  SwitchWidget(this.aCtx, this.game)
      : assert(aCtx != null),
        assert(game != null);

  @override
  Widget build(BuildContext context) {
    final Page page = aCtx.page;
    assert(page != null);
    if (page == Page.home) {
      return HomePageVu(aCtx: aCtx);
    } else if (page == Page.ui1) {
      return GamePageVu(game: game);
    } else if (page == Page.ui2) {
      return GamePageVu(game: game);
    } else {
      throw StateError("Bad Page value: $page");
    }
  }
}

//Widget computePageVu(Page p) {
//  if (p == Page.home) {
//    return HomePageVu();
//  } else if (p == Page.ui1) {
//    return GamePageVu(game: game);
//  } else if (p == Page.ui2) {
//    return GamePageVu(game: game);
//  } else {
//    throw StateError("Bad Page value: $p");
//  }
//}
