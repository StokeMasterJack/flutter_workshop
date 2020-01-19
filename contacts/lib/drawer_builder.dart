import 'package:contacts/ui_common.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

Drawer mkDrawer(ScaffoldKey scaffoldKey, Choices choices) {

  DrawerHeader mkDrawerHeader() {
    return new DrawerHeader(child: new Text('Drawer Header'));
  }

  ListTile mkTileFromChoice(Choice c) {
    return ListTile(
      title: Text(c.title),
      onTap: () {
        c.callback();
        Navigator.pop(scaffoldKey.currentContext);
      },
    );
  }

  List<ListTile> mkTilesFromChoices(Choices choices) => choices.map(mkTileFromChoice).toList();

  final List<Widget> children = <Widget>[mkDrawerHeader()];

  List<Widget> tiles = mkTilesFromChoices(choices);
  children.addAll(tiles);

  return Drawer(child: new ListView(padding: EdgeInsets.zero, children: children));
}
