import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:splashscreen/splashscreen.dart';
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
      home: Startup(),
//      home: new HomePage(title: 'Collection Manager Startpage'),
    );
  }
}

class Startup extends StatefulWidget {
  @override
  StartupState createState() => new StartupState();
}

class StartupState extends State<Startup> {
  Logger logger;
  Persistence persistence;

  @override
  void initState() {
    logger = Logger("StartupState");
    persistence = Persistence(this);

    super.initState();
    logger.logM("initState", null, null);
  }

  @override
  Widget build(BuildContext context) {
    logger.logM("build", BuildContext, context);
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: HomePage(
        startupState: this,
      ),
      backgroundColor: Colors.black12,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: () => print("Flutter Egypt"),
      loaderColor: Colors.red,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.startupState}) : super(key: key);

  final String title;
  final StartupState startupState;

  @override
  HomePageState createState() => new HomePageState(startupState);
}

class HomePageState extends State<HomePage> {
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

  HomePageState(StartupState startupState) {
    print("HomePageState Konstruktor");
    persistence = startupState.persistence;
  }

  @override
  initState() {
//    persistence = Persistence(StartupState());
    logger = Logger("StartPageState");
    createStuffUI = CreateStuffUI(this);
    collectionUI = CollectionUI();
    itemUI = ItemUI();
    detailUI = DetailUI(this);

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

    setState(() {
      savedCollections = persistence.loadedCollections;
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("CollectionStack"),
      ),
      body: _buildCollectionListView(),
      drawer: detailUI.appDrawer(context),
      floatingActionButton: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.yellow),
        child: new FloatingActionButton(
          onPressed: newCollection,
          child: new Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  ///full with Test Collections atm, will load safed collections from files
  ///Collection Methods

  void _openCollection(Collection collection) {
    logger.logM("_openCollection", Collection, collection);

    currentlyOpenCollection = collection;
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            // Add 6 lines from here...
            appBar: new AppBar(
              title: Text(collection.name),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: confirmToDeleteCollection),
                IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.red,
                    ),
                    onPressed: editCollection)
              ],
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
//                          confirmToDeleteItem(collection.savedItems[i - 1]);
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
                              Container(
                                padding: const EdgeInsets.all(1.0),
                                child: Text(
                                    collection.savedItems[i - 1].count
                                        .toString(),
                                    style: TextStyle(fontSize: 18.0)),
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
                  "Collection name", "", newCollectionNameController),
              createStuffUI.spaceDivider(),
              createStuffUI.descriptionWidget(
                  "Collection description", "", newCollectionDescController),
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
        createStuffUI.nameWidget("Item name", "", newItemNameCntrl);
    Widget itemDescriptionWidget = createStuffUI.descriptionWidget(
        "Item description", "", newItemDescCntrl);
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

  CollectionItem currentlyOpenItem;

