import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bj.dart' show IGame;
import 'bj_common.dart' show Page, Dispatch, UI, UIExt;
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
      if (p == Page.home)
        return HomePageVu(dispatch: dispatch);
      else if (p == Page.game1)
        
        return GamePageVu(dispatch: dispatch, game: game, ui: UI.ui1);
      else if (p == Page.game2)
        return GamePageVu(dispatch: dispatch, game: game, ui: UI.ui2);
      else
        throw StateError("");
    }

    final pageVu = computePageVu(page);
    return MaterialApp(title: "Blackjack Flutter", theme: themeData, home: pageVu);
  }
}
