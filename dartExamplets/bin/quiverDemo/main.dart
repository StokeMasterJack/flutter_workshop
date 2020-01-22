import 'package:quiver/check.dart';

main(List<String> arguments) {
  print('Hello world: ${33}');

  foo(4);
  foo(12);



}

void foo(int x){
  checkArgument(x < 10);
}
