import 'package:flutter/material.dart';
import 'collection.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Collection Management',
      theme: new ThemeData(
        primaryColor: Colors.black,
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
  int _counter = 0;
  List<Collection> _savedCollections = new List<Collection>();

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  void _loadCollectionsOnStartup(){
    Collection collection1 = new Collection("Test Collection1", "More blabla", [new CollectionItem("Item11", "blablubb", 2, null),
    new CollectionItem("Item21", "blubbBla", 3, null)]);

    Collection collection2 = new Collection("Test Collection2", "More blabla", [new CollectionItem("Item12", "blablubb", 2, null),
    new CollectionItem("Item22", "blubbBla", 3, null)]);

    _savedCollections.add(collection1);
    _savedCollections.add(collection2);
  }

  void _newCollection(){


//    _openCollection(collection);
  }

  void _openCollection (Collection collection){
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {


          return new Scaffold(         // Add 6 lines from here...
            appBar: new AppBar(
              title: Text(collection.name),
            ),
            body: new ListView(),
          );                           // ... to here.
        },
      ),
    );
  }

  Widget _buildListView(){
    if (_savedCollections.length != 0){
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i){
          if (i < _savedCollections.length){
            return _buildRow(_savedCollections[i]);
          }
        },
      );
    }
    else {
      return new Center(
        child: Text("You don't have any collections yet! Tap the '+' below to create one!")
      );
    }

  }

  Widget _buildRow(Collection collection){
    return ListTile(
      title: Text (
        collection.name,
        style: TextStyle(fontSize: 18.0),
      ),
      onTap: () {
        _openCollection(collection);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_savedCollections.length == 0){
      _loadCollectionsOnStartup();
    }

    return new Scaffold(
      appBar: new AppBar(

        title: new Text(widget.title),

      ),

      body: _buildListView(),

      drawer: new Drawer(
          child: new ListView(
            children: <Widget> [
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
          )
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: _newCollection,
        tooltip: 'New Collection',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CollectionPage extends StatefulWidget{
  CollectionPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _CollectionPageState createState() => new _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

}