import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum UI { ui1, ui2 }
enum Page { home, game1, game2 }
enum BjEvent { deal, hit, stay }

@sealed
abstract class Action {
  Type get type => runtimeType;

  const Action();

  bool get isNav => false;

  bool get isBj => false;
}

class NavAction extends Action {
  final Page page;
  final String title;

  @override
  bool get isNav => true;

  const NavAction(this.page, this.title);

  static NavAction home = NavAction(Page.home, "Home");
  static NavAction game1 = NavAction(Page.game1, "Play Game ${UI.ui1.title}");
  static NavAction game2 = NavAction(Page.game2, "Play Game ${UI.ui2.title}");
}

class BjAction extends Action {
  final BjEvent event;

  const BjAction(this.event);

  @override
  bool get isBj => true;

  static BjAction deal = BjAction(BjEvent.deal);
  static BjAction hit = BjAction(BjEvent.hit);
  static BjAction stay = BjAction(BjEvent.stay);
}

typedef Dispatch = void Function(Action action);

extension UIExt on UI {
  String get name => this.toString().split('.').last;

  String get title {
    switch (this) {
      case UI.ui1:
        return "UI 1";
      case UI.ui2:
        return "UI 2";
      default:
        throw StateError("");
    }
  }
}

class UICtx extends InheritedWidget {
  final UI ui;

  const UICtx({
    Key key,
    @required this.ui,
    @required Widget child,
  })  : assert(ui != null),
        assert(child != null),
        super(key: key, child: child);

  static UICtx _of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UICtx>();
  }

  static UI of(BuildContext context) {
    final UICtx uiCtx = _of(context);
    return uiCtx.ui;
  }

  @override
  bool updateShouldNotify(UICtx old) => ui != old.ui;
}