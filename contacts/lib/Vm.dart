import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:contacts/contacts.dart';
import 'package:contacts/sample_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ssutil/ssutil.dart' as ss;

class Singleton {}

class Vm {
  static bool isVm = false;

  static AssetBundle mockAssetBundle;

  static MockAssetBundle getMockAssetBundle() {
    if (mockAssetBundle == null) {
      mockAssetBundle = MockAssetBundle(map: {Db.defaultLocalAssetName: SampleData.contactsJsonText});
    }
    return mockAssetBundle;
  }

  static Future<R> computeAsync<Q, R>(ComputeCallback<Q, R> callback, Q message, {String debugLabel}) async {
    if (isVm) {
      print("Vm.computeAsync 1");
      R retVal = callback(message);
      return retVal;
    } else {
      print("Vm.computeAsync 3");
      return compute(callback, message);
    }
  }

  static Future<R> computeAsyncJvm<Q, R>(ComputeCallback<Q, R> callback, Q message, {String debugLabel}) async {
    R retVal = callback(message);
    print("retVal: $retVal");
    return retVal;
  }

  static AssetBundle assetBundle() {
    if (isVm) {
      MockAssetBundle assetBundle = getMockAssetBundle();
      return assetBundle;
    } else {
      return rootBundle;
    }
  }
}

class MockAssetBundle extends AssetBundle {
  Map<String, String> map = {};

  MockAssetBundle({this.map});

  @override
  Future<ByteData> load(String key) {
    String value = map[key];
    if (value == null) {
      throw new FlutterError('Unable to load asset: $key');
    }
    ByteData byteData = stringToByteData(value);
    return Future.value(byteData);
  }

  @override
  Future<T> loadStructuredData<T>(String key, Future<T> parser(String value)) {
    return Future.value(ss.throwStateErr<T>());
  }

//  static Future<ByteData> handleMessage(ByteData bKey) {
//    String textData = SampleData.contactsJsonText;
//    ByteData byteData = stringToByteData(textData);
//    return Future.value(byteData);
//  }
//

  static ByteData stringToByteData(String s) {
    Uint8List uInt8list = utf8.encode(s);
    return uInt8list.buffer.asByteData();
  }

  static String byteDataToString(ByteData byteData) {
    ByteBuffer buffer = byteData.buffer;
    Uint8List uIntList = buffer.asUint8List();
    return utf8.decode(uIntList);
  }
}

typedef Future<ByteData> MessageHandler(ByteData message);
