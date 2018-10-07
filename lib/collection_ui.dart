import 'package:flutter/material.dart';
import 'collection.dart';
import 'item_ui.dart';
import 'main.dart';

class CollectionUI {

  Scaffold _currentScaffold;
  ItemUI _itemui;

  Widget buildCollectionView(Collection collection) {
    return new ListView(children: [
      returnCollectionHeader(collection),
      returnItemListView(collection),
    ]);
  }

  Widget returnCollectionHeader(Collection collection) {
    return new Container(
      padding: const EdgeInsets.all(32.0),
      decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage(collection.imagePath),
            fit: BoxFit.cover,
      )),
      child: Row(
        children: [],
      ),
    );
  }

  Widget returnItemListView(Collection collection) {
//    ItemUI itemui = new ItemUI();
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i < collection.savedItems.length) {
            ListTile(
              title: Text(
                collection.savedItems[i].name,
                style: TextStyle(fontSize: 14.0),
              ),
              onTap: () {
                itemui.buildItemView(collection.savedItems[i]);
              },
            );
          }
        });
  }


  Widget buildNewCollectionView() {
    return new ListView(children: []);
  }

  ItemUI get itemui => _itemui;

  set itemui(ItemUI value) {
    _itemui = value;
  }

  Scaffold get currentScaffold => _currentScaffold;

  set currentScaffold(Scaffold value) {
    _currentScaffold = value;
  }


}
