void main() {
  void dispatch() {
    print(11);
  }

  final o1 = foo();
  final o2 = foo();
  final o3 = foo();

  print(identityHashCode(o1));
  print(identityHashCode(o2));
  print(identityHashCode(o3));
}

void Function() foo(){
  void dispatch() {
    print(11);
  }
  final o = dispatch;
  return o;

}
