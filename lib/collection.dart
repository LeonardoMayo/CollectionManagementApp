import 'package:flutter/material.dart';

class Collection {
  List<CollectionItem> _savedItems;
  String _description;
  String _name;

  // Collection Constructor
  Collection(
      String name, String description, List<CollectionItem> loadedItems) {
    _name = name;
    _description = description;
    _savedItems = loadedItems;
  }

  void addItem(CollectionItem item) {
    _savedItems.add(item);
  }

  void removeItem(CollectionItem item) {
    _savedItems.remove(item);
  }

  CollectionItem getItemByIndex(int index) {
    return _savedItems.elementAt(index);
  }

  CollectionItem getItemByName(String itemName) {
    for (int i = 0; i < _savedItems.length; i++) {
      if (_savedItems[i].name == itemName){
        return _savedItems[i];
      }
    }
    return null;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  List<CollectionItem> get savedItems => _savedItems;

  set savedItems(List<CollectionItem> value) {
    _savedItems = value;
  }


}

class CollectionItem {
  Image _picture;
  String _name;
  String _description;
  int _value;

  //Item Constructor
  CollectionItem(String name, String description, int value, Image picture) {
    _name = name;
    _description = description;
    _value = value;
    _picture = picture;
  }

  int get value => _value;

  set value(int value) {
    _value = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  Image get picture => _picture;

  set picture(Image value) {
    _picture = value;
  }
}
