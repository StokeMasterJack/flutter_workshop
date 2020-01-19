import 'package:flutter/material.dart';

extension ThemeDataExt on ThemeData {
  TextStyle get handNameMsg {
    TextTheme textTheme = this.textTheme;
    final TextStyle subtitleTheme = textTheme.subtitle;
    final Color color = this.hintColor;
    return subtitleTheme.copyWith(fontWeight: FontWeight.bold, color: color, decorationStyle: TextDecorationStyle.wavy);
  }

  TextStyle get handPointsMsg {
    return handNameMsg;
  }

  TextStyle get gameMsg {
    final TextTheme textTheme = this.textTheme;
    final TextStyle titleTheme = textTheme.title;
    final Color color = titleTheme.color;
    return titleTheme.copyWith(fontStyle: FontStyle.italic, color: color);
  }

  static ThemeData mkTheme() {
    return ThemeData(primarySwatch: Colors.blueGrey, fontFamily: 'GoogleSans');
  }

  static ThemeData mkThemeForPlatform(TargetPlatform platform) {
    return mkTheme().copyWith(platform: platform);
  }
}

//class ThemeDataPlus {
//  final ThemeData themeData;
//
//  ThemeDataPlus(this.themeData);
//
//
//
//
//  static ThemeDataPlus of(BuildContext context) {
//    ThemeData themeData = Theme.of(context);
//    return buildThemeDataPlus(themeData);
//  }
//
//  static ThemeDataPlus buildThemeDataPlus(ThemeData themeData) {
//    return ThemeDataPlus(themeData);
//  }
//}
