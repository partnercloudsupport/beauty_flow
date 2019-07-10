import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:beauty_flow/util/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewPostPage extends StatefulWidget {
  NewPostPage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  File file;
  final _formKey = GlobalKey<FormState>();
  final Firestore _db = Firestore.instance;
  String _style;
  int _price;
  int _duration;
  String _beautyPro;
  String _decription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Beauty Flow")),
      ),
      body: new Container(
        color: Colors.white,
        child: Builder(
          builder: (context) => Form(
                key: _formKey,
                child: new ListView(
                  children: <Widget>[
                    _isLoading == true
                        ? LinearProgressIndicator()
                        : Container(),
                    Column(
                      children: <Widget>[
                        new Container(
                          height: 210.0,
                          color: Colors.white,
                          child: new Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.0, left: 20.0),
                                child: new Stack(
                                  fit: StackFit.loose,
                                  children: <Widget>[
                                    new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        new Container(
                                          width: 140.0,
                                          height: 140.0,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            image: new DecorationImage(
                                              image: file == null
                                                  ? new ExactAssetImage(
                                                      'assets/img/as.png')
                                                  : FileImage(file),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 90.0, right: 275.0),
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 25.0,
                                            child: new IconButton(
                                              icon: Icon(Icons.camera_alt),
                                              color: Colors.white,
                                              onPressed: () {
                                                _selectImage(context);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        new Container(
                          color: Color(0xffFFFFFF),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 25.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 25.0, right: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Style Name',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextFormField(
                                          decoration: const InputDecoration(
                                            hintText: "Enter Style",
                                          ),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please enter style';
                                            }
                                          },
                                          onSaved: (val) =>
                                              setState(() => _style = val),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Price',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextFormField(
                                            decoration: const InputDecoration(
                                              hintText: "Enter Price",
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter price.';
                                              }
                                            },
                                            onSaved: (val) => setState(
                                                () => _price = int.parse(val))),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Duration',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextFormField(
                                            decoration: const InputDecoration(
                                              hintText: "Enter Duration in Min",
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter duration.';
                                              }
                                            },
                                            onSaved: (val) => setState(() =>
                                                _duration = int.parse(val))),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Beauty Pro',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextFormField(
                                            decoration: const InputDecoration(
                                              hintText: "BeautyFlow",
                                            ),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter Beauty Pro';
                                              }
                                            },
                                            onSaved: (val) => setState(
                                                () => _beautyPro = val)),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 25.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new Text(
                                            'Description',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25.0, right: 25.0, top: 2.0),
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new Flexible(
                                        child: new TextFormField(
                                            decoration: const InputDecoration(
                                              hintText:
                                                  "Tell us about the treatment",
                                            ),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter description';
                                              }
                                            },
                                            onSaved: (val) => setState(
                                                () => _decription = val)),
                                      ),
                                    ],
                                  ),
                                ),
                                _getActionButtons()
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                child: new RaisedButton(
                  child: new Text("Save"),
                  textColor: Colors.white,
                  color: Colors.green,
                  onPressed: () {
                    final form = _formKey.currentState;
                    if (form.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      form.save();
                      _getDownloadUrl();
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Saving Data')));
                    }
                  },
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                child: new RaisedButton(
                  child: new Text("Cancel"),
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                      file = null;
                    });
                    _formKey.currentState?.reset();
                  },
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog<Null>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1350);
                  setState(() {
                    file = imageFile;
                  });
                }),
            SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = imageFile;
                  });
                }),
            SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future _getDownloadUrl() async {
    try {
      DocumentSnapshot user =
          await _db.collection('users').document(widget.userId).get();
      String fileId = randomString(5);
      StorageReference reference =
          FirebaseStorage.instance.ref().child("$fileId.jpg");
      StorageUploadTask uploadTask = reference.putFile(file);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      var fsReference = _db.collection('beautyPosts');
      int count = 0;

      QuerySnapshot ref = await _db.collection("styles").getDocuments();
      if (ref.documents.isNotEmpty) {
        count = ref.documents.length;
      }

      QuerySnapshot docExists = await _db
          .collection("styles")
          .where("styleName", isEqualTo: _style)
          .getDocuments();

      if (docExists.documents.isEmpty) {
        var sReference = _db.collection('styles').document((count).toString());

        sReference.setData({
          "styleName": _style,
          "bookings": 0,
          "timestamp": DateTime.now(),
        }, merge: true);
      } else {
        var list = docExists.documents.toList();
        print(list);
        var sReference = _db.collection('styles').document(list[0].documentID);
        sReference.updateData({
          "timestamp": DateTime.now(),
        });
      }

      fsReference.add({
        "displayName": user.data["displayName"],
        "style": _style,
        "price": _price,
        "duration": _duration,
        "beautyPro": _beautyPro,
        "likes": {},
        "mediaUrl": downloadUrl,
        "description": _decription,
        "ownerId": user.data["uid"],
        "timestamp": DateTime.now(),
      }).then((DocumentReference doc) {
        String docId = doc.documentID;
        fsReference.document(docId).updateData({"postId": docId});
      });
      setState(() {
        file = null;
        _isLoading = false;
      });
      _formKey.currentState?.reset();
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Data Uploaded')));
    } catch (exception, stackTrace) {
      print("exception: $exception");
      print("stackTrace: $stackTrace");
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Try Again')));
      setState(() {
        file = null;
        _isLoading = false;
      });
      _formKey.currentState?.reset();
    }
  }
}
