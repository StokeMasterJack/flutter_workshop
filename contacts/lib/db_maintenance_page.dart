import 'dart:async';

import 'package:contacts/contacts.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

class DbMaintenancePage extends SsStatefulWidget {
  final Db db;

  DbMaintenancePage(this.db) : assert(db != null);

  @override
  State createState() => DbMaintenanceState();
}

class DbMaintenanceState extends SsState<DbMaintenancePage> {
  final ScaffoldKey _scaffoldKey = ScaffoldKey();

  String _statusBarText;
  bool _showWaiting = false;
  int _contactCount = 0;

  void dbListener() {
    setState(() {
      _contactCount = db.contactCount;
    });
  }

  @override
  void initState() {
    super.initState();
    db.addListener(dbListener);
    _contactCount = db.contactCount;
  }

  @override
  void dispose() {
    db.removeListener(dbListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("DB Maintenance")),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    List<Widget> children = <Widget>[buildHeader(context), _buildStatusBar(context)];
    children.addAll(_buildTiles(context));

    return ListView(children: children.toList());
  }

  Db get db => widget.db;

  Widget buildHeader(BuildContext context) {
    Widget mkNameValueRow(String name, String value) {
      return Container(
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              child: Text(name),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(2.0),
              margin: EdgeInsets.all(8.0),
            )),
            Container(
              child: Text(value),
              width: 40.0,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(2.0),
              margin: EdgeInsets.all(5.0),
            ),
          ],
        ),
      );
    }

    return Container(
        constraints: BoxConstraints(minWidth: double.infinity, maxWidth: double.infinity, minHeight: 0.0, maxHeight: double.infinity),
        padding: EdgeInsets.all(10.0),
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    mkNameValueRow("Db contact count", "$_contactCount"),
                  ],
                ))));
  }

  Widget _buildStatusBar(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    String status = _statusBarText ?? "";

    List<Widget> a = [];
    if (_showWaiting) {
      a.add(SizedBox(width: 10.0));
      a.add(SizedBox(width: 15.0, height: 15.0, child: CircularProgressIndicator()));
      a.add(SizedBox(width: 10.0));
    }
    if (_statusBarText != null) {
      a.add(SizedBox(width: 10.0));
      a.add(Text(status, style: textTheme.body1.copyWith(color: themeData.primaryColorDark, fontStyle: FontStyle.italic)));
    }
    return Container(height: 50.0, padding: EdgeInsets.only(left: 20.0), child: Row(children: a));
  }

  void _onClearDb() async {
    bool confirm = await _okCancelDialog(msg: "Delete all data?");
    if (confirm) {
      db.clearDb();
      _snack("DB Reset!");
    }
  }

  void _clearStatus() {
    setState(() {
      _statusBarText = null;
      _showWaiting = false;
    });
  }

  void _setStatus(String text, [bool showWaiting = false]) {
    setState(() {
      _statusBarText = text;
      _showWaiting = showWaiting;
    });
  }

  void _onExportToDocDir() async {
    await db.exportToDocDir();
    _snack("Export to doc dir complete!");
  }

  Future<void> _onImportFromExtDir() async {
    try {
      await db.importFromExtDir();
      _snack("Import successful");
    } catch (e) {
      _snack("Import failed: $e");
    }
  }

  Future<void> _onExportToExtDir() async {
    try {
      await db.exportToExtDir();
      _snack("Export to ext dir success!");
    } catch (e) {
      _snack("Export to ext dir failed: $e");
    }
  }

  void _onImportRandom() async {
    _setStatus("Loading random data...", true);
    await db.importFromRandom();
    _clearStatus();
    _scaffoldKey.snack("Random import complete!");
  }

  void _onImportFromAsset() async {
    await db.importFromJsonAssetAsync();
    _snack("Import complete!");
  }

  void _onImportFromDocDir() async {
    bool success = await db.importFromDocDir();
    _snack("Import ${success ? "successful" : "failed"}!");
  }

  List<Widget> _buildTiles(BuildContext context) {
    Choices choices = Choices([
      Choice(title: 'Clear DB', icon: Icons.directions_car, callback: _onClearDb),
      Choice(title: 'Import from asset', icon: Icons.directions_bike, callback: _onImportFromAsset),
      Choice(title: 'Import from doc dir', icon: Icons.directions_bike, callback: _onImportFromDocDir),
      Choice(title: 'Import from ext dir', icon: Icons.directions_bike, callback: _onImportFromExtDir),
      Choice(title: 'Import random http', icon: Icons.directions_bike, callback: _onImportRandom),
      Choice(title: 'Export to doc dir', icon: Icons.directions_boat, callback: _onExportToDocDir),
      Choice(title: 'Export to ext dir', icon: Icons.directions_boat, callback: _onExportToExtDir),
    ]);

    return buildListTiles(choices, context);
  }

  List<Widget> buildListTiles(Choices choices, BuildContext context) {
    Widget choiceToListTile(Choice c) {
      Container container = Container(
          constraints: BoxConstraints(
            minWidth: double.infinity,
            maxWidth: double.infinity,
          ),
          padding: EdgeInsets.all(8.0).copyWith(left: 15.0, right: 15.0),
          child: RaisedButton(child: Text(c.title), onPressed: c.callback));

      return container;
    }

    return choices.map(choiceToListTile).toList();
  }

  Future<bool> _okCancelDialog({@required String msg, String title = "Confirm", String okText = "Ok", String cancelText = "Cancel"}) {
    return _scaffoldKey.okCancelDialog(msg: msg, title: title, okText: okText, cancelText: cancelText);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snack(String msg) {
    return _scaffoldKey.snack(msg);
  }
}
