import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/bj_app.dart';

void main() {
  testHomePage();
  testGamePage("UI 1");
  testGamePage("UI 2");
}

void testHomePage() {
  testWidgets('Home Page', (WidgetTester tester) async {
    await tester.pumpWidget(BjApp(shuffle: false));
    expect(find.widgetWithText(AppBar, 'Blackjack - Home'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(buttonWithText('BLACKJACK - UI 1'), findsOneWidget);
    expect(buttonWithText('BLACKJACK - UI 2'), findsOneWidget);
  });
}

void testGamePage(String suffix) {
  testWidgets('$suffix', (WidgetTester tester) async {
    await tester.pumpWidget(BjApp(
      shuffle: false,
    ));

    await tester.tap(find.text('BLACKJACK - $suffix'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, "Blackjack - $suffix"), findsOneWidget);
    expect(buttonWithText('HIT'), findsOneWidget);
    expect(buttonWithText('STAY'), findsOneWidget);
    expect(buttonWithText('DEAL'), findsOneWidget);

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

/// @return true if w is a Button with child of type Text containing text (or any text if text is null)
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
