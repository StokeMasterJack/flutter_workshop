library ssutil_flutter;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil/ssutil.dart' as ss;

typedef Widget WidgetBuilder2(ScaffoldKey scaffoldKey);

typedef OnSelected<T>(BuildContext context, T value);

typedef ContextCallback(BuildContext context);
typedef ContextAction<T>(BuildContext context, T arg);

typedef ScaffoldCallback(GlobalKey<ScaffoldState> key);
typedef ScaffoldAction<T>(GlobalKey<ScaffoldState> key, T arg);

typedef Widget DataBuilder<T>(BuildContext context, T data);
typedef Widget ErrBuilder(BuildContext context, Object err);
typedef Widget NoneBuilder(BuildContext context);

Route<T> mkRoute<T>(WidgetBuilder pageBuilder) => MaterialPageRoute<T>(builder: pageBuilder);

Future<T> navPush<T>(BuildContext context, WidgetBuilder pageBuilder) {
  return Navigator.push<T>(context, mkRoute<T>(pageBuilder));
}

Future<T> navPush2<T>(BuildContext context, WidgetBuilder pageBuilder) {
  return Navigator.push<T>(context, mkRoute<T>(pageBuilder));
}


class SsGlobals {
  static bool debugLogging = false;
}

class Defaults {
  static Widget noneBuilder(BuildContext context) {
//    return new Text("ConnectionState.none");
    return new Text("");
  }

  static Widget activeBuilder(BuildContext context) {
    return new Text("ConnectionState.active");
  }

  static Widget waitBuilder(BuildContext context) {
    return new Center(child: new CircularProgressIndicator());
  }

  static Widget errBuilder(BuildContext context, Object err, {String title}) {
    ss.logError(err, title);
    final String effectiveTitle = title ?? "An error occurred";

    final List<Widget> rows = [
      new Text(effectiveTitle, style: Theme.of(context).textTheme.headline),
      new Text("Type: ${err.runtimeType}"),
      new Text("$err"),
    ];

    if (err is Error) {
      StackTrace trace = err.stackTrace;
      if (trace != null) {
        rows.add(new Text("Stacktrace:"));

        rows.add(new Text(
          trace.toString(),
          style: new TextStyle(fontFamily: 'monospace'),
        ));
      } else {
        rows.add(new Text("No stacktrace"));
      }
    }

    final col = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );

    return new Padding(padding: const EdgeInsets.all(16.0), child: new SingleChildScrollView(child: col));
  }

  static Widget dataBuilder<T>(BuildContext context, T data) {
    return new Text("$data");
  }

  static Widget asyncBuilder<T>(
    BuildContext context,
    AsyncSnapshot<T> snap, {
    WidgetBuilder noneBuilder,
    WidgetBuilder waitBuilder,
    WidgetBuilder activeBuilder,
    DataBuilder<T> dataBuilder,
    ErrBuilder errBuilder,
  }) {
    if (noneBuilder == null) noneBuilder = Defaults.noneBuilder;
    if (waitBuilder == null) waitBuilder = Defaults.waitBuilder;
    if (activeBuilder == null) activeBuilder = Defaults.activeBuilder;
    if (errBuilder == null) errBuilder = Defaults.errBuilder;
    if (dataBuilder == null) dataBuilder = Defaults.dataBuilder;

    switch (snap.connectionState) {
      case ConnectionState.none:
        return noneBuilder(context);
      case ConnectionState.waiting:
        return waitBuilder(context);
      case ConnectionState.active:
        return activeBuilder(context);
      case ConnectionState.done:
        return snap.hasError ? errBuilder(context, snap.error) : dataBuilder(context, snap.data);
      default:
        return Text("Should nver get here");
    } //switch
  } //asyncBuilder

}

class FutBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final WidgetBuilder waitBuilder;
  final WidgetBuilder noneBuilder;
  final WidgetBuilder activeBuilder;
  final ErrBuilder errBuilder;
  final DataBuilder<T> dataBuilder;

  FutBuilder({@required this.future, dataBuilder, noneBuilder, waitBuilder, activeBuilder, errBuilder})
      : this.noneBuilder = noneBuilder != null ? noneBuilder : Defaults.noneBuilder,
        this.waitBuilder = waitBuilder != null ? waitBuilder : Defaults.waitBuilder,
        this.activeBuilder = activeBuilder != null ? activeBuilder : Defaults.activeBuilder,
        this.errBuilder = errBuilder != null ? errBuilder : Defaults.errBuilder,
        this.dataBuilder = dataBuilder != null ? dataBuilder : Defaults.dataBuilder;


  void test1() {

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snap) {
//          if(snap.hasData) return dataBuilder(context,snap.data);
          switch (snap.connectionState) {
            case ConnectionState.none:
              return noneBuilder(context);
            case ConnectionState.waiting:
              return CircularProgressIndicator();
//              return waitBuilder(context);
            case ConnectionState.active:
              return activeBuilder(context);
            case ConnectionState.done:
              return snap.hasError ? Text("Err") : ListView(
                children: <Widget>[Text("p1")],
              );
            default:
              return Text("Should nver get here");
          }
        });
  }
}