  ///Methods for Item Details screen
  void _openItem(CollectionItem item) {
    currentlyOpenItem = item;

    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          // Add 6 lines from here...
          appBar: AppBar(
            title: Text(item.name),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: confirmToDeleteItem),
              IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.red,
                  ),
                  onPressed: editItem)
            ],
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

  final editCollectionName = TextEditingController();
  final editCollectionDesc = TextEditingController();

  void editCollection() {
    logger.logM("editCollection", null, null);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("editing " + currentlyOpenCollection.name),
        ),
        body: ListView(
          children: <Widget>[
            createStuffUI.nameWidget(
                currentlyOpenCollection.name, "", editCollectionName),
            createStuffUI.spaceDivider(),
            createStuffUI.descriptionWidget(
                currentlyOpenCollection.description, "", editCollectionDesc),
            createStuffUI.spaceDivider(),
          ],
        ),
        floatingActionButton: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.yellow),
          child: new FloatingActionButton(
            onPressed: updateCollection,
            child: new Icon(Icons.check, color: Colors.black),
          ),
        ),
      );
    }));
  }

  void confirmToDeleteCollection() {
    logger.logM("confirmToDeleteCollection", null, null);

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are about to delete this collection.'),
                Text('This Action can not be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text(
                'Delete',
                style: new TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteCollection(currentlyOpenCollection);
              },
            ),
          ],
        );
      },
    );
  }

  final editItemName = TextEditingController();
  final editItemDesc = TextEditingController();
  final editItemCount = TextEditingController();
  final editItemValue = TextEditingController();

  void editItem() {
    logger.logM("editItem", null, null);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("editing " + currentlyOpenItem.name),
        ),
        body: ListView(
          children: <Widget>[
            createStuffUI.nameWidget(currentlyOpenItem.name, "", editItemName),
            createStuffUI.spaceDivider(),
            createStuffUI.descriptionWidget(
                currentlyOpenItem.description, "", editItemDesc),
            createStuffUI.spaceDivider(),
            createStuffUI.valueWidget(
                currentlyOpenItem.value.toString(), "", editItemValue),
            createStuffUI.spaceDivider(),
            createStuffUI.countWidget(
                currentlyOpenItem.count.toString(), "", editItemCount),
            createStuffUI.spaceDivider(),
          ],
        ),
        floatingActionButton: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.yellow),
          child: new FloatingActionButton(
            onPressed: updateItem,
            child: new Icon(Icons.check, color: Colors.black),
          ),
        ),
      );
    }));
  }

  void confirmToDeleteItem() {
    logger.logM("confirmToDeleteItem", null, null);

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You are about to delete this item.'),
                Text('This Action can not be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
              child: Text(
                'Delete',
                style: new TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteItem(currentlyOpenItem);
              },
            ),
          ],
        );
      },
    );
  }

  void updateCollection() {
    String name, description;
    //TODO rewrite

    Collection newCollection;
    newCollection.currency = currentlyOpenCollection.currency;
    newCollection.savedItems = currentlyOpenCollection.savedItems;


    if (editCollectionName.text != "") {
      name = editCollectionName.text;
      newCollection.name = name;
    } else {
      newCollection.name = currentlyOpenCollection.name;
    }

    if (editCollectionDesc.text != "") {
      description = editCollectionDesc.text;
      newCollection.description = description;
    } else {
      newCollection.description = currentlyOpenCollection.description;
    }

//    logger.log(oldCollection.toString());
//    logger.log(currentlyOpenCollection.toString());

    persistence.updateCollection(currentlyOpenCollection, newCollection);

    leaveScreen();
  }

  void updateItem() {
    String name, description;
    int count, value;
    //TODO rewrite

    CollectionItem newItem;

    if (editItemName.text != "") {
      name = editItemName.text;
      newItem.name = name;
    } else {
      newItem.name = currentlyOpenItem.name;
    }

    if (editItemDesc.text != "") {
      description = editItemDesc.text;
      newItem.description = description;
    } else {
      newItem.description = currentlyOpenItem.description;
    }

    if (editItemCount.text != "") {
      count = int.parse(editItemCount.text);
      newItem.count = count;
    } else {
      newItem.count = currentlyOpenItem.count;
    }

    if (editItemValue.text != "") {
      value = int.parse(editItemValue.text);
      newItem.value = value;
    } else {
      newItem.value = currentlyOpenItem.value;
    }

    persistence.updateItem(currentlyOpenCollection.name, currentlyOpenItem, newItem);

    leaveScreen();
  }

  void deleteItem(CollectionItem item) {
    logger.logM("deleteItem", CollectionItem, item);

    currentlyOpenCollection.savedItems.remove(item);

    persistence.deleteItem(currentlyOpenCollection.name, item);
    setState(() {
      currentlyOpenItem = null;
    });
    Navigator.of(context).pop();
  }

  void deleteCollection(Collection collection) {
    logger.logM("deleteCollection", Collection, collection);

    savedCollections.remove(collection);

    persistence.deleteCollection(collection);
    setState(() {
      currentlyOpenCollection = null;
    });
    Navigator.of(context).pop();
  }

  void openSettingsMenu() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Center(
          child: Text('This function is not yet implemented. \n '
              'But hang in there, it will come sooner than you think.'),
        ),
      );
    }));
  }

  void openAbout() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('About'),
        ),
        body: ListView(
          children: <Widget>[
            detailUI.createdBy(),
            createStuffUI.spaceDivider(),
            detailUI.contactInfo(),
            createStuffUI.spaceDivider(),
            detailUI.declarationOfSomething(),
            createStuffUI.spaceDivider(),
            detailUI.versionInfo(),
            createStuffUI.spaceDivider(),
          ],
        ),
      );
    }));
  }
}
