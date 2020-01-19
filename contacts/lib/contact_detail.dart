import 'package:contacts/contacts.dart';
import 'package:contacts/contacts_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssutil/ssutil.dart' as ss;
import 'package:ssutil_flutter/ssutil_flutter.dart';

enum ContactAction { delete, edit, email, call }

const appBarHeight = 256.0;
const kToolbarHeight = 56.0;

enum Layout {
//  aCol1,
  Sliver,
  Column,
  Stack,
  PreferredSize
}

class ContactDetailPage extends StatefulWidget {
  final Contact contact;
  final ContactsCallbacks callbacks;
  final Db db;

  ContactDetailPage(this.contact, this.callbacks, this.db);

  @override
  State createState() => ContactDetailPageState();
}

class ContactDetailPageState extends State<ContactDetailPage> {
  final ScaffoldKey _scaffoldKey = ScaffoldKey();

  Contact contact;

  ContactsCallbacks get callbacks => widget.callbacks;

  Layout currentLayout = Layout.Sliver;

  void _dbListener() {
    Contact cc = widget.db.getById(contact.id);
    if (cc != null && cc != contact) {
      setState(() {
        contact = cc;
        assert(contact != null);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.contact = widget.contact;
    widget.db.addListener(_dbListener);
  }

  @override
  void dispose() {
    widget.db.removeListener(_dbListener);
    super.dispose();
  }

  void onMenuItemSelected(ContactAction action) {
    _scaffoldKey.snack(action.toString());
  }

  String fullName() {
    return contact.fullName;
  }

  List mkActions() {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.delete),
        tooltip: 'Delete',
        onPressed: () => onMenuItemSelected(ContactAction.delete),
      ),
      PopupMenuButton<ContactAction>(
        onSelected: onMenuItemSelected,
        itemBuilder: (BuildContext ctx) => <PopupMenuItem<ContactAction>>[
              PopupMenuItem<ContactAction>(value: ContactAction.edit, child: const Text("Edit")),
              PopupMenuItem<ContactAction>(value: ContactAction.delete, child: const Text("Delete")),
              PopupMenuItem<ContactAction>(value: ContactAction.email, child: const Text("Email")),
              PopupMenuItem<ContactAction>(value: ContactAction.call, child: const Text("Call")),
            ],
      ),
    ];
  }

  Widget mkFab() {
    return FloatingActionButton(
      child: const Icon(Icons.edit),
      onPressed: () {
        callbacks.navToContactEdit(context, contact);
      },
    );
  }

  Widget mkToolBar(BuildContext ctx, {String title}) {
    ThemeData themeData = Theme.of(ctx);
    IconThemeData appBarIconTheme = themeData.primaryIconTheme.copyWith(color: Colors.white);
    TextStyle titleStyle = themeData.primaryTextTheme.title.copyWith(color: Colors.white);

    final Widget toolbar = Container(
      padding: const EdgeInsetsDirectional.only(start: 4.0, end: 4.0),
      child: NavigationToolbar(
          leading: BackButton(),
          middle: Text(title ?? ""),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: mkActions(),
          )),
    );

