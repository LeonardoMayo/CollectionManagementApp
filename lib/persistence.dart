import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'collection.dart';

class Persistence {

  ///Class fields
  StartPageState homePage;
  String appPath;
  String filePath;
  File managementFile;
  List<Collection> loadedCollections;

  Persistence(StartPageState startPage) {
    homePage = startPage;

    loadedCollections = List<Collection>();

    setAppPath();
    setFilePath();
    loadAppManagementFile();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void setAppPath() {
    appPath = "/data/user/0/jpl.software.collectionmanagement/files";
  }

  void setFilePath() {
    String result = appPath + "/collections/";

    filePath = result;
  }

  void loadAppManagementFile() async {
    File file = await _collectionManagementFile;

    if (file == null) {
      final path = await _localPath;
      file = new File("$path/appmanager.txt");
      managementFile = file;
    } else {
      managementFile = file;
      file.readAsLines().then((List<String> data) {
        loadAllKnownCollections(data);
      });
    }
  }

  void loadAllKnownCollections(List<String> data) {
    for (int i = 0; i < data.length; i++) {
      loadedCollections.add(_loadCollectionFromFile(data[i]));
    }
  }

  Collection _loadCollectionFromFile(String fileName) {
    String currentPath = filePath + fileName;
    print(currentPath);

    File file = File(currentPath);
    file.readAsLines().then((List<String> lines) {
      String name, description, currency;
      List<CollectionItem> savedItems = new List<CollectionItem>();

      name = lines[0];
      description = lines[1];
      currency = lines[2];

      for (int i = 3; i < lines.length; i++) {
        List<String> contents = lines[i].split(";");

        String itemName, itemDesc, itemPicPath;
        int itemValue, itemCount;

        itemName = contents[0];
        itemDesc = contents[1];
        itemValue = int.parse(contents[2]);
        itemCount = int.parse(contents[3]);
        itemPicPath = contents[4];

        savedItems.add(CollectionItem(
            itemName, itemDesc, itemValue, itemCount, itemPicPath));
      }

      return Collection(name, description, savedItems, currency);
    });

    return null;
  }

//  bool doesTestFileExist() {
//    File file;
//    _localFile.then((File value) {
//      file = value;
//    });
//    bool result;
//    file.exists().then((bool value) {
//      result = value;
//    });
//    return result;
//  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/collectiontest.txt');
  }

  Future<File> get _collectionManagementFile async {
    final path = appPath;
    try {
      return File("$path/appmanager.txt");
    } catch (e) {
      File file = new File("$path/appmanager.txt");
      return file;
    }
  }

  File _getCorrectFile(String name) {
    final path = filePath + "" + name +".txt";
    try {
      return new File(path);
    } catch (e) {
      return null;
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
      String result = item.name +
          ";" +
          item.description +
          ";" +
          item.value.toString() +
          ";" +
          item.count.toString();
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

  void writeItemIntoCollectionFile(
      Collection collection, CollectionItem item) async {
    final file = _getCorrectFile(collection.name);

    String result = item.name +
        ";" +
        item.description +
        ";" +
        item.value.toString() +
        ";" +
        item.count.toString();
    var sink = file.openWrite();

    sink.writeln(result);

    sink.close();
  }

  void writeCollectionNameIntoManagementFile(String name) {
    if (name != null && name != ""){
      var sink = managementFile.openWrite();
      sink.writeln(name);
      sink.close();
    }
  }

//  Future<Collection> readCollection() async {
//    try {
//      final file = await _localFile;
//
//      // Read the file
//      List<String> contents = await file.readAsLines();
//
//      String name = "";
//      String description = "";
//      List<CollectionItem> loadedItems = new List<CollectionItem>();
//      String currency = "";
//
//      name = contents[0];
//      description = contents[1];
//
//      for (int i = 2; i < contents.length; i++) {
//        String sItem = contents[i];
//        List<String> sItemParts = sItem.split(';');
//        CollectionItem item = new CollectionItem(sItemParts[0], sItemParts[1],
//            int.parse(sItemParts[2]), int.parse(sItemParts[3]), null);
//
//        loadedItems.add(item);
//      }
//
//      return new Collection(name, description, loadedItems, currency);
//    } catch (e) {
//      // If we encounter an error, return 0
//      return null;
//    }
//  }
}
