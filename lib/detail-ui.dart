import 'main.dart';
import 'creation-ui.dart';
import 'constants.dart';
import 'logger.dart';
import 'package:flutter/material.dart';

class DetailUI {
  HomePageState homePage;
  CreateStuffUI createStuffUI;
  Constants constants;
  Logger logger;

  DetailUI(HomePageState homePage) {
    this.homePage = homePage;
    createStuffUI = homePage.createStuffUI;

    constants = Constants();
    logger = Logger("DeatilUI");
  }

  Widget headerItem(String name, String description) {
    return Container(
      padding: EdgeInsets.all(50.0),
      decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.grey, style: BorderStyle.solid)),
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              name,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
          createStuffUI.spaceDivider(),
          Text(
            description,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Drawer appDrawer(BuildContext context) {
    return Drawer(
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
    ));
  }

  int currentType;

  Widget customFab(BuildContext context, Icon icon, int type) {
    currentType = type;
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.yellow),
        child: FloatingActionButton(
          onPressed: _runFittingMethod,
          tooltip: 'New Collection',
          child: icon,
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  _runFittingMethod() {
    logger.logM("_runFittingMethod", int, currentType);
    switch (currentType) {
      // ignore: non_constant_case_expression
      case 1:
        homePage.newCollection();
        break;
      // ignore: non_constant_case_expression
      case 3:
        homePage.newItem();
        break;
      // ignore: non_constant_case_expression
      case 2:
        homePage.addCollection();
        break;
      // ignore: non_constant_case_expression
      case 4:
        homePage.addItem();
        break;
    }
  }

  Widget itemValueField(int value, Icon currency) {

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: <Widget>[
          Expanded(child:
            Text(value.toString(),
              style: TextStyle(fontSize: 20.0,),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: createStuffUI.valueWidgetIcon(
              homePage.currentlyOpenCollection.currency, 40.0),),
        ],),
    );
  }

  Widget itemCountField(int value) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: <Widget>[
          Expanded(child:
          Text(value.toString(),
            style: TextStyle(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
          ),
          Expanded(child: createStuffUI.countWidgetIcon(40.0),),
        ],),
    );
  }
}
