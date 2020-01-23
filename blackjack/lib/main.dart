import 'package:flutter/material.dart' hide Card;

import 'app_common.dart';
import 'bj_page.dart';
import 'home_page.dart';
import 'ss_themes.dart';

void main() {
  runApp(App(shuffle: false));
}

class App extends StatefulWidget {
  final bool shuffle;

  App({this.shuffle = true}) : assert(shuffle != null);

  @override
  State createState() => AppState();
}

class AppState extends State<App> {
  Page page;

  @override
  void initState() {
    super.initState();
    page = Page.home;
  }

  void appDispatch(Page page) {
    setState(() {
      this.page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
//    var pf = defaultTargetPlatform;
//    ThemeDataPlu

    return MaterialApp(
        title: "App",
        theme: ThemeDataExt.mk(),
        home: AppCtx(
            page: page,
            dispatch: appDispatch,
            child: AppVu(
              shuffle: widget.shuffle,
            )));
  }
}

//router
class AppVu extends StatelessWidget {
  final bool shuffle;

  AppVu({this.shuffle = true}) : assert(shuffle != null);

  @override
  Widget build(BuildContext context) {
    AppCtx appCtx = AppCtx.of(context);
    final Page page = appCtx.page;
    assert(page != null);

    if (page == Page.home) {
      return HomePageVu();
    } else if (page == Page.ui1) {
      return BjPage(
        shuffle: shuffle,
      );
    } else if (page == Page.ui2) {
      return BjPage(
        shuffle: shuffle,
      );
    } else {
      throw StateError("Bad Page value: $page");
    }
  }
}
