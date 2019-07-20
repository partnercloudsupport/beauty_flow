import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/pages/forgotpass_page.dart';
import 'package:beauty_flow/pages/signup_pagenew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPageNew extends StatefulWidget {
  LoginPageNew({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  _LoginPageNewState createState() => _LoginPageNewState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

enum FormMode { LOGIN, SIGNUP }

class _LoginPageNewState extends State<LoginPageNew> {
  final _formKey = new GlobalKey<FormState>();
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  String _email;
  String _password;
  String _errorMessage;

  // Focus Fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Initial form is login form
  bool _isIos;
  bool _isLoading;

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
        userId = await widget.auth.signIn(_email, _password);
        print('Signed in: $userId');

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

  void _goToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(
      () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SignUpPageNew(
              auth: widget.auth,
              onSignedIn: _onLoggedIn,
            ),
          ),
        );
      },
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          _showBody(context),
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showBody(context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        15.0, height < 600 ? height * 0.04 : 130.0, 0.0, 0.0),
                    child: Text('Hello',
                        style: TextStyle(
                            fontSize: 80.0, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        17.0, height < 600 ? height * 0.16 : 210.0, 0.0, 0.0),
                    child: Text('There',
                        style: TextStyle(
                            fontSize: 80.0, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        250.0, height < 600 ? height * 0.16 : 210.0, 0.0, 0.0),
                    child: Text('.',
                        style: TextStyle(
                            fontSize: 80.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: height < 600 ? 0 : 60.0, left: 20.0, right: 20.0),
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
                  SizedBox(height: height < 600 ? 0 : 20.0),
                  TextFormField(
                    maxLines: 1,
                    obscureText: true,
                    autofocus: false,
                    focusNode: _passwordFocus,
                    decoration: InputDecoration(
                      labelText: 'PASSWORD',
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
                        return 'Password can\'t be empty';
                      }
                    },
                    onSaved: (value) => _password = value,
                  ),
                  SizedBox(height: height < 600 ? 0 : 5.0),
                  Container(
                    alignment: Alignment(1.0, 0.0),
                    padding: EdgeInsets.only(
                        top: height < 600 ? 5 : 15.0, left: 20.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ForgotPassPage(
                              auth: widget.auth,
                              onSignedIn: _onLoggedIn,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  SizedBox(height: height < 600 ? 15 : 40.0),
                  Container(
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
                            'LOGIN',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 20.0),
                  // Container(
                  //   height: 40.0,
                  //   color: Colors.transparent,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //         border: Border.all(
                  //             color: Colors.black,
                  //             style: BorderStyle.solid,
                  //             width: 1.0),
                  //         color: Colors.transparent,
                  //         borderRadius: BorderRadius.circular(20.0)),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: <Widget>[
                  //         Center(
                  //           child: ImageIcon(
                  //               AssetImage('assets/facebook.png')),
                  //         ),
                  //         SizedBox(width: 10.0),
                  //         Center(
                  //           child: Text('Log in with facebook',
                  //               style: TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                   fontFamily: 'Montserrat')),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'New to Beauty Flow?',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                SizedBox(width: 5.0),
                InkWell(
                  onTap: _goToSignUp,
                  child: Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Center(child: _showErrorMessage()),
            )
          ],
        ),
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
