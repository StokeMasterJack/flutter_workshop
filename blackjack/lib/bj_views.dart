import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;

import 'bj.dart';
import 'bj_common.dart';
import 'ss_util.dart';
import 'ss_themes.dart';

class ButtonsVu extends StatelessWidget {
  final Game g;
  final Dispatch dispatch;
  final UI ui;

  ButtonsVu(this.g, this.dispatch, this.ui);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: ButtonBar(
          alignment: ui == UI.ui1 ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              child: Text("DEAL"),
              onPressed: g.isGameOver ? () => dispatch(BjAction.deal) : null,
            ),
            RaisedButton(
              child: Text("HIT"),
              onPressed: g.isGameOver ? null : () => dispatch(BjAction.hit),
            ),
            RaisedButton(
              child: Text("STAY"),
              onPressed: g.isGameOver ? null : () => dispatch(BjAction.stay),
            ),
          ],
        ),
      );
}

class GamePageVu extends StatelessWidget {
  final IGame game;
  final Dispatch dispatch;
  final UI ui;

  GamePageVu({Key key, @required this.dispatch, @required this.game, @required this.ui})
      : assert(game != null),
        assert(dispatch != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.home), tooltip: 'Home', onPressed: () => dispatch(NavAction.home)),
          title: Text("Blackjack - ${NavAction.home.title}"),
        ),
        body: SafeArea(
//            minimum: EdgeInsets.fromLTRB(0.0, 20.0, 20.0, 0.0),
            child: GameVu(dispatch: dispatch, g: game, ui: ui)));
  }
}

class GameVu extends StatelessWidget {
  final IGame g;
  final Dispatch dispatch;
  final UI ui;

  GameVu({Key key, @required this.dispatch, @required this.g, @required this.ui})
      : assert(g != null),
        assert(dispatch != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final double hp = this.ui == UI.ui1 ? 0.0 : 5.0;
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 20, left: hp, right: hp),
      child: Column(
        children: <Widget>[ButtonsVu(g, dispatch, ui), HandsVu(ph: g.ph, dh: g.dh, ui: ui), GameMsgVu(g, ui)],
      ),
    );
  }
}

class GameMsgVu extends StatelessWidget {
  final IGame g;
  final UI ui;

  GameMsgVu(this.g, this.ui);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final double leftPad = ui == UI.ui1 ? 0 : 14;
    final AlignmentGeometry alignment = ui == UI.ui1 ? Alignment.center : Alignment.centerLeft;
    return Padding(padding: EdgeInsets.only(top: 30, left: leftPad), child: Align(alignment: alignment, child: Text(g.msg, style: themeData.gameMsg)));
  }
}

class HandsVu extends StatelessWidget {
  final IHand ph;
  final IHand dh;
  final UI ui;

  const HandsVu({@required this.ph, @required this.dh, @required this.ui});

  Widget build1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 0, right: 0),
      child: IntrinsicHeight(
        child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: 1, child: HandVu(hand: ph, ui: ui)),
          Expanded(flex: 1, child: HandVu(hand: dh, ui: ui)),
        ]),
      ),
    );
  }

  Widget build2(BuildContext context) {
    return Container(
//      padding: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      constraints: BoxConstraints.tightForFinite(),
      child: Column(children: [
        HandVu(hand: ph, ui: ui),
        SizedBox(height: 22, width: 3),
        HandVu(hand: dh, ui: ui),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => ui == UI.ui1 ? build1(context) : build2(context);
}

class CardsVu extends StatelessWidget {
  final IList<Card> cards;
  final UI ui;

  CardsVu({@required this.cards, @required this.ui});

  Widget _mkCardVu(MapEntry<int, Card> e) {
    final int index = e.key;
    final Card c = e.value;
    final ListPos pos = cards.computeListPos(index);
    return CardVu(card: c, pos: pos, ui: ui);
  }

  Widget _build1(BuildContext context) {
    final Map<int, Card> map = cards.asMap();
    final Iterable<MapEntry<int, Card>> entries = map.entries;
    final List<Widget> cardVuWidgets = entries.map(_mkCardVu).toList();
    return Container(constraints: BoxConstraints.expand(height: 180.0), child: ListView(children: cardVuWidgets));
  }

  Widget _build2(BuildContext context) {
    final Map<int, Card> map = cards.asMap();
    final Iterable<MapEntry<int, Card>> entries = map.entries;
    final List<Widget> cardVuWidgets = entries.map(_mkCardVu).toList();

    return Container(
        height: 80,
        padding: EdgeInsets.only(top: 2, bottom: 2, left: 0, right: 0),
        margin: EdgeInsets.only(top: 2, bottom: 2),
        alignment: Alignment.centerLeft,
        child: ListView(children: cardVuWidgets, scrollDirection: Axis.horizontal));
  }

  @override
  Widget build(BuildContext context) => ui == UI.ui1 ? _build1(context) : _build2(context);
}

class CardVu extends StatelessWidget {
  final Card card;
  final ListPos pos;
  final UI ui;

  CardVu({@required this.card, @required this.pos, @required this.ui});

  Widget _build1(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(card.name, style: theme.textTheme.body1, softWrap: false);
  }

  Widget _build2(BuildContext context) {
    String path = "images/cards/${card.imageName}";
    var image = Image.asset(path, fit: BoxFit.fitWidth);
    double left = pos == ListPos.first ? 0 : 3;
    double right = pos == ListPos.last ? 0 : 3;
    return Padding(padding: EdgeInsets.only(left: left, right: right), child: image);
  }

  @override
  Widget build(BuildContext context) => ui == UI.ui1 ? _build1(context) : _build2(context);
}

class HandVu extends StatelessWidget {
  final IHand hand;
  final UI ui;

  HandVu({@required this.hand, @required this.ui});

  Widget build1(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    bool isRight = hand.isDealer;
    bool isLeft = !hand.isDealer;
    return IntrinsicHeight(
        child: Container(
      color: themeData.dividerColor.withOpacity(.05),
      padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      margin: EdgeInsets.only(top: 5, bottom: 5, left: isLeft ? 14 : 7, right: isRight ? 14 : 7),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${hand.name}", style: themeData.handNameMsg, softWrap: false),
          CardsVu(cards: hand.cards, ui: ui),
          Text(hand.msg, style: themeData.handPointsMsg, softWrap: false)
        ],
      ),
    ));
  }

  Widget build2(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      constraints: BoxConstraints(minWidth: 0.0, maxWidth: double.infinity, minHeight: 0.0, maxHeight: double.infinity),
//      color: theme.dividerColor.withOpacity(.05),
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 5),
      margin: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
      child: Column(
//        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(child: Text("${hand.name}", style: themeData.handNameMsg)),
          CardsVu(cards: hand.cards, ui: ui),
          Container(child: Text(hand.msg, style: themeData.handPointsMsg))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ui == UI.ui1 ? build1(context) : build2(context);
}
