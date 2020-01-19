import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;

import 'bj_actions.dart' show Dispatch, NavAction;

class HomePageVu extends StatelessWidget {
  final Dispatch dispatch;

  HomePageVu({Key key, @required this.dispatch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Blackjack - Home"),
        ),
        body: SafeArea(
            minimum: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  "images/blackjack-1.jpg",
                  fit: BoxFit.contain,
                  matchTextDirection: true,
                  alignment: AlignmentDirectional.topCenter,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 60),
                  child: RaisedButton(
                    child: Text(NavAction.game1.title),
                    onPressed: () => dispatch(NavAction.game1),
                  ),
                ),
                RaisedButton(
                  child: Text(NavAction.game2.title),
                  onPressed: () => dispatch(NavAction.game2),
                )
              ],
            )));
  }
}
