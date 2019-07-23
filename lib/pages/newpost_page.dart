import 'dart:io';
import 'package:beauty_flow/Model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
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
  User _beautyPro;
  String _decription;
  bool _isLoading = false;

  List<User> listUser = List<User>();

  // Focus Fields
  final FocusNode _styleName = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _durationFocus = FocusNode();
  final FocusNode _description = FocusNode();
  final FocusNode _beautyProFocus = FocusNode();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    Firestore _db = Firestore.instance;
    var userRef = await _db
        .collection('users')
        .where('isPro', isEqualTo: true)
        .getDocuments();
    print(userRef.documents);
    userRef.documents.forEach((f) {
      var user = User.fromDocument(f);
      listUser.add(user);
    });
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return new Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Beauty Flow")),
      ),
      body: Stack(
        children: <Widget>[
          _showBody(height),
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(
        child: SpinKitChasingDots(
          color: Colors.blueAccent,
          size: 60.0,
        ),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showBody(height) {
    return Container(
      color: Colors.white,
      child: Builder(
        builder: (context) => Form(
          key: _formKey,
          child: new ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    height: 170.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 0.0),
                          child: new Stack(
                            fit: StackFit.loose,
                            children: <Widget>[
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                padding:
                                    EdgeInsets.only(top: 70.0, left: 70.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, right: 25.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              focusNode: _styleName,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _styleName, _priceFocus);
                              },
                              decoration: InputDecoration(
                                labelText: 'STYLE',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return 'Style can\'t be empty';
                                }
                              },
                              onSaved: (value) => _style = value,
                            ),
                          ),
                          SizedBox(height: height < 600 ? 0 : 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, right: 25.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              focusNode: _priceFocus,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _priceFocus, _durationFocus);
                              },
                              decoration: InputDecoration(
                                labelText: 'PRICE',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return 'Price can\'t be empty';
                                }
                              },
                              onSaved: (value) => _price = int.parse(value),
                            ),
                          ),
                          SizedBox(height: height < 600 ? 0 : 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, right: 25.0),
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              focusNode: _durationFocus,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _durationFocus, _description);
                              },
                              decoration: InputDecoration(
                                labelText: 'DURATION',
                                hintText: "Enter Duration in Min",
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return 'Duration can\'t be empty';
                                }
                              },
                              onSaved: (value) => _duration = int.parse(value),
                            ),
                          ),
                          SizedBox(height: height < 600 ? 0 : 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, right: 25.0),
                            child: TextFormField(
                              maxLines: 2,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              focusNode: _description,
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _description, _beautyProFocus);
                              },
                              decoration: InputDecoration(
                                labelText: 'DESCRITION',
                                hintText: "Tell us about treatment",
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              textInputAction: TextInputAction.newline,
                              validator: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  return 'Description can\'t be empty';
                                }
                              },
                              onSaved: (value) => _decription = value,
                            ),
                          ),
                          SizedBox(height: height < 600 ? 0 : 20.0),
                          Padding(
                            padding: EdgeInsets.only(left: 25.0, right: 25.0),
                            child: SimpleAutocompleteFormField<User>(
                              focusNode: _beautyProFocus,
                              decoration: InputDecoration(
                                labelText: 'Beauty Pro',
                                hintText: 'Select Beauty Pro',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                              ),
                              suggestionsHeight: 100.0,
                              itemBuilder: (context, person) => Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${person.username}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${person.displayName}')
                                    ]),
                              ),
                              onSearch: (search) async => listUser
                                  .where((person) => person.username
                                      .toLowerCase()
                                      .contains(search.toLowerCase()))
                                  .toList(),
                              itemFromString: (string) => listUser.singleWhere(
                                  (person) =>
                                      person.username.toLowerCase() ==
                                      string.toLowerCase(),
                                  orElse: () => null),
                              onChanged: (value) =>
                                  setState(() => _beautyPro = value),
                              onSaved: (value) =>
                                  setState(() => _beautyPro = value),
                              validator: (person) =>
                                  person == null ? 'Invalid Beauty Pro.' : null,
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
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
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
      if (file != null) {
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
          var sReference =
              _db.collection('styles').document((count).toString());

          sReference.setData({
            "styleName": _style,
            "bookings": 0,
            "styleId": count,
            'imageUrl': downloadUrl,
            "timestamp": FieldValue.serverTimestamp(),
          }, merge: true);
        }

        fsReference.add({
          "ownerIddisplayName": user.data["displayName"],
          "style": _style,
          "price": _price,
          "duration": _duration,
          "beautyProUserName": _beautyPro.username,
          "beautyProDisplayName": _beautyPro.displayName,
          "beautyProId": _beautyPro.uid,
          "likes": {},
          "mediaUrl": downloadUrl,
          "description": _decription,
          "savedBy": {},
          "ownerId": user.data["uid"],
          "timestamp": FieldValue.serverTimestamp(),
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
      } else {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Select File')));
      }
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
