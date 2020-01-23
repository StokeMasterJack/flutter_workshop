import 'package:flutter/material.dart';

typedef AppDispatch = void Function(Page page);

class Page {
  final String type;
  final String title;

  const Page._(this.type, this.title);

  static const Page ui1 = Page._("bj1", "Blackjack - UI 1");

  static const Page ui2 = Page._("bj2", "Blackjack - UI 2");

  static const Page home = Page._("home", "Blackjack - Home"); //'Blackjack - Home'

  String get name => this.type;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => type;
}
/*
Stateful
  InheritedWidget
  Stateless
    Stateless
      Stateless
        Stateless
          Stateless



 */
class AppCtx extends InheritedWidget {
  final Page page;

  final AppDispatch dispatch;

  AppCtx({this.page, this.dispatch, Key key, Widget child})
      : assert(page != null),
        assert(dispatch != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static AppCtx of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppCtx>();
  }
}
