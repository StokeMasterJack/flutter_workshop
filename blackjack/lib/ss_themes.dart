import 'package:flutter/material.dart';

const MaterialColor _primarySwatch = Colors.blueGrey;

extension ThemeDataExt on ThemeData {
  TextStyle get handNameMsg {
    TextTheme textTheme = this.textTheme;
    final TextStyle subtitleTheme = textTheme.subtitle2;
    final Color color = this.hintColor;
    return subtitleTheme.copyWith(fontWeight: FontWeight.bold, color: color, decorationStyle: TextDecorationStyle.wavy);
  }

  TextStyle get handPointsMsg {
    return handNameMsg;
  }

  TextStyle get gameMsg {
    final TextTheme textTheme = this.textTheme;
    final TextStyle titleTheme = textTheme.headline6;
    final Color color = titleTheme.color;
    return titleTheme.copyWith(fontStyle: FontStyle.italic, color: color);
  }

  MaterialColor get primarySwatch => _primarySwatch;

  Color get backgroundColorLite => primarySwatch[50];

  static ThemeData mk() {
    return ThemeData(primarySwatch: _primarySwatch, fontFamily: 'GoogleSans');
  }

  static ThemeData mkThemeForPlatform(TargetPlatform platform) => mk().copyWith(platform: platform);
}
