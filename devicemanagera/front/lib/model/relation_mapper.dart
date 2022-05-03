class RelationMapper {
  final _storage = <String, List<dynamic>>{};

  void addRelation(String key, dynamic value) {
    // get list
    var list = _storage[key];

    if (list == null) {
      // if list is null
      // make list and add item to the list
      list = <dynamic>[value];
      // insert the list to _storage
      _storage[key] = list;
    } else {
      // else
      // add item to the list
      list.add(value);
    }
  }

  List<dynamic>? getRelation(String key) {
    return _storage[key];
  }
}
