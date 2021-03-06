

String indent(int d) {
  final sb = StringBuffer();
  for (var i = 0; i < d; i++) sb.write(" ");
  return sb.toString();
}

void prn(Object value, [int depth = 0]) {
  final prefix = indent(depth);
  print("$prefix$value");
}

class Mutator {
  const Mutator();
}

class Transform {
  const Transform();
}

class Effect {
  const Effect();
}

typedef ToInt<T> = int Function(T);

extension ListExtras<T> on List<T> {
  int total(ToInt<T> f) {
    int t = 0;
    for (var e in this) {
      var i = f(e);
      t += i;
    }
    return t;
  }

  ListPos computeListPos(int index) {
    final iFirst = 0;
    final iLast = this.length - 1;
    if (index == iFirst) return ListPos.first;
    if (index == iLast) return ListPos.last;
    assert(index > iFirst && index < iLast);
    return ListPos.middle;
  }
}

enum ListPos { first, middle, last }

T ensure<T>(T v, [String m = "Ensure failed"]) {
  if (v == null) {
    throw ArgumentError(m);
  }
  return v;
}
