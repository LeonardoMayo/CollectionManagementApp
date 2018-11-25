import 'package:flutter/material.dart';
import 'collection.dart';
import 'main.dart';

class CreateStuffUI{

  HomePageState homePage;

  CreateStuffUI(HomePageState startPage){
    homePage = startPage;
  }

  ///Multiple usable Widgets
  Widget nameWidget(String hinttext, String text, TextEditingController controller) {
//    controller.text = text;

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
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hinttext,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget descriptionWidget(String hinttext, String text, TextEditingController controller) {
//    controller.text = text;

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
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hinttext,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget valueWidget(String hinttext, String text, TextEditingController controller) {
//    controller.text = text;

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
                  controller: controller,
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
                padding: EdgeInsets.all(10.0), child: valueWidgetIcon("EUR", 40.0)),
          ],
        ),
      ],
    );
  }

  Widget valueWidgetIcon(String currency, double size) {
    if (currency.contains("EUR")) {
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

  Widget countWidget(String hinttext, String text, TextEditingController controller) {
//    controller.text = text;

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
                  controller: controller,
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

  Widget spaceDivider() {
    return SizedBox(
      height: 20.0,
      width: 20.0,
    );
  }

  countWidgetIcon(double textsize) {
    return Container(
      child: Icon(
        Icons.dehaze,
        color: Colors.red,
        size: textsize,
      ),
    );
  }

}