import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'collection.dart';
import 'collection_ui.dart';
import 'item_ui.dart';
import 'dart:io';
import 'persistence.dart';
import 'creation-ui.dart';
import "logger.dart";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Collection Management',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Colors.grey[600],
      ),
      home: new StartPage(title: 'Collection Manager Startpage'),
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  StartPageState createState() => new StartPageState();
}

class StartPageState extends State<StartPage> {
  List<Collection> savedCollections = new List<Collection>();

  CollectionUI collectionUI ;
  ItemUI itemUI ;
  Persistence persistence;
  CreationUI creationUI;
  Logger logger;
  FloatingActionButton addButton;


  //Runtime Vars
  Collection currentlyOpenCollection;

  @override
  initState() {
    persistence = Persistence(this);
    logger = Logger("StartPageState");
    creationUI = CreationUI(this);
    collectionUI = CollectionUI();
    itemUI = ItemUI();

    setState(() {
      savedCollections = persistence.loadedCollections;
    });

    super.initState();
    logger.log("initState Method");
  }

  @override
  dispose() {
    super.dispose();
  }

  ///Build Method, most important
  @override
  Widget build(BuildContext context) {
    logger.logM("build", BuildContext, context);
    addButton = FloatingActionButton(
      onPressed: _newCollection,
      tooltip: 'New Collection',
      child: new Icon(Icons.add, color: Colors.black,),
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: _buildCollectionListView(),
        drawer: new Drawer(
            child: new ListView(
          children: <Widget>[
            new DrawerHeader(
              child: new Text('Header'),
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: Colors.black,
              ),
            ),
            new ListTile(
              title: new Text('First Menu Item'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            new ListTile(
              title: new Text('Second Menu Item'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            new Divider(),
            new ListTile(
              title: new Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        )),
        floatingActionButton: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.yellow),
          child:
              addButton, // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  ///full with Test Collections atm, will load safed collections from files
  ///Collection Methods

  void _openCollection(Collection collection) {
    Widget collectionHeader = Container(
      padding: EdgeInsets.all(50.0),
      decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.grey, style: BorderStyle.solid)),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              collection.name,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            collection.description,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
          ),
          creationUI.spaceDivider()
        ],
      ),
    );

    currentlyOpenCollection = collection;
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            // Add 6 lines from here...
            appBar: new AppBar(
              title: Text(collection.name),
            ),
            body: new ListView.builder(
                padding: const EdgeInsets.all(18.0),
                itemCount: collection.savedItems.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return collectionHeader;
                  } else {
                    return new GestureDetector(
                        onTap: () {
                          _openItem(collection.savedItems[i - 1]);
                        },
                        onLongPress: () {
                          confirmToDeleteItem(collection.savedItems[i - 1]);
                        },
                        child: new Container(
                          padding: const EdgeInsets.all(32.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        collection.savedItems[i - 1].name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      collection.savedItems[i - 1].description,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                collection.savedItems[i - 1].value.toString(),
                                style: TextStyle(fontSize: 18.0),
                              ),
                              creationUI.valueWidgetIcon(currentlyOpenCollection.currency, 20.0),
                            ],
                          ),
                        ));
                  }
                }),

            floatingActionButton: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.yellow),
              child: new FloatingActionButton(
                onPressed: _newItem,
                tooltip: 'New Item',
                child: new Icon(Icons.add,
                    color: Colors.black),
              ),
            ), // ... to here.
          );
        },
      ),
    );
  }

  Widget _buildCollectionListView() {
    setState(() {
      savedCollections = persistence.loadedCollections;
    });
    if (savedCollections.length != 0 && savedCollections != null) {
      logger.log("_buildCollectionListView Method with "+savedCollections.toString());
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i < savedCollections.length && savedCollections[i] != null) {
            return ListTile(
              title: Text(
                savedCollections[i].name,
                style: TextStyle(fontSize: 18.0),
              ),
              onTap: () {
                _openCollection(savedCollections[i]);
              },
            );
          }
        },
      );
    } else {
      return new Center(
          child: Text(
              "You don't have any collections yet! \nTap the '+' below to create one!"));
    }
  }

  void confirmToDeleteItem(CollectionItem item) {
    new AlertDialog(
      title: new Text("Are you sure?"),
      content: new Center(
          child:
              new Text("Are you sure you want to delete " + item.name + "?")),
      actions: <Widget>[
        new RaisedButton(
          child: new Text("Yes"),
          onPressed: () {},
        )
      ],
    );
  }

  final newCollectionNameController = TextEditingController();
  final newCollectionDescController = TextEditingController();

  ///Methods for displaying the Making of a new Collection
  void _newCollection() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            // Add 6 lines from here...
            appBar: new AppBar(
              title: Text('create a new collection'),
            ),
            body: new ListView(children: [
              creationUI.spaceDivider(),
              creationUI.nameWidget("Collection name", newCollectionNameController),
              creationUI.spaceDivider(),
              creationUI.descriptionWidget("Collection description", newCollectionDescController),
              creationUI.spaceDivider(),
              Container(
                padding: EdgeInsets.only(
                  left: 30.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Text("Currency"),
              ),
              currencyChooser(),
            ]),
            floatingActionButton: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.yellow),
              child: new FloatingActionButton(
                onPressed: addCollection,
                tooltip: 'New Item',
                child: new Icon(
                  Icons.check,
                  color: Colors.black,
                ),
              ),
            ),
          ); // ... to here.
        },
      ),
    );
  }

  Widget currencyChooser() {
    Radio dollarRadio = Radio(
      value: 0,
      groupValue: _radioValue,
      onChanged: _handleCurrencyRadioValueChange,
    );
    Radio euroRadio = Radio(
      value: 1,
      groupValue: _radioValue,
      onChanged: _handleCurrencyRadioValueChange,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            dollarRadio,
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              color: Colors.red,
              size: 40.0,
            ),
          ],
        ),
        Column(
          children: [
            euroRadio,
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.euro_symbol,
              color: Colors.red,
              size: 40.0,
            ),
          ],
        )
      ],
    );
  }

  int _radioValue;

  _handleCurrencyRadioValueChange(dynamic value) {
    print(value.toString());
    _radioValue = value;
    setState(() {});
  }

  void addCollection() {
    String currency;
    switch(_radioValue){
      case 0: currency = "USD"; break;
      case 1: currency = "EUR"; break;
    }
    Collection collection = new Collection(newCollectionNameController.text,
        newCollectionDescController.text, new List<CollectionItem>(), currency);
    savedCollections.add(collection);
    leaveScreen();

    persistence.createNewCollectionFile(collection);
//    persistence.writeCollection(collection);
  }

  final newItemNameCntrl = TextEditingController();
  final newItemDescCntrl = TextEditingController();
  final newItemValueCntrl = TextEditingController();
  final newItemCountCntrl = TextEditingController();
  final newItemPhotoCntrl = TextEditingController();

  ///Methods for displaying the Making of a new Item
  void _newItem() {
    Widget itemNameWidget = creationUI.nameWidget("Item name", newItemNameCntrl);
    Widget itemDescriptionWidget = creationUI.descriptionWidget("Item description", newItemDescCntrl);
    Widget itemValueWidget = creationUI.valueWidget("Item value", "", newItemValueCntrl);
    Widget itemCountWidget = creationUI.countWidget("Item count", "", newItemCountCntrl);
    Widget itemFotoWidget = creationUI.photoWidget(null);

    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
              // Add 6 lines from here...
              appBar: new AppBar(
                title: Text('New Item'),
              ),
              body: new ListView(children: [
                creationUI.spaceDivider(),
                itemNameWidget,
                creationUI.spaceDivider(),
                itemDescriptionWidget,
                creationUI.spaceDivider(),
                itemValueWidget,
                creationUI.spaceDivider(),
                itemCountWidget,
                creationUI.spaceDivider(),
//                itemFotoWidget,
              ]),
              floatingActionButton: Theme(
                data: Theme.of(context).copyWith(accentColor: Colors.yellow),
                child: new FloatingActionButton(
                  onPressed: addItem,
                  tooltip: 'New Item',
                  child: new Icon(Icons.check,
                      color: Colors.black),
                ),
              ));
        },
      ),
    );
  }

  void addItem() {
    int value = int.parse(newItemValueCntrl.text);
    int count = int.parse(newItemCountCntrl.text);
    CollectionItem item = new CollectionItem(
        newItemNameCntrl.text, newItemDescCntrl.text, value, count, null);
    currentlyOpenCollection.addItem(item);
    persistence.writeItemIntoCollectionFile(currentlyOpenCollection, item);
    leaveScreen();
  }

  void leaveScreen() {
    Navigator.of(context).pop();

    newCollectionNameController.text = "";
    newCollectionDescController.text = "";

    newItemNameCntrl.text = "";
    newItemDescCntrl.text = "";
    newItemValueCntrl.text = "";
  }

  ///Methods for Item Details screen
  void _openItem(CollectionItem item) {

    Navigator.of(context)
        .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      return new Scaffold(
        // Add 6 lines from here...
        appBar: new AppBar(
          title: Text(item.name),
        ),
        body: creationUI.spaceDivider(),
      );
    }));
  }
}
