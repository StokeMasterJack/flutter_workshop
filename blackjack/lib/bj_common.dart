import 'package:flutter/cupertino.dart';

import 'app_common.dart';

typedef BjDispatch = void Function(BjAction action);

enum BjAction { deal, hit, stay }
//enum Page { ui1, ui2 }

void test1() {
//    UI.ui1;
}

//extension UIExt on UI{
//  String  get title =>
//}

class BjCtx extends InheritedWidget {
  final BjDispatch dispatch;
  final Page ui;

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
