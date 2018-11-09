import 'package:flutter/material.dart';

class Collection {
  List<CollectionItem> _savedItems;
  String _description;
  String _name;
  String _imagePath;
  String _currency;
  Icon _currencyIcon;

  // Collection Constructor
  Collection(
      String name, String description, List<CollectionItem> loadedItems, String currency) {
    _name = name;
    _description = description;
    _savedItems = loadedItems;
    _currency = currency;
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

  @override
  String toString(){
    String result;

    result = this.name +", "+this.description+", "+this.currency+", "+this.savedItems.length.toString();

    return result;
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

  String get imagePath => _imagePath;

  set imagePath(String value) {
    _imagePath = value;
  }

  Icon get currencyIcon => _currencyIcon;

  set currencyIcon(Icon value) {
    _currencyIcon = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }


}

class CollectionItem {
  Image _picture;
  String _picturePath;
  String _name;
  String _description;
  int _value;
  int _count;

  //Item Constructor
//  CollectionItem(String name, String description, int value, Image picture) {
//    _name = name;
//    _description = description;
//    _value = value;
//    _picture = picture;
//  }

  CollectionItem(String name, String description, int value, int count, String picturePath){
    _name = name;
    _description = description;
    _value = value;
    _count = count;
    _picturePath = picturePath;
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

  int get count => _count;

  set count(int value) {
    _count = value;
  }

  String get picturePath => _picturePath;

  set picturePath(String value) {
    _picturePath = value;
  }


}
