import 'package:flutter/material.dart' hide Card, Action;

import 'bj_app.dart' show BjApp;

void main() {
  print("main");

  runApp(BjApp(shuffle: false));
}
