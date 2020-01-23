import 'package:flutter/material.dart' hide Card, Action;

import 'app_common.dart';
import 'bj.dart';
import 'bj_common.dart';
import 'bj_views.dart';

class BjPage extends StatefulWidget {
  final bool shuffle;

  BjPage({this.shuffle = true});

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
    AppCtx appCtx = AppCtx.of(context);
    return BjCtx(dispatch: dispatch, ui: appCtx.page, child: BjPageVu(game: g));
  }


}

class BjPageVu extends StatelessWidget {
  final IGame game;

  BjPageVu({Key key, @required this.game})
      : assert(game != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppCtx appCtx = AppCtx.of(context);
    final Page page = appCtx.page;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.home), tooltip: 'Home', onPressed: () => appCtx.dispatch(Page.home)),
          title: Text(page.title),
        ),
        body: SafeArea(
//            minimum: EdgeInsets.fromLTRB(0.0, 20.0, 20.0, 0.0),
            child: GameVu(g: game)));
  }
}
