import 'dart:async';

import 'package:contacts/contact_detail.dart';
import 'package:contacts/contact_edit_page.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/contacts_page.dart';
import 'package:contacts/db_maintenance_page.dart';
import 'package:contacts/drawer_builder.dart';
import 'package:contacts/simple_theme.dart';
import 'package:contacts/ui_common.dart';
import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

const defaultLocalAssetName = "data/contacts.json";

class App extends SsStatefulWidget {
  createState() => AppState();
}

class AppState extends State<App> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Db db;

  void onDbChanged() {
    print("onDbChanged");
  }

  @override
  void initState() {
    super.initState();
    db = Db();
    db.addListener(onDbChanged);
    db.importFromJsonAssetAsync();
  }

  @override
  void dispose() {
    db.removeListener(onDbChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(context.runtimeType);
    return MaterialApp(
      home: _buildContactsPage(),
      theme: buildSimpleTheme(),
      title: "Flutter Contacts",
    );
  }

  ContactsCallbacks mkCallbacks() {
    return ContactsCallbacks(
      exportToJson: db.exportToDocDir,
      clearDb: db.clearDb,
      importRandom: db.importFromRandom,
      importFromAsset: db.importFromJsonAssetAsync,
      deleteAll: db.deleteAll,
      navToContactDetail: _navToContactDetail,
      navToContactEdit: _navToContactEdit,
    );
  }

  Widget _buildContactsPage() {
    return ContactsPage(
        model: ContactsModel(computeData: (Filter f) => ContactsData(db.select(f)), db: db), callbacks: mkCallbacks(), drawerBuilder: mkMyDrawer);
  }

  Widget _buildContactEditPage(BuildContext context, Contact contact) {
    return new ContactEditPage(initContact: contact);
  }

  Widget _buildContactDetailPage(BuildContext context, Contact contact) {
    return new ContactDetailPage(contact, mkCallbacks(), db);
  }

  void _navToContactEdit(BuildContext context, Contact contact) async {
    Widget buildPage(BuildContext context) {
      return _buildContactEditPage(context, contact ?? Contact.empty());
    }

    Contact updatedContact = await navPush(context, buildPage);

    if (updatedContact != null) {
      setState(() {
        db.put(updatedContact);
      });
    }
  }

  void _navToContactDetail(BuildContext context, Contact contact) async {
    assert(contact != null);
    Widget buildPage(BuildContext context) {
      return _buildContactDetailPage(context, contact);
    }

    navPush(context, buildPage);
  }

  Future navToDbAdminPage(ScaffoldKey k) async {
    print("navToDbAdminPage 1");
    DbMaintenancePage p = DbMaintenancePage(db);
    print("navToDbAdminPage 2");
    final ctx = k.currentContext;
    print("navToDbAdminPage 3");
    await navPush(ctx, (_) => p);
    print("navToDbAdminPage 4");
  }

  Drawer mkMyDrawer(ScaffoldKey k) {
    Choices choices = Choices([Choice(title: "Nav to DbAdmin", callback: () => navToDbAdminPage(k))]);
    return mkDrawer(k, choices);
  }
}
