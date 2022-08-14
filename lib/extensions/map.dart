extension MapExtension on Map<String, dynamic> {
  String get toJsonStr {
    String output = '{';
    int index = 1;
    for(String key in keys) {
      // Add key.
      output += '"$key": ';
      // Add value.
      final value = this[key];
      if(value is String) {
        output += '"$value"';
      } else if (value is Map<String, dynamic>){
        output += value.toJsonStr;
      } else {
        output += '$value';
      }
      // Add comma of close parentis.
      if(index < length) {
        output += ', ';
      } else {
        output += '}';
      }
      index++;
    }
    return output;
  }
}