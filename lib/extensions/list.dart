extension ListExtension<T> on List<T> {
  List<OutputType> to<OutputType>(OutputType Function(T) toOutputType) {
    List<OutputType> list = [];
    for(T item in this) { list.add(toOutputType(item)); }
    return list;
  }
}