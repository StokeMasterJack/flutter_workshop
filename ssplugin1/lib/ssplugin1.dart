import 'dart:async';

import 'package:flutter/services.dart';

const String platformChannelName = "com.smartsoft.ssplugin";

class SsPlugin1 {
  static const MethodChannel _channel = const MethodChannel(platformChannelName);

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