class SnapBuilder<T> extends StatelessWidget {
  final AsyncSnapshot<T> snap;
  final WidgetBuilder waitBuilder;
  final WidgetBuilder noneBuilder;
  final WidgetBuilder activeBuilder;
  final ErrBuilder errBuilder;
  final DataBuilder<T> dataBuilder;

  SnapBuilder({@required this.snap, dataBuilder, noneBuilder, waitBuilder, activeBuilder, errBuilder})
      : this.noneBuilder = noneBuilder != null ? noneBuilder : Defaults.noneBuilder,
        this.waitBuilder = waitBuilder != null ? waitBuilder : Defaults.waitBuilder,
        this.activeBuilder = activeBuilder != null ? activeBuilder : Defaults.activeBuilder,
        this.errBuilder = errBuilder != null ? errBuilder : Defaults.errBuilder,
        this.dataBuilder = dataBuilder != null ? dataBuilder : Defaults.dataBuilder;

  @override
  Widget build(BuildContext context) {
    switch (snap.connectionState) {
      case ConnectionState.none:
        return noneBuilder(context);
      case ConnectionState.waiting:
        return waitBuilder(context);
      case ConnectionState.active:
        return activeBuilder(context);
      case ConnectionState.done:
        return snap.hasError ? errBuilder(context, snap.error) : dataBuilder(context, snap.data);
      default:
        return Text("Should nver get here");
    }
  }
}

//void snack2(BuildContext context, String msg) {
//  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(msg)));
//}
//
//void snack1(GlobalKey<ScaffoldState> key, String msg) {
//  key.currentState.showSnackBar(new SnackBar(
//    content: new Text(msg),
//    duration: Duration(seconds: 100),
//  ));
//}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snack(GlobalKey<ScaffoldState> key, String msg,
    {int seconds = 5, SnackBarAction action}) {
  Widget content = Text(msg);
  SnackBar snackBar = new SnackBar(
    content: content,
    duration: Duration(seconds: seconds),
    action: action,
  );
  return key.currentState.showSnackBar(snackBar);
}

void showBottomSheet(GlobalKey<ScaffoldState> key, String msg) {
  Widget w = new Padding(padding: const EdgeInsets.all(8.0), child: new Text(msg));
  key.currentState.showBottomSheet((BuildContext b) => w);
}

