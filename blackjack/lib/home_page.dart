import 'package:blackjack/ss_util_flutter.dart';
import 'package:flutter/material.dart' hide Card;

class HomeDispatch {
  NavPush pushUI1;
  NavPush pushUI2;

  HomeDispatch(this.pushUI1, this.pushUI2);
}

class HomePageVu extends StatelessWidget {
  final HomeDispatch dispatch;

  HomePageVu(this.dispatch);

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
                  "images/blackjack-2.png",
                  fit: BoxFit.contain,
                  matchTextDirection: true,
                  alignment: AlignmentDirectional.topCenter,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 60),
                  child: RaisedButton(
                    child: Text("Blackjack - UI 1"),
                    onPressed: () => dispatch.pushUI1(context),
                  ),
                ),
                RaisedButton(
                  child: Text("Blackjack - UI 2"),
                  onPressed: () => dispatch.pushUI2(context),
                )
              ],
            )));
  }
}
