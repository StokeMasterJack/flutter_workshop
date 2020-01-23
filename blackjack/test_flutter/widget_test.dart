import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/app_common.dart';
import '../lib/main.dart';

void main() {
  testApp();
  testBjPage(Page.ui1, "UI 1");
  testBjPage(Page.ui2, "UI 2");
}

void testApp() {
  testWidgets('App', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    expect(find.widgetWithText(AppBar, 'Blackjack - Home'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(buttonWithText('BLACKJACK - UI 1'), findsOneWidget);
    expect(buttonWithText('BLACKJACK - UI 2'), findsOneWidget);
  });
}

void testBjPage(Page page, String suffix) {
  testWidgets('${page.name}', (WidgetTester tester) async {
    await tester.pumpWidget(App(shuffle: false));

//    Blackjack - UI 1
    String buttonText = 'BLACKJACK - $suffix';
    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();
//    await tester.pumpAndSettle();

    final appBarText = "Blackjack - $suffix";
    expect(find.widgetWithText(AppBar, appBarText), findsOneWidget);

    expect(buttonWithText('HIT'), findsOneWidget);


    expect(buttonWithText('STAY'), findsOneWidget);

    expect(buttonWithText('DEAL'), findsOneWidget);
//    if (true) return;

    expect(find.text('4 Points'), findsOneWidget);
    expect(find.text('6 Points'), findsOneWidget);
    expect(find.text('Press Hit or Stay'), findsOneWidget);

    await tester.tap(buttonWithText("HIT"));
    await tester.pumpAndSettle();
    expect(find.text('9 Points'), findsOneWidget);
    expect(find.text('6 Points'), findsOneWidget);
    expect(find.text('Press Hit or Stay'), findsOneWidget);

    await tester.tap(buttonWithText("Stay"));
    await tester.pumpAndSettle();
    expect(find.text('9 Points'), findsOneWidget);
    expect(find.text('19 Points'), findsOneWidget);
    expect(find.text('Dealer Wins!'), findsOneWidget);
  });
}

bool isButton(Widget w, String text) {
  bool isButton = w is MaterialButton || w is CupertinoButton;
  if (!isButton) return false;

  Widget childOrNull;
  if (w is MaterialButton) {
    childOrNull = w.child;
  } else if (w is CupertinoButton) {
    childOrNull = w.child;
  } else {
    return false;
  }

  if (childOrNull != null && childOrNull is Text && childOrNull.data != null) {
    if (text == null) return true;
    final outer = childOrNull.data.toLowerCase();
    final inner = text.toLowerCase();
    return outer.contains(inner);
  } else {
    return false;
  }
}

Finder buttonWithText(String s) => find.byWidgetPredicate((w) => isButton(w, s));
