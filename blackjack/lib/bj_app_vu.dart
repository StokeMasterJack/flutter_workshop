import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bj.dart' show IGame;
import 'bj_actions.dart' show Page, Dispatch, UI, UICtx;
import 'bj_views.dart' show GamePageVu;
import 'home_page.dart' show HomePageVu;
import 'ss_themes.dart' show ThemeDataExt;

class BjAppVu extends StatelessWidget {
  final Page page;
  final IGame game;
  final Dispatch dispatch;
  final TargetPlatform platform;

  BjAppVu(this.page, this.game, this.dispatch, this.platform);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeDataExt.mkThemeForPlatform(defaultTargetPlatform);

    Widget computePageVu(Page p) {
      if (p == Page.home) {
        return HomePageVu(dispatch: dispatch);
      } else if (p == Page.game1) {
        UI ui = UI.ui1;
        return UICtx(ui: ui, child: GamePageVu(dispatch: dispatch, game: game));
      } else if (p == Page.game2) {
        UI ui = UI.ui2;
        return UICtx(ui: ui, child: GamePageVu(dispatch: dispatch, game: game));
      } else {
        throw StateError("");
      }
    }

    final Widget pageVu = computePageVu(page);
    return MaterialApp(title: "Blackjack Flutter", theme: themeData, home: pageVu);
  }
}