Future<bool> showOkCancelDialog(
    {@required BuildContext context,
    @required String msg,
    String title = "Confirm",
    String okText = "Ok",
    String cancelText = "Cancel"}) async {

  assert(context!=null);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new AlertDialog(
        title: title != null ? new Text(title) : null,
        content: new Text(msg),
        actions: <Widget>[
          new FlatButton(
            child: new Text(cancelText),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          new FlatButton(
            child: new Text(okText),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<T> navPushNoAnimation<T>(BuildContext context, Widget page) {
  WidgetBuilder builder = (_) => page;
  NoAnimationRoute<T> route = new NoAnimationRoute<T>(builder: builder);
  return Navigator.push<T>(context, route);
}

class NoAnimationRoute<T> extends MaterialPageRoute<T> {
  NoAnimationRoute({WidgetBuilder builder}) : super(builder: builder) {
    print("NoAnimationRoute.new");
  }

  @override
  Widget buildTransitions(BuildContext ctx, Animation<double> a1, Animation<double> a2, Widget child) {
//    print("NoAnimationRoute.buildTransitions");
    return child;
  }
}

@override
String safeWidgetToString(Widget widget) {
  String typeName = widget.runtimeType.toString();
  int hash = identityHashCode(widget);
  Key key = widget.key;
  return "$typeName hash[$hash] key[$key]";
}

Key keyForState(State state) {
  if (state.widget == null) return null;
  return state.widget.key;
}

String safeStateToString(State state) {
  String typeName = state.runtimeType.toString();
  int hash = identityHashCode(state);
  Key key = keyForState(state);
  return "$typeName hash[$hash] key[$key]";
}

abstract class SsStatelessWidget extends StatelessWidget {
  SsStatelessWidget({Key key}) : super(key: key) {
    logNew();
  }

  @override
  Widget build(BuildContext context) {
    logBuild();
    return null;
  }

  String get typeName {
    return runtimeType.toString();
  }

  void log(String prefix) {
    if (SsGlobals.debugLogging) {
      print("$prefix $this");
    }
  }

  @override
  int get hashCode => hash;

  int get hash => identityHashCode(this);

  @override
  bool operator ==(other) => isIdentical(other);

  bool isIdentical(Object other) => identical(this, other);

  String superToString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    return "";
//    return toDiagnosticsNode(style: DiagnosticsTreeStyle.singleLine).toString(minLevel: minLevel);
  }

  @override
  String toString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    String sKey = keyToString(key);
    return "$typeName hash[$hash] key[$sKey] Flutter:${superToString(minLevel: minLevel)}";
  }

  void logBuild() {
    log("build");
  }

  void logInitState() {
    log("initState");
  }

  void logNew() {
    log("new");
  }
}

String keyToString(Key k) {
  if (k == null) {
    return "NoKey";
  } else if (k is ValueKey) {
    dynamic v = k.value;
    if (v is String) {
      return v;
    } else {
      throw StateError("");
    }
  } else {
    throw StateError("");
  }
}

abstract class SsStatefulWidget extends StatefulWidget {
  SsStatefulWidget({Key key}) : super(key: key) {
    logNew();
  }

  String get typeName {
    return runtimeType.toString();
  }

  void log(String prefix) {
    if (SsGlobals.debugLogging) {
      debugPrint("$prefix $this");
    }
  }


//  bool isIdentical(Object other) => identical(this, other);

  String superToString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    return "";
//    return toDiagnosticsNode(style: DiagnosticsTreeStyle.singleLine).toString(minLevel: minLevel);
  }

  @override
  String toString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    String sKey = keyToString(key);
    return "$typeName key[$sKey] Flutter:${superToString(minLevel: minLevel)}";
  }

  void logBuild() {
    log("build");
  }

  void logInitState() {
    log("initState");
  }

  void logNew() {
    log("new");
  }
}

class MyMixIn {
  void foo() {
    print("foo");
  }
}

abstract class SsState<T extends StatefulWidget> extends State<T> {
  SsState() : super() {
//    logNew();
  }

  @override
  void initState() {
    super.initState();
    logInitState();
  }

  Key get key {
    if (widget == null) return null;
    return widget.key;
  }

  @override
  Widget build(BuildContext context) {
    logBuild();
    return null;
  }

  String get typeName {
    return runtimeType.toString();
  }

  void log(String prefix) {
    if (SsGlobals.debugLogging) {
      debugPrint("$prefix $this");
    }
  }


  String superToString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    return toDiagnosticsNode(style: DiagnosticsTreeStyle.singleLine).toString(minLevel: minLevel);
  }

  @override
  String toString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    String sKey = keyToString(key);
    return "$typeName hash[$hashCode] key[$sKey] Flutter:${superToString(minLevel: minLevel)}";
  }

  void logBuild() {
    log("build");
  }

  void logInitState() {
    log("initState");
  }

  void logNew() {
    log("new");
  }
}

class ScaffoldKey extends LabeledGlobalKey<ScaffoldState> {
  ScaffoldKey([String debugLabel = "ScaffoldKey"]) : super(debugLabel);

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snack(String msg, {int millis = 1500, SnackBarAction action}) {
    SnackBar snackBar = new SnackBar(
      content: Text(msg),
      duration: Duration(milliseconds: millis),
      action: action,
    );
    return currentState.showSnackBar(snackBar);
  }

  void todo() {
    snack("Todo");
  }

  Future<bool> okCancelDialog({@required String msg, String title = "Confirm", String okText = "Ok", String cancelText = "Cancel"}) async {

    assert(currentContext !=null);
    
    return showOkCancelDialog(context: currentContext, msg: msg, title: title, okText: okText, cancelText: cancelText);
  }

  Future<T> navPush<T>(WidgetBuilder pageBuilder) {
    Route<T> rt = mkRoute<T>(pageBuilder);
    return Navigator.push<T>(currentContext, rt);
  }
}
