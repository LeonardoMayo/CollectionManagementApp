import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'collection.dart';
import 'collection_ui.dart';
import 'item_ui.dart';
import 'dart:io';

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
  _StartPageState createState() => new _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<Collection> _savedCollections = new List<Collection>();

  CollectionUI collectionUI = new CollectionUI();
  ItemUI itemUI = new ItemUI();

  FloatingActionButton addButton;

  ///Build Method, most important
  @override
  Widget build(BuildContext context) {
    if (_savedCollections.length == 0) {
      _loadCollectionsOnStartup();
    }

    addButton = FloatingActionButton(
      onPressed: _newCollection,
      tooltip: 'New Collection',
      child: new Icon(Icons.add),
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
  void _loadCollectionsOnStartup() {
    Collection collection1 = new Collection("Test Collection1", "More blabla", [
      new CollectionItem("Item11", "blablubb", 2, null),
      new CollectionItem("Item21", "blubbBla", 3, null)
    ]);

    Collection collection2 = new Collection("Test Collection2", "More blabla", [
      new CollectionItem("Item12", "blablubb", 2, null),
      new CollectionItem("Item22", "blubbBla", 3, null)
    ]);

    _savedCollections.add(collection1);
    _savedCollections.add(collection2);

    if (doesTestFileExist()){
      Collection collection3;

      readCollection().then((Collection value){
        collection3 = value;
      });

      _savedCollections.add(collection3);

    }
  }

  Collection currentCollection;

  void _openCollection(Collection collection) {
    currentCollection = collection;
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            // Add 6 lines from here...
            appBar: new AppBar(
              title: Text(collection.name),
            ),
            body:
//            new ListView(
//              children:[
//                new TextField(
//                  enabled: false,
//                  controller: new TextEditingController(text: collection.description),
//                ),
//                new Divider(),
                new ListView.builder(
                    padding: const EdgeInsets.all(18.0),
                    itemBuilder: (context, i) {
                      if (i < collection.savedItems.length) {
                        return new GestureDetector(
                            onTap: () {},
                            onLongPress: () {
                              confirmToDeleteItem(collection.savedItems[i]);
                            },
                            child: new Container(
                              padding: const EdgeInsets.all(32.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            collection.savedItems[i].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          collection.savedItems[i].description,
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(collection.savedItems[i].value
                                      .toString()),
                                  Icon(
                                    Icons.euro_symbol,
                                    color: Colors.red[500],
                                  ),
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
                child: new Icon(Icons.add),
              ),
            ), // ... to here.
          );
        },
      ),
    );
  }

  Widget _buildCollectionListView() {
    if (_savedCollections.length != 0) {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i < _savedCollections.length) {
            return ListTile(
              title: Text(
                _savedCollections[i].name,
                style: TextStyle(fontSize: 18.0),
              ),
              onTap: () {
                _openCollection(_savedCollections[i]);
              },
            );
          }
        },
      );
    } else {
      return new Center(
          child: Text(
              "You don't have any collections yet! Tap the '+' below to create one!"));
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
              title: Text('New Collection'),
            ),
            body: new ListView(children: [
              new TextField(
                controller: newCollectionNameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Collection name",
                ),
              ),
              new TextField(
                controller: newCollectionDescController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Collection description",
                ),
              ),
            ]),
            floatingActionButton: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.yellow),
              child: new FloatingActionButton(
                onPressed: addCollection,
                tooltip: 'New Item',
                child: new Icon(Icons.check),
              ),
            ),
          ); // ... to here.
        },
      ),
    );
  }

  void addCollection() {
    Collection collection = new Collection(newCollectionNameController.text,
        newCollectionDescController.text, new List<CollectionItem>());
    _savedCollections.add(collection);
    leaveScreen();

    writeCollection(collection);

  }

  final newItemNameCntrl = TextEditingController();
  final newItemDescCntrl = TextEditingController();
  final newItemValueCntrl = TextEditingController();

  ///Methods for displaying the Making of a new Item
  void _newItem() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
              // Add 6 lines from here...
              appBar: new AppBar(
                title: Text('New Item'),
              ),
              body: new ListView(children: [
                new TextField(
                  controller: newItemNameCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Item name",
                  ),
                ),
                new TextField(
                  controller: newItemDescCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Item description",
                  ),
                ),
                new TextField(
                  controller: newItemValueCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Item value",
                  ),
                ),
              ]),
              floatingActionButton: Theme(
                data: Theme.of(context).copyWith(accentColor: Colors.yellow),
                child: new FloatingActionButton(
                  onPressed: addItem,
                  tooltip: 'New Item',
                  child: new Icon(Icons.check),
                ),
              )); // ... to here.
        },
      ),
    );
  }

  void addItem(){
    int value = int.parse(newItemValueCntrl.text);
    CollectionItem item = new CollectionItem(newItemNameCntrl.text, newItemDescCntrl.text, value, null);
    currentCollection.addItem(item);
    leaveScreen();
  }

  void leaveScreen(){
    Navigator.of(context).pop();

    newCollectionNameController.text = "";
    newCollectionDescController.text = "";

    newItemNameCntrl.text = "";
    newItemDescCntrl.text = "";
    newItemValueCntrl.text = "";
  }

  ///Filesave Methods

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  bool doesTestFileExist() {
    File file;
    _localFile.then((File value){file = value;});
    return file.existsSync();
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/collectiontest.txt');
  }

  void writeCollection(Collection collection) async {

    final file = await _localFile;

    String name = collection.name;
    String description = collection.description;

    List<String> sItems = new List<String>();
    for(int i = 0; i < collection.savedItems.length; i++){
      CollectionItem item = collection.savedItems[i];
      String result = item.name+";"+item.description+";"+item.value.toString();
      sItems.add(result);
    }

    var sink = file.openWrite();

    sink.writeln(name);
    sink.writeln(description);

    for(int i = 0; i < sItems.length; i++){
      sink.writeln(sItems[i]);
    }

    sink.close();

  }

  Future<Collection> readCollection() async {
    try {
      final file = await _localFile;


      // Read the file
      List<String> contents = await file.readAsLines();

      String name = "";
      String description = "";
      List<CollectionItem> loadedItems = new List<CollectionItem>();

      name = contents[0];
      description = contents[1];

      for(int i = 2; i < contents.length; i++){

          String sItem = contents[i];
          List<String> sItemParts = sItem.split(';');
          CollectionItem item = new CollectionItem(
              sItemParts[0], sItemParts[1], int.parse(sItemParts[2]), null
          );

          loadedItems.add(item);
      }

      return new Collection(name, description, loadedItems);
    } catch (e) {
      // If we encounter an error, return 0
      return null;
    }
  }

}