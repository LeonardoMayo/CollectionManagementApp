import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'collection.dart';
import 'logger.dart';

class Persistence {
  Logger logger;

  ///Class fields
  StartPageState homePage;
  String appPath;
  String filePath;
  File managementFile;
  List<File> files;
  List<Collection> loadedCollections;
  bool isLoaded;

  Persistence(StartPageState startPage) {
    homePage = startPage;

    logger = new Logger("Persistence");

    loadedCollections = List<Collection>();

    setAppPath();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void setAppPath() {
    getApplicationDocumentsDirectory().then((Directory dir) {
      dir.createSync();
      appPath = dir.path;
      Directory collectionDir = new Directory(appPath + "/collections/");
      collectionDir.createSync(recursive: true);
      print(collectionDir.path);
      String result = appPath + "/collections/";

      filePath = collectionDir.path;
      loadAppManagementFile();
    });
  }

  void setFilePath() async {
    String result = appPath + "/collections/";

    filePath = result;
  }

  void loadAppManagementFile() {
    logger.log("loadAppManagementFile() Method");

    File file;
    File(appPath + "/appmanager.txt").exists().then((bool exists) {
      logger.log("File " + exists.toString());
      if (exists) {
        //return file
        file = File(appPath + "/appmanager.txt");
        managementFile = file;
        file.readAsLines().then((List<String> data) {
          loadAllKnownCollections(data);
        });
      } else {
        //create and return file
        File(appPath + "/appmanager.txt").create().then((File createdFile) {
          file = createdFile;
          var sink = file.openWrite();
          sink.close();
          managementFile = file;
//          file.readAsLines().then((List<String> data) {
//            loadAllKnownCollections(data);
//          });
        });
      }
    });
  }

  void loadAllKnownCollections(List<String> data) {
    logger.log(
        "loadAllKnownCollections Method with List<String> " + data.toString());
    for (int i = 0; i < data.length; i++) {
      _loadCollectionFromFile(data[i]);
    }
    isLoaded = true;
    logger.log(loadedCollections.toString());
  }

  void _loadCollectionFromFile(String fileName) {

    logger.logM("_loadCollectionFromFile", String, fileName);
    String currentPath = filePath + fileName+".txt";

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
      Collection collection = Collection(name, description, savedItems, currency);
      logger.log(collection.toString());
//      return collection;
      loadedCollections.add(collection);
    });

//    return null;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/collectiontest.txt');
  }

  File _getCorrectFile(String name) {
    final path = filePath + "" + name + ".txt";
    try {
      return new File(path);
    } catch (e) {
      return null;
    }
  }

  void createNewCollectionFile(Collection collection) {
    logger.log("createNewCollectionFile Method with Collection " +
        collection.toString());

    String name = collection.name;
    String description = collection.description;
    String currency = collection.currency;

    File file = File(filePath + name + ".txt");
    logger.log(file.path);
    var sink = file.openWrite();

    sink.writeln(name);
    sink.writeln(description);
    sink.writeln(currency);

    sink.close();
    writeCollectionNameIntoManagementFile(name);
  }

  void writeItemIntoCollectionFile(
      Collection collection, CollectionItem item) async {
    logger.log("writeItemIntoCollectionFile Method with Collection "+collection.toString()+"and Item "+item.toString());
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
    logger.log("writeCollectionNameIntoManagementFile Method with String "+name);
    if (name != null && name != "") {
      var sink = managementFile.openWrite();
      sink.writeln(name);
      sink.close();

      logger.log(managementFile.readAsStringSync());
    }
  }

  ///Base Method
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
}
