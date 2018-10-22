import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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


  String filePath;

  @override
  initState(){
    super.initState();

    setFilePath();
//    if (_savedCollections.length == 0) {
//      _loadCollectionsOnStartup();
//    }
    loadAppManagementFile();
  }

  @override
  dispose(){
    super.dispose();
  }

  void loadAppManagementFile() async{
    File file = await _collectionManagementFile;

    file.readAsLines().then((List<String> data){
      setState(() {

        for(int i = 0; i < data.length; i++){
          _loadCollectionFromFile(data[i]);
        }

      });
    });

  }

  ///Build Method, most important
  @override
  Widget build(BuildContext context) {

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
    Collection collection1 = new Collection(
        "Test Collection1",
        "More blabla",
        [
          new CollectionItem("Item11", "blablubb", 2, 1,null),
          new CollectionItem("Item21", "blubbBla", 3, 1,null)
        ],
        "EUR");

    Collection collection2 = new Collection(
        "Test Collection2",
        "More blabla",
        [
          new CollectionItem("Item12", "blablubb", 2, 1,null),
          new CollectionItem("Item22", "blubbBla", 3, 1,null)
        ],
        "USD");

    _savedCollections.add(collection1);
    _savedCollections.add(collection2);
//    var path = getApplicationDocumentsDirectory();
//    if (File('$path/collectiontest.txt') != null){
//      Collection collection3;
//
//      readCollection().then((Collection value){
//        collection3 = value;
//      });
//
//      _savedCollections.add(collection3);
//
//    }
  }

  void _loadCollectionFromFile( String fileName){
    String currentPath = filePath + fileName;
    print( currentPath);

    File file = File(currentPath);
    file.readAsLines().then((List<String> lines) {
      String name, description, currency;
      List<CollectionItem> savedItems = new List<CollectionItem>();

      name = lines[0];
      description = lines[1];
      currency = lines[2];

      for(int i = 3; i < lines.length; i++){
        List<String> contents = lines[i].split(";");

        String itemName, itemDesc, itemPicPath;
        int itemValue, itemCount;

        itemName = contents[0];
        itemDesc = contents[1];
        itemValue = int.parse(contents[2]);
        itemCount = int.parse(contents[3]);
        itemPicPath = contents[4];

        savedItems.add(CollectionItem(itemName, itemDesc, itemValue, itemCount, itemPicPath));
      }

      _savedCollections.add(Collection(name, description, savedItems, currency));

    });
  }

  Collection currentCollection;

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
          spaceDivider()
        ],
      ),
    );

    currentCollection = collection;
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
                        onTap: () {_openItem(collection.savedItems[i - 1]);},
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
                              valueWidgetIcon(20.0),
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
              spaceDivider(),
              nameWidget("Collection name"),
              spaceDivider(),
              descriptionWidget("Collection description"),
              spaceDivider(),
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
                  color: Colors.grey[800],
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
    setState(() {
      print(value.toString());
      _radioValue = value;
    });
  }

  void addCollection() {
    Collection collection = new Collection(newCollectionNameController.text,
        newCollectionDescController.text, new List<CollectionItem>(), "");
    _savedCollections.add(collection);
    leaveScreen();

    writeCollection(collection);
  }

  final newItemNameCntrl = TextEditingController();
  final newItemDescCntrl = TextEditingController();
  final newItemValueCntrl = TextEditingController();
  final newItemCountCntrl = TextEditingController();
  final newItemPhotoCntrl = TextEditingController();

  ///Methods for displaying the Making of a new Item
  void _newItem() {
    Widget itemNameWidget = nameWidget("Item name");
    Widget itemDescriptionWidget = descriptionWidget("Item description");
    Widget itemValueWidget = valueWidget("Item value", "");
    Widget itemCountWidget = countWidget("Item count", "");
    Widget itemFotoWidget = photoWidget(null);

    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            // Add 6 lines from here...
              appBar: new AppBar(
                title: Text('New Item'),
              ),
              body: new ListView(children: [
                spaceDivider(),
                itemNameWidget,
                spaceDivider(),
                itemDescriptionWidget,
                spaceDivider(),
                itemValueWidget,
                spaceDivider(),
                itemCountWidget,
                spaceDivider(),
                itemFotoWidget,
              ]),
              floatingActionButton: Theme(
                data: Theme.of(context).copyWith(accentColor: Colors.yellow),
                child: new FloatingActionButton(
                  onPressed: addItem,
                  tooltip: 'New Item',
                  child: new Icon(Icons.check),
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
        newItemNameCntrl.text, newItemDescCntrl.text, value,count, null);
    currentCollection.addItem(item);
    writeItemIntoCollectionFile(currentCollection, item);
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

  Widget spaceDivider() {
    return SizedBox(
      height: 20.0,
      width: 100.0,
    );
  }

  ///Multiple usable Widgets
  Widget nameWidget(String text) {
    return Row(
      children: <Widget>[
        Expanded(
          child: new Column(
            children: <Widget>[
              spaceDivider(),
              new Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius:
                    new BorderRadius.all(new Radius.circular(18.0)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 3.0,
                      style: BorderStyle.solid,
                    )),
                child: new TextField(
                  controller: newItemNameCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: text,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget descriptionWidget(String text) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: 50.0,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 3.0,
                      style: BorderStyle.solid,
                    )),
                child: TextField(
                  controller: newItemDescCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget valueWidget(String hinttext, String text) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius:
                    new BorderRadius.all(new Radius.circular(18.0)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 3.0,
                      style: BorderStyle.solid,
                    )),
                child: TextField(
                  controller: newItemValueCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hinttext,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(10.0), child: valueWidgetIcon(40.0)),
          ],
        ),
      ],
    );
  }

  Widget valueWidgetIcon(double size) {
    if (currentCollection.currency.contains("EUR")) {
      return Container(
        child: Icon(
          Icons.euro_symbol,
          color: Colors.red,
          size: size,
        ),
      );
    } else {
      return Container(
        child: Icon(
          Icons.attach_money,
          color: Colors.red,
          size: size,
        ),
      );
    }
  }

  Widget countWidget(String hinttext, String text) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius:
                    new BorderRadius.all(new Radius.circular(18.0)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 3.0,
                      style: BorderStyle.solid,
                    )),
                child: TextField(
                  controller: newItemCountCntrl,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hinttext,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.playlist_play,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget photoWidget(CollectionItem item) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: photoWidgetImagePart(item),
            ),
          ],
        ),
        Expanded(
          child: Column(children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  left: 100.0, top: 20.0, right: 100.0, bottom: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(new Radius.circular(18.0)),
                border: Border.all(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                "Item picture",
                textAlign: TextAlign.center,
              ),
            ),
          ]),
        ),
        Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.camera_enhance,
                    color: Colors.red,
                    size: 40.0,
                  ),
                  onTap: openCameraActivity(),
                )),
          ],
        ),
      ],
    );
  }

  Widget photoWidgetImagePart(CollectionItem item) {
    if (item != null && item.picture == null) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: Image.network(item.picturePath),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
        ),
        child: Icon(
          Icons.camera_alt,
          color: Colors.grey[700],
          size: 40.0,
        ),
      );
    }
  }

  openCameraActivity() {
    print("camera");
  }

  ///Methods for Item Details screen
  void _openItem(CollectionItem item) {

    Widget body = Container();
    Navigator.of(context).push(
        new MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return new Scaffold(
                // Add 6 lines from here...
                appBar: new AppBar(
                  title: Text(item.name),
                ),
                body: spaceDivider(),
              );
            }));
  }

  ///Persistence Methods
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void setFilePath() async {
    final rawPath = await getApplicationDocumentsDirectory();
    String result = rawPath.path + "/collections/";

    filePath = result;

  }

  bool doesTestFileExist() {
    File file;
    _localFile.then((File value) {
      file = value;
    });
    bool result;
    file.exists().then((bool value) {
      result = value;
    });
    return result;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/collectiontest.txt');
  }

  Future<File> get _collectionManagementFile async {
    final path = await _localPath;
    try {
      return File("$path/appmanager.txt");
    } catch (e) {
      File file = new File("$path/appmanager.txt");
      return file;
    }
  }

  File _getCorrectFile(String name){
    final path = filePath + name;
    try {
      return new File(path);
    } catch(e){

    }
  }

  void writeCollection(Collection collection) async {
    final file = _getCorrectFile(collection.name);

    String name = collection.name;
    String description = collection.description;
    String currency = collection.currency;

    List<String> sItems = new List<String>();
    for (int i = 0; i < collection.savedItems.length; i++) {
      CollectionItem item = collection.savedItems[i];
      String result =
          item.name + ";" + item.description + ";" + item.value.toString() +";"+item.count.toString();
      sItems.add(result);
    }

    var sink = file.openWrite();

    sink.writeln(name);
    sink.writeln(description);
    sink.writeln(currency);

    for (int i = 0; i < sItems.length; i++) {
      sink.writeln(sItems[i]);
    }

    sink.close();
  }

  void writeItemIntoCollectionFile(Collection collection, CollectionItem item) async {
    final file = _getCorrectFile(collection.name);

    String result = item.name + ";" + item.description + ";" + item.value.toString() +";"+item.count.toString();
    var sink = file.openWrite();

    sink.writeln(result);

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
      String currency = "";

      name = contents[0];
      description = contents[1];

      for (int i = 2; i < contents.length; i++) {
        String sItem = contents[i];
        List<String> sItemParts = sItem.split(';');
        CollectionItem item = new CollectionItem(
            sItemParts[0], sItemParts[1], int.parse(sItemParts[2]),int.parse(sItemParts[3]), null);

        loadedItems.add(item);
      }

      return new Collection(name, description, loadedItems, currency);
    } catch (e) {
      // If we encounter an error, return 0
      return null;
    }
  }
}
