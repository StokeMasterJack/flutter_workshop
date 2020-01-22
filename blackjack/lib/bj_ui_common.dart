import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'bj_action.dart';
import 'ss_util.dart';

//class PageCtx extends InheritedWidget {
//  final Page page;
//
//  const PageCtx({
//    Key key,
//    @required this.page,
//    @required Widget child,
//  })  : assert(page != null),
//        assert(child != null),
//        super(key: key, child: child);
//
//  static PageCtx _of(BuildContext context) {
//    return context.dependOnInheritedWidgetOfExactType<PageCtx>();
//  }
//
//  static Page of(BuildContext context) {
//    final PageCtx ctx = _of(context);
//    return ctx.page;
//  }
//
//  @override
//  bool updateShouldNotify(PageCtx old) => page != old.page;
//}

class ACtx {
  final Page page;
  final Dispatch dispatch;

  const ACtx(this.dispatch, this.page)
      : assert(dispatch != null),
        assert(page != null);

  @override
  String toString() {
    return "page: $page (${identityHashCode(page)})  dispatch: ${identityHashCode(dispatch)}";
  }

  @override
  int get hashCode => page.hashCode ^  dispatch.hashCode;

  @override
  bool operator ==(other) {
    return identical(this, other) || other is ACtx && runtimeType == other.runtimeType && page == other.page && dispatch == other.dispatch;
  }

  ACtx cp(Page page) {
    return ACtx(this.dispatch, page);
  }
}

class AppCtx extends InheritedWidget {
  final ACtx aCtx;

  const AppCtx({
    Key key,
    @required this.aCtx,
    @required Widget child,
  })  : assert(aCtx != null),
        assert(child != null),
        super(key: key, child: child);

  static AppCtx _of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppCtx>();
  }

  static ACtx of(BuildContext context) {
    print(111);
    assert(context != null);
    final AppCtx appCtx = _of(context);
    assert(appCtx != null);
    print(222);
    final ACtx aCtx = appCtx.aCtx;
    assert(aCtx != null);
    print(333);
    return aCtx;
  }

  @override
  bool updateShouldNotify(AppCtx old) => aCtx != old.aCtx;
}
