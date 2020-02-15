import 'package:flutter/cupertino.dart';

typedef BjDispatch = void Function(BjAction action);

enum BjAction { deal, hit, stay }
enum UI {ui1,ui2}

class BjCtx extends InheritedWidget {
  final BjDispatch dispatch;
  final UI ui;

  BjCtx({this.dispatch, this.ui, Key key, Widget child})
      : assert(dispatch != null),
        assert(ui != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true; //todo
  }

  static BjCtx of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BjCtx>();
  }
}
