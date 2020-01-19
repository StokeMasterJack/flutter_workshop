import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

void showSamples() {

  String sBinDir = p.dirname(Platform.script.path);
  Directory rootDir = new Directory(sBinDir).parent;
  String  sSamplesFile =  p.join(rootDir.path,"lib/show_samples/samples.json");

  File jsonFile = new File(sSamplesFile);
  String jsonText = jsonFile.readAsStringSync();
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