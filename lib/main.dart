import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final message = "Initial Message.";
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Sample',
      home: MyPage(message: this.message),
    );
  }
}

class MyPageState extends State<MyPage> {
  String _time;
  File _image;
  final _stateController = TextEditingController();
  final _visionTextController = TextEditingController();
  //final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.cloudTextRecognizer();

  @override
  void initState() {
    super.initState();
    this._time = "Tap Floating Action Button";
  }

  @override
  void dispose() {
    this._stateController.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      this._image = File(image.path);
    });
  }

  Future<void> vision() async {
    if (this._image != null) {
      FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(this._image);

      VisionText visionText = await textRecognizer.processImage(visionImage);

      String text = visionText.text;
      print(text);

      var buf = new StringBuffer();
      for (TextBlock block in visionText.blocks) {
        final List<RecognizedLanguage> languages = block.recognizedLanguages;
        print(languages);
        buf.write("=====================\n");
        for (TextLine line in block.lines) {
          buf.write("${line.text}\n");
        }
      }
      setState(() {
        this._visionTextController.text = buf.toString();
      });
    }
  }

  void showTime() {
    setState(() {
      this._time = DateTime.now().toString();
    });
  }

  void loadOnPressed() {
    FirebaseFirestore.instance
        .doc("sample/sandwichData")
        .get()
        .then((DocumentSnapshot ds) {
      setState(() {
        this._stateController.text = ds["hotDogStatus"];
      });
      print("status=$this.status");
    });
  }

  void saveOnPressed() {
    FirebaseFirestore.instance
        .doc("sample/sandwichData")
        .update({"hotDogStatus": _stateController.text})
        .then((value) => print("success"))
        .catchError((value) => print("error $value"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Firebase Sample'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this._time,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: TextField(
                            controller: _stateController,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(2.0),
                          child: RaisedButton(
                              onPressed: saveOnPressed, child: Text("Save")),
                        ),
                        Padding(
                            padding: EdgeInsets.all(2.0),
                            child: RaisedButton(
                                onPressed: loadOnPressed, child: Text("Load")))
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: RaisedButton(
                                onPressed: getImage,
                                child: Text("Pick Image"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: RaisedButton(
                                onPressed: () {
                                  print('aaaaa');
                                  vision();
                                },
                                child: Text("Vision Api"),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _visionTextController,
                          minLines: 6,
                          maxLines: 15,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Container(
                          //width: MediaQuery.of(context).size.width,
                          //height: 300,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: _image == null
                                ? Text('No image selected.')
                                : Image.file(_image),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTime,
        child: Icon(Icons.timer),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  final String message;
  MyPage({this.message}) : super();
  @override
  State<StatefulWidget> createState() => new MyPageState();
}
