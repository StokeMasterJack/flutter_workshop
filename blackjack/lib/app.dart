import 'package:blackjack/ss_themes.dart';
import 'package:flutter/material.dart';

import 'bj_common.dart';
import 'bj_page.dart';
import 'home_page.dart';

class Rt {
  static const home = Rt._("/");
  static const ui1 = Rt._("/ui1");
  static const ui2 = Rt._("/ui2");

  Rt get initialRoute => home;

  static const routes = <Rt>[home, ui1, ui2];

  final String name;

  const Rt._(this.name);

  Key get key => ValueKey(name);

  static Rt parse(String name) {
    Rt rt = routes.firstWhere((Rt rt) => rt.name == name);
    if (rt == null) {
      throw ArgumentError("Bad route: [$name]");
    }
    return rt;
  }
}

class DavePageRoute extends MaterialPageRoute {
  WidgetBuilder builder;

  DavePageRoute({this.builder}) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

class App extends StatelessWidget {
  final bool shuffle;

  App({this.shuffle = true}) : assert(shuffle != null);

  Widget mkUi1(BuildContext context) {
    return BjPage(shuffle: shuffle, ui: UI.ui1);
  }

  Widget mkUi2(BuildContext context) {
    return BjPage(shuffle: shuffle, ui: UI.ui2);
  }

  void push(BuildContext context, WidgetBuilder builder) {
    Navigator.push(context, DavePageRoute(builder: builder));
  }

  void pushUI1(BuildContext context) {
    push(context, mkUi1);
  }

  void pushUI2(BuildContext context) {
    push(context, mkUi2);
  }

  Widget mkHome(BuildContext context) {
    final dispatch = HomeDispatch(pushUI1, pushUI2);
    return HomePageVu(dispatch);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Blackjack - V1", theme: ThemeDataExt.mk(), home: Builder(builder: mkHome));
  }
}
