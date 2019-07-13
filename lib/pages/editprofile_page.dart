import 'dart:io';
import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/util/random_string.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key, this.userId}) : super(key: key);

  final String userId;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = new GlobalKey<FormState>();
  final Firestore _db = Firestore.instance;

  // Initial Form States
  bool _isLoading;
  String _errorMessage;
  bool _isIos;
  File file;

  // Text Controllers
  final TextEditingController _emailController = new TextEditingController();
  String _email = currentUserModel.email;

  final TextEditingController _displaynameController =
      new TextEditingController();
  String _displayName = currentUserModel.displayName;

  final TextEditingController _userNameController = new TextEditingController();
  String _userName = currentUserModel.username;

  final TextEditingController _bioController = new TextEditingController();
  String _bio = currentUserModel.bio;

  String _profilePic = currentUserModel.photoURL;

  // Focus Fields
  final FocusNode _bioFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _userNameFocus = FocusNode();

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      try {
        String downloadUrl = currentUserModel.photoURL;
        if (file != null) {
          String fileId = randomString(5);
          StorageReference reference =
              FirebaseStorage.instance.ref().child("$fileId.jpg");
          StorageUploadTask uploadTask = reference.putFile(file);
          StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
          downloadUrl = await taskSnapshot.ref.getDownloadURL();
          setState(() {
           _profilePic =  downloadUrl;
          });
        }

        DocumentReference userRef =
            _db.collection('users').document(currentUserModel.id);

        userRef.updateData({
          'bio': _bio,
          'username': _userName,
          'displayName': _displayName,
          'photoURL': downloadUrl,
          'lastSeen': DateTime.now()
        });

        User currentUser = User(
            email: _email,
            id: currentUserModel.id,
            photoURL: downloadUrl,
            username: _userName,
            displayName: _displayName,
            bio: _bio,
            followers: currentUserModel.followers,
            following: currentUserModel.following,
            isPro: currentUserModel.isPro);
        currentUserModel = currentUser;

        setState(() {
          file = null;
          _isLoading = false;
          currentUserModel = currentUser;
        });
        _formKey.currentState?.reset();
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    _emailController.text = _email;
    _displaynameController.text = _displayName;
    _userNameController.text = _userName;
    _bioController.text = _bio;
    _errorMessage = "";
    _isLoading = false;
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("Beauty Flow"),
          ),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(context),
            _showCircularProgress(),
          ],
        ),
      ),
    );
  }

  Widget _showBody(context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: new Stack(
                      fit: StackFit.loose,
                      children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 140.0,
                              width: 140.0,
                              child: CachedNetworkImage(
                                imageUrl: (file == null)
                                    ? _profilePic
                                    : file,
                                fit: BoxFit.contain,
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeInCurve: Curves.easeIn,
                                placeholder: (context, url) =>
                                    new CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 85.0, left: 100.0),
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
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              top: height < 600 ? 0 : 20.0,
                              right: 20.0,
                              left: 10.0),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                maxLines: 1,
                                keyboardType: TextInputType.emailAddress,
                                autofocus: false,
                                controller: _emailController,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'EMAIL',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                              ),
                              SizedBox(height: height < 600 ? 0 : 20.0),
                              TextFormField(
                                maxLines: 2,
                                keyboardType: TextInputType.multiline,
                                autofocus: false,
                                controller: _bioController,
                                focusNode: _bioFocus,
                                onFieldSubmitted: (term) {
                                  _fieldFocusChange(
                                      context, _bioFocus, _fullNameFocus);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Bio',
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
                                    return 'Bio can\'t be empty';
                                  }
                                },
                                onSaved: (value) => _bio = value,
                              ),
                              SizedBox(height: height < 600 ? 0 : 20.0),
                              TextFormField(
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                autocorrect: false,
                                controller: _displaynameController,
                                focusNode: _fullNameFocus,
                                onFieldSubmitted: (term) {
                                  _fieldFocusChange(
                                      context, _fullNameFocus, _userNameFocus);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
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
                                    return 'Full Name can\'t be empty';
                                  }
                                },
                                onSaved: (value) => _displayName = value,
                              ),
                              SizedBox(height: height < 600 ? 0 : 20.0),
                              TextFormField(
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                autocorrect: false,
                                controller: _userNameController,
                                focusNode: _userNameFocus,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return 'UserName can\'t be empty';
                                  }
                                },
                                onSaved: (value) => _userName = value,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height < 600 ? 15 : 40.0),
                        Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          height: 40.0,
                          child: InkWell(
                            onTap: _validateAndSubmit,
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor: Colors.greenAccent,
                              color: Colors.green,
                              elevation: 7.0,
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height < 600 ? 15 : 20.0),
                        Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          height: height < 600 ? 30 : 40.0,
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                    width: 1.0),
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20.0)),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Text('Go Back',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat')),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                          child: Center(child: _showErrorMessage()),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog<Null>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Profile Image'),
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

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 14.0,
            color: Colors.red,
            fontFamily: 'Montserrat',
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}
