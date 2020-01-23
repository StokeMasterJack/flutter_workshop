import 'dart:collection';

int hashCodeList<T>(Iterable<T> a) {
  int hash = 1;
  Iterator<T> i = a.iterator;
  while (true) {
    bool dd = i.moveNext();
    if (!dd) break;
    T el = i.current;
    hash = 31 * hash + (el == null ? 0 : el.hashCode);
  }
  return hash;
}

class IList<E> extends UnmodifiableListView<E> {
  IList(Iterable<E> source) : super(source);
}

class IList2<E> extends UnmodifiableListView<E> {
  final int hash;

  IList2(Iterable<E> source, [int hash])
      : this.hash = hash ?? hashCodeList(source),
        super(source);

  @override
  bool operator ==(Object other) => identical(this, other) || other is IList2 && runtimeType == other.runtimeType && hash == other.hash;

  @override
  int get hashCode => hash;
}

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

T ensure<T>(T v) {
  if (v == null) {
    throw ArgumentError("ensure failed");
  }
  return v;
}


