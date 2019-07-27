import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:beauty_flow/Model/Style.dart';
import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/datasearch_page.dart';
import 'package:beauty_flow/pages/newpost_page.dart';
import 'package:beauty_flow/pages/topstype_page.dart';
import 'package:beauty_flow/pages/userdetailshero_page.dart';
import 'package:beauty_flow/util/searchservice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NewDashBoardPage extends StatefulWidget {
  NewDashBoardPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final VoidCallback onSignedOut;
  @override
  _NewDashBoardPageState createState() => _NewDashBoardPageState();
}

class _NewDashBoardPageState extends State<NewDashBoardPage> {
  final queryResultSet = [];
  final ref = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  @override
  void initState() {
    _saveDeviceToken() async {
      // Get the current user
      String uid = widget.userId;
      // FirebaseUser user = await _auth.currentUser();

      // Get the token for this device
      String fcmToken = await _fcm.getToken();
      print(fcmToken);
      // Save it to Firestore
      if (fcmToken != null) {
        print(fcmToken);
        var tokens = ref
            .collection('users')
            .document(uid)
            .collection('tokens')
            .document(fcmToken);

        await tokens.setData({
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(), // optional
          'platform': Platform.operatingSystem // optional
        });
      }
    }

    this._loadSearchList();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
    super.initState();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // final snackbar = SnackBar(
        //   content: Text(message['notification']['title']),
        //   action: SnackBarAction(
        //     label: 'Go',
        //     onPressed: () => null,
        //   ),
        // );

        // Scaffold.of(context).showSnackBar(snackbar);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Beauty Flow"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearch(
                      auth: widget.auth, queryResultSet: queryResultSet));
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
                child: Text(
                  "Top Styles",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 150.0,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection("styles")
                      .orderBy("bookings", descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? Center(
                            child: SpinKitChasingDots(
                              color: Colors.blueAccent,
                              size: 60.0,
                            ),
                          )
                        : _buildTopStyles(context, snapshot.data.documents);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
                child: Text(
                  "Top Pros",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 170.0,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection("users")
                      .where('isPro', isEqualTo: true)
                      .orderBy("followersCount", descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? Center(
                            child: SpinKitChasingDots(
                              color: Colors.blueAccent,
                              size: 60.0,
                            ),
                          )
                        : _buildTopPros(context, snapshot.data.documents);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NewPostPage(userId: widget.userId, auth: widget.auth),
            ),
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  _loadSearchList() async {
    setState(() {
      SearchService().searchByName().then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    });

    if (currentUserModel == null) {
      DocumentSnapshot userRecord = await ref
          .collection('users')
          .document(widget.userId.toString())
          .get();
      currentUserModel = User.fromDocument(userRecord);
      setState(() {
        currentUserModel = User.fromDocument(userRecord);
      });
    }
  }

  Widget _buildTopStyles(
      BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView.builder(
      itemCount: snapshots.length,
      scrollDirection: Axis.horizontal,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return TopStyles(style: Style.fromSnapshot(snapshots[index]));
      },
    );
  }

  Widget _buildTopPros(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView.builder(
      itemCount: snapshots.length,
      scrollDirection: Axis.horizontal,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return TopPros(pros: User.fromSnapshot(snapshots[index]));
      },
    );
  }
}

class TopStyles extends StatelessWidget {
  TopStyles({
    Key key,
    this.style,
  }) : super(key: key);

  final Style style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                print(style.styleName);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TopStylePage(style);
                    },
                  ),
                );
              },
              child: ClipOval(
                child: Container(
                  width: 110.0,
                  height: 100.0,
                  child: CachedNetworkImage(
                    imageUrl: (style.imageUrl == "" || style.imageUrl == null)
                        ? "assets/img/person.png"
                        : style.imageUrl,
                    fit: BoxFit.cover,
                    // fadeInDuration: Duration(milliseconds: 500),
                    // fadeInCurve: Curves.easeIn,
                    placeholder: (context, url) => SpinKitFadingCircle(
                      color: Colors.blueAccent,
                      size: 30.0,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Text(
              style.styleName,
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class TopPros extends StatefulWidget {
  TopPros({
    Key key,
    this.pros,
  }) : super(key: key);

  final User pros;

  @override
  _TopProsState createState() => _TopProsState();
}

class _TopProsState extends State<TopPros> {
  String distance;

  @override
  void initState() {
    super.initState();
    calDistance(widget.pros);
  }

  calDistance(User pros) async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    }
    double distanceInMeters = await Geolocator().distanceBetween(
        position.latitude, position.longitude, pros.latitude, pros.longitude);
    if (distanceInMeters > 1000) {
      distance = (distanceInMeters.round() / 1000).round().toString() + ' Km';
    } else {
      distance = distanceInMeters.round().toString() + ' m';
    }
    print(distance);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return UserDetailsHeroPage(widget.pros.uid);
                    },
                  ),
                );
              },
              child: Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      width: 110.0,
                      height: 100.0,
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: widget.pros.uid,
                        child: CachedNetworkImage(
                          imageUrl: (widget.pros.photoURL == "" ||
                                  widget.pros.photoURL == null)
                              ? "assets/img/person.png"
                              : widget.pros.photoURL,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SpinKitFadingCircle(
                            color: Colors.blueAccent,
                            size: 30.0,
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${widget.pros.username}',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
            ),
            Text(
              distance == null ? '' : distance,
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
