import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/*
Example of tight:
  minWidth = maxWidth = 10
  minHeight = maxHeight = 5
  BoxConstraints(minWidth: 10, maxWidth: 10, minHeight: 3, maxHeight: 3)
 */

final b0Tight = BoxConstraints.tight(Size(10.0, 5.0));

final b1Tight = BoxConstraints(minWidth: 10.0, maxWidth: 10.0, minHeight: 3.0, maxHeight: 3.0);
final b3Tight = BoxConstraints(minWidth: 10.0, maxWidth: 10.0, minHeight: 3.0, maxHeight: 3.0);


final b2Tight = BoxConstraints.tightFor(width: 10.0, height: 3.0);


final b1Loose = new BoxConstraints.loose(Size(10.0,3.0));
final ee = new BoxConstraints.expand();


void foo(RenderTable ro){
  BoxConstraints constraints = BoxConstraints.loose(Size(10.0,3.0));
//  ro.parentData;
  ro.layout(constraints);
  ro.performResize();
  ro.performLayout();
}




