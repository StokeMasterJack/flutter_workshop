import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;

import 'bj_action.dart';
import 'bj_ui_common.dart';
import 'ss_util.dart';

class HomePageVu extends StatelessWidget {
  final ACtx aCtx;

  HomePageVu({Key key, this.aCtx})
      : assert(aCtx != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Dispatch dispatch = aCtx.dispatch;
    final Page page = aCtx.page;
    assert(dispatch != null);
    assert(page != null);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.home), tooltip: 'Home', onPressed: () => dispatch(Page.home)),
          title: Text(page.title + " Q!Q"),
        ),
        body: SafeArea(
            minimum: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset(
//                  "images/blackjack-1.jpg",
                  "images/blackjack-2.png",
                  fit: BoxFit.contain,
                  matchTextDirection: true,
                  alignment: AlignmentDirectional.topCenter,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 60),
                  child: RaisedButton(
                    child: Text(Page.ui1.title.toUpperCase()),
                    onPressed: () => dispatch(Page.ui1),
                  ),
                ),
                RaisedButton(
                  child: Text(Page.ui2.title.toUpperCase()),
                  onPressed: () => dispatch(Page.ui2),
                )
              ],
            )));
  }
}
