import 'package:beauty_flow/authentication/authentication.dart';
import 'package:flutter/material.dart';

class SignUpPageNew extends StatefulWidget {
  SignUpPageNew({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  _SignUpPageNewState createState() => _SignUpPageNewState();
}

enum FormMode { LOGIN, SIGNUP }
enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _SignUpPageNewState extends State<SignUpPageNew> {
  final _formKey = new GlobalKey<FormState>();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  String _email;
  String _password;
  String _errorMessage;
  String _fullName;

  // Initial form is login form
  bool _isIos;
  bool _isLoading;
  bool _isSwitched = false;

  // Focus Fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        userId =
            await widget.auth.signUp(_email, _password, _isSwitched, _fullName);
        // widget.auth.sendEmailVerification();
        print('Signed up user: $userId');
        // Navigator.pop(context);
        final snackBar = SnackBar(
          content: Text(
            'Welcome to Beauty Flow Family $_fullName!',
            textAlign: TextAlign.center,
          ),
        );

        // Find the Scaffold in the widget tree and use it to show a SnackBar.
        Scaffold.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });

        if (userId != null && userId.length > 0) {
          widget.onSignedIn();
        }
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
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
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
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          new Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(
                    15.0, height < 600 ? height * 0.04 : 110.0, 0.0, 0.0),
                child: Text(
                  'Signup',
                  style: TextStyle(
                      fontSize: height < 600 ? 70.0 : 80.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    280.0, height < 600 ? height * 0.05 : 130.0, 0.0, 0.0),
                child: Text(
                  '.',
                  style: TextStyle(
                      fontSize: 80.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(
                top: height < 600 ? 0 : 35.0, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: false,
                  focusNode: _emailFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _emailFocus, _passwordFocus);
                  },
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
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _isLoading = false;
                      });
                      return 'Email can\'t be empty';
                    }
                  },
                  onSaved: (value) => _email = value,
                ),
                SizedBox(height: height < 600 ? 0 : 10.0),
                TextFormField(
                  maxLines: 1,
                  autofocus: false,
                  focusNode: _passwordFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _passwordFocus, _nameFocus);
                  },
                  decoration: InputDecoration(
                      labelText: 'PASSWORD ',
                      labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green))),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _isLoading = false;
                      });
                      return 'Password can\'t be empty';
                    }
                  },
                  onSaved: (value) => _password = value,
                ),
                SizedBox(height: height < 600 ? 0 : 10.0),
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  focusNode: _nameFocus,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'FULL NAME ',
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
                      return 'Full Name can\'t be empty';
                    }
                  },
                  onSaved: (value) => _fullName = value,
                ),
                SizedBox(height: height < 600 ? 0 : 10.0),
                Row(
                  children: <Widget>[
                    new Text("Sign Up As Pro"),
                    new Switch(
                      value: _isSwitched,
                      onChanged: (value) {
                        setState(() {
                          _isSwitched = value;
                        });
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: height < 600 ? 10 : 50.0),
                Container(
                  height: height < 600 ? 30 : 40.0,
                  child: GestureDetector(
                    onTap: _validateAndSubmit,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.greenAccent,
                      color: Colors.green,
                      elevation: 7.0,
                      child: Center(
                        child: Text(
                          'SIGNUP',
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
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
