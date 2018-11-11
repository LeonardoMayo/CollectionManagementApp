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
import 'detail-ui.dart';
import 'constants.dart';

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

  CollectionUI collectionUI;

  ItemUI itemUI;

  Persistence persistence;
  CreateStuffUI createStuffUI;
  Logger logger;
  DetailUI detailUI;
  FloatingActionButton addButton;

  //Runtime Vars
  Collection currentlyOpenCollection;

  @override
  initState() {
    persistence = Persistence(this);
    logger = Logger("StartPageState");
    createStuffUI = CreateStuffUI(this);
    collectionUI = CollectionUI();
    itemUI = ItemUI();
    detailUI = DetailUI(this);

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

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: _buildCollectionListView(),
        drawer: detailUI.appDrawer(context),
        floatingActionButton:
    Theme(
    data: Theme.of(context).copyWith(accentColor: Colors.yellow),
    child: new FloatingActionButton(
    onPressed: newCollection,
    child: new Icon(Icons.add, color: Colors.black),
    ),
    ), );
  }

  ///full with Test Collections atm, will load safed collections from files
  ///Collection Methods

  void _openCollection(Collection collection) {
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
                    return detailUI.headerItem(
                        collection.name, collection.description);
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
                              createStuffUI.countWidgetIcon(20.0),
                              Container(padding: const EdgeInsets.all(1.0),child:
                              Text(collection.savedItems[i - 1].count.toString(), style: TextStyle(fontSize: 18.0)),
                              ),
                              createStuffUI.spaceDivider(),
                              Text(
                                collection.savedItems[i - 1].value.toString(),
                                style: TextStyle(fontSize: 18.0),
                              ),
                              createStuffUI.valueWidgetIcon(
                                  currentlyOpenCollection.currency, 20.0),
                            ],
                          ),
                        ));
                  }
                }),

            floatingActionButton: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.yellow),
              child: new FloatingActionButton(
                onPressed: newItem,
                tooltip: 'New Item',
                child: new Icon(Icons.add, color: Colors.black),
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
      logger.log("_buildCollectionListView Method with " +
          savedCollections.toString());
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
  void newCollection() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            // Add 6 lines from here...
            appBar: new AppBar(
              title: Text('create a new collection'),
            ),
            body: new ListView(children: [
              createStuffUI.spaceDivider(),
              createStuffUI.nameWidget(
                  "Collection name", newCollectionNameController),
              createStuffUI.spaceDivider(),
              createStuffUI.descriptionWidget(
                  "Collection description", newCollectionDescController),
              createStuffUI.spaceDivider(),
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
                child: new Icon(Icons.check, color: Colors.black),
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
    switch (_radioValue) {
      case 0:
        currency = "USD";
        break;
      case 1:
        currency = "EUR";
        break;
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
  void newItem() {
    logger.logM("newItem", null, null);
    Widget itemNameWidget =
        createStuffUI.nameWidget("Item name", newItemNameCntrl);
    Widget itemDescriptionWidget =
        createStuffUI.descriptionWidget("Item description", newItemDescCntrl);
    Widget itemValueWidget =
        createStuffUI.valueWidget("Item value", "", newItemValueCntrl);
    Widget itemCountWidget =
        createStuffUI.countWidget("Item count", "1", newItemCountCntrl);
    Widget itemFotoWidget = createStuffUI.photoWidget(null);

    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
              // Add 6 lines from here...
              appBar: new AppBar(
                title: Text('New Item'),
              ),
              body: new ListView(children: [
                createStuffUI.spaceDivider(),
                itemNameWidget,
                createStuffUI.spaceDivider(),
                itemDescriptionWidget,
                createStuffUI.spaceDivider(),
                itemValueWidget,
                createStuffUI.spaceDivider(),
                itemCountWidget,
                createStuffUI.spaceDivider(),
//                itemFotoWidget,
              ]),
              floatingActionButton: Theme(
                data: Theme.of(context).copyWith(accentColor: Colors.yellow),
                child: new FloatingActionButton(
                  onPressed: addItem,
                  tooltip: 'New Item',
                  child: new Icon(Icons.check, color: Colors.black),
                ),
              ),
          );
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
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          // Add 6 lines from here...
          appBar: AppBar(
            title: Text(item.name),
          ),
          body: ListView(
            children: <Widget>[
              detailUI.headerItem(item.name, item.description),
              createStuffUI.spaceDivider(),
              detailUI.itemValueField(
                  item.value, currentlyOpenCollection.currencyIcon),
              createStuffUI.spaceDivider(),
              detailUI.itemCountField(item.count),
              createStuffUI.spaceDivider()
            ],
          ));
    }));
  }
}
