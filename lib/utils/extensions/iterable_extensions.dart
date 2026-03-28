// iterable_extensions.dart
extension IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  Iterable<E> mapIndexed<E>(E Function(int i, T e) fn) sync* {
    int i = 0;
    for (final e in this) {
      yield fn(i++, e);
    }
  }
}
