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

  static ThemeData mk() {
    return ThemeData(primarySwatch: Colors.blueGrey, fontFamily: 'GoogleSans');
  }

  static ThemeData mkThemeForPlatform(TargetPlatform platform) => mk().copyWith(platform: platform);
}
