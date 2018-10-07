import 'package:flutter/material.dart';
import 'collection.dart';
import 'main.dart';

class ItemUI{

  Scaffold _currentScaffold;

  Widget buildItemView(CollectionItem item){
    return new ListView(
      children: [

      ]
    );
  }

  Widget buildNewItenView(){
    return new ListView(
        children: [

        ]
    );
  }

  Scaffold get currentScaffold => _currentScaffold;

  set currentScaffold(Scaffold value) {
    _currentScaffold = value;
  }


}