    //this is pretty cool
    Widget toolbarPretty = IconTheme.merge(
      data: appBarIconTheme,
      child: DefaultTextStyle(
        style: titleStyle,
        child: toolbar,
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: kToolbarHeight),
      child: toolbarPretty,
    );
  }

  Widget mkImageStack(BuildContext ctx2, {bool textOverlay, bool toolbar}) {
    ThemeData theme = Theme.of(ctx2);
    TextStyle titleStyle = theme.primaryTextTheme.title;
    titleStyle = titleStyle.copyWith(fontSize: titleStyle.fontSize * 1.5, color: Colors.white);

    Widget layer1Photo;

    String url = contact.bestImage;
    if (url != null) {
      layer1Photo = Image.network(
        contact.bestImage,
        fit: BoxFit.cover,
        height: appBarHeight,
        width: double.infinity,
      );
    } else {
      layer1Photo = Container(
        color: Theme.of(ctx2).primaryColorDark,
        constraints: new BoxConstraints.expand(),
        child: Icon(Icons.person, size: 150.0, color: Colors.white),
      );
    }

    Color c1 = Color(0x60000000); //r: 0, g: 0, b: 0, o: 0.38
    Color c2 = Color(0x00000000); //r: 0, g: 0, b: 0, o: 0.00

    Widget layer2Gradient = DecoratedBox(
        decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(0.0, -1.0),
        end: Alignment(0.0, -0.4),
        colors: <Color>[c1, c2],
      ),
    ));

    List<Widget> children = <Widget>[layer1Photo, layer2Gradient];

    //layer3
    if (textOverlay) {
      children.add(Container(
          height: appBarHeight,
          width: double.infinity,
          child: Text(fullName(), style: titleStyle),
          alignment: Alignment.bottomCenter,
          padding: new EdgeInsets.only(bottom: 10.0)));
    }

    if (toolbar) {
      children.add(Container(
        height: appBarHeight,
        width: double.infinity,
        child: SafeArea(child: mkToolBar(ctx2)),
        alignment: Alignment.topCenter,
      ));
    }

    return Stack(overflow: Overflow.clip, fit: StackFit.expand, children: children);
  }

  Widget bottomNavBar() {
    return bottomNavBar2();
  }

  Widget bottomNavBar1() {
    Widget mapIt(Layout layout) {
      return FlatButton(
        child: Text(describeEnum(layout)),
        onPressed: () {
          setState(() {
            this.currentLayout = layout;
          });
        },
      );
    }

    List<Widget> actions = Layout.values.map(mapIt).toList();

    Row rr = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions,
    );
    return BottomAppBar(child: rr);
  }

  Widget bottomNavBar2() {
    List icons = <IconData>[
      Icons.view_column,
      Icons.panorama_vertical,
      Icons.touch_app,
      Icons.slideshow,
    ];

    BottomNavigationBarItem mapIt(Layout lo) {
      String text = describeEnum(lo);
      int index = Layout.values.indexOf(lo);
      return BottomNavigationBarItem(icon: Icon(icons[index]), title: Text(text));
    }

    List<Layout> layouts = Layout.values;

    List<BottomNavigationBarItem> items = layouts.map(mapIt).toList();

    return BottomNavigationBar(
      currentIndex: layouts.indexOf(currentLayout),
      type: BottomNavigationBarType.fixed,
      items: items,
      onTap: (int index) {
        Layout lo = layouts[index];
        setState(() {
          this.currentLayout = lo;
        });
      },
    );
  }

  List<Widget> mkBodyRows() {
    List<NameValue> nvList = contact.nvList();
    Widget mkChild(NameValue nv) {
      return nv.toListTileWidget();
    }

    return nvList.map(mkChild).toList();
  }

  Widget mkFakeAppBar(BuildContext context) {
    return SizedBox(height: appBarHeight, child: mkImageStack(context));
  }

  Widget mkAppBarPreferredSize(BuildContext ctx) {
    PreferredSize bottom = PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          height: appBarHeight,
          width: double.infinity,
          alignment: Alignment.center,
          child: Builder(builder: (BuildContext ctxB) {
            return mkImageStack(ctxB, textOverlay: true, toolbar: true);
          }),
        ));

    return bottom;
  }

  Widget mkAppBarSliver(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: appBarHeight,
      actions: mkActions(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(fullName()),
        background: mkImageStack(context, textOverlay: false, toolbar: false),
      ),
    );
  }

  Widget mkBodyListView() {
    return ListView(padding: EdgeInsets.all(0.0), children: mkBodyRows());
  }

  SliverList mkBodySliverList() {
    return SliverList(delegate: SliverChildListDelegate(mkBodyRows()));
  }

  //fails: Vertical viewport was given unbounded height
  Widget mkScaffoldAColumnNaive(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: bottomNavBar(),
        key: _scaffoldKey,
        floatingActionButton: mkFab(),
        body: Column(children: <Widget>[mkFakeAppBar(context), mkBodyListView()]));
  }

  Widget mkScaffoldColumn(BuildContext context1) {
    Widget body = LayoutBuilder(
        builder: (ctx2, constraints) => Column(
              children: <Widget>[
                SizedBox(height: appBarHeight, child: mkImageStack(ctx2, textOverlay: true, toolbar: true)),
                SizedBox(height: constraints.maxHeight - appBarHeight, child: mkBodyListView())
              ],
            ));

    return Scaffold(bottomNavigationBar: bottomNavBar(), floatingActionButton: mkFab(), body: body);
  }

  Widget mkScaffoldStack(BuildContext context) {
    Widget body = LayoutBuilder(
      builder: (loContext, constraints) => Stack(
            overflow: Overflow.clip,
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: SizedBox(height: appBarHeight, child: mkImageStack(loContext, textOverlay: true, toolbar: true)),
              ),
              Positioned(
                right: 0.0,
                left: 0.0,
                bottom: 0.0,
                child: SizedBox(height: constraints.maxHeight - appBarHeight, child: mkBodyListView()),
              ),
            ],
          ),
    );

    return Scaffold(bottomNavigationBar: bottomNavBar(), floatingActionButton: mkFab(), body: body);
  }

  Widget mkScaffoldPreferredSize(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: mkFab(),
      appBar: mkAppBarPreferredSize(context),
      body: mkBodyListView(),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  Widget mkScaffoldSliver(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: mkFab(),
      body: CustomScrollView(slivers: <Widget>[mkAppBarSliver(context), mkBodySliverList()]),
//      bottomNavigationBar: bottomNavBar(),
    );
  }

  Widget mkScaffold(BuildContext context) {
    switch (currentLayout) {
//      case Layout.aCol1:
//        return mkScaffoldAColumnNaive();
      case Layout.Sliver:
        return mkScaffoldSliver(context);
      case Layout.Column:
        return mkScaffoldColumn(context);
      case Layout.Stack:
        return mkScaffoldStack(context);
      case Layout.PreferredSize:
        return mkScaffoldPreferredSize(context);
      default:
        return ss.throwStateErr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return mkScaffold(context);
  }
}
