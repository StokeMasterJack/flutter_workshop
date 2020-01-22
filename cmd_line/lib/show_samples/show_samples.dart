import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

void showSamples() {

  var sBinDir = p.dirname(Platform.script.path);
  var rootDir = Directory(sBinDir).parent;
  var sSamplesFile =  p.join(rootDir.path,'lib/show_samples/samples.json');

  var jsonFile = File(sSamplesFile);
  var jsonText = jsonFile.readAsStringSync();
//  print(jsonText);

  final json = jsonDecode(jsonText);
  for(var s in json){
    final id = s['id'];
    final description = s['description'];
    print(id);
    print(description);
    print('');
  }

//  print(json);
}