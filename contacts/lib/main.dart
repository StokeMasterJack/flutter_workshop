import 'package:flutter/material.dart';
import 'package:ssutil_flutter/ssutil_flutter.dart';

import 'Vm.dart';
import 'app.dart';

void main() async {
  Vm.isVm = false;
  SsGlobals.debugLogging = false;

  runApp(App());
}
