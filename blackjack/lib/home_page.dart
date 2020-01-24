import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Card;

import 'app_common.dart';
import 'ss_util.dart';

class HomePageVu extends StatelessWidget {
  HomePageVu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppCtx appCtx = ensure(AppCtx.of(context));
    Page page = appCtx.page;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.home), tooltip: 'Home', onPressed: () => appCtx.dispatch(Page.home)),
          title: Text(page.title),
        ),
        body: SafeArea(
            minimum: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  "images/blackjack-2.png",
                  fit: BoxFit.contain,
                  matchTextDirection: true,
                  alignment: AlignmentDirectional.topCenter,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 60),
                  child: RaisedButton(
                    child: Text(Page.ui1.title.toUpperCase()),
//                    onPressed: () => appCtx.dispatch(Page.ui1),
                    onPressed: () => Navigator.pushNamed(context, Page.ui1.name),
                  ),
                ),
                RaisedButton(
                  child: Text(Page.ui2.title.toUpperCase()),
//                  onPressed: () => appCtx.dispatch(Page.ui2),
                  onPressed: () => Navigator.pushNamed(context, Page.ui2.name),
                )
              ],
            )));
  }
}
