import 'package:beauty_flow/Model/Style.dart';
import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/Model/post.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/datasearch_page.dart';
import 'package:beauty_flow/pages/newpost_page.dart';
import 'package:beauty_flow/pages/topstype_page.dart';
import 'package:beauty_flow/pages/userdetailshero_page.dart';
import 'package:beauty_flow/util/searchservice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

import '../postdetails_page.dart';
import 'dashboard_page_view_model.dart';

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
  final store = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  DashboardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DashboardViewModel(widget.userId);
    _loadSearchList();
    _subscribeOnMessages();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  _loadSearchList() async {
    // todo it is a big mistake do download all users from the server
    setState(() {
      SearchService().searchByName().then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    });

    if (currentUserModel == null) {
      DocumentSnapshot userRecord = await store
          .collection('users')
          .document(widget.userId.toString())
          .get();
      currentUserModel = User.fromDocument(userRecord);
      setState(() {
        currentUserModel = User.fromDocument(userRecord);
      });
    }
  }

  void _subscribeOnMessages() {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
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
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
                child: Text(
                  "Nearest Posts",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 150.0,
                child: StreamBuilder(
                  stream: viewModel.postList,
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? _buildEmptyTopStyles()
                        : _buildPosts(context, snapshot.data);
                  },
                ),
              ),
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
                  stream: viewModel.styleList,
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? _buildEmptyTopStyles()
                        : _buildTopStyles(context, snapshot.data);
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
                  stream: viewModel.proUserList,
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? _buildEmptyTopStyles()
                        : _buildTopPros(context, snapshot.data);
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

  Center _buildEmptyTopStyles() {
    return Center(
      child: SpinKitChasingDots(
        color: Colors.blueAccent,
        size: 60.0,
      ),
    );
  }

  Widget _buildPosts(BuildContext context, List<Post> styleList) {
    return ListView.builder(
      itemCount: styleList.length,
      scrollDirection: Axis.horizontal,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return PostItem(post: styleList[index]);
      },
    );
  }

  Widget _buildTopStyles(BuildContext context, List<Style> styleList) {
    return ListView.builder(
      itemCount: styleList.length,
      scrollDirection: Axis.horizontal,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return TopStyles(style: styleList[index]);
      },
    );
  }

  Widget _buildTopPros(BuildContext context, List<User> userList) {
    return ListView.builder(
      itemCount: userList.length,
      scrollDirection: Axis.horizontal,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return TopPros(pros: userList[index]);
      },
    );
  }
}

class PostItem extends StatelessWidget {
  PostItem({
    Key key,
    this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PostDetailsPage(post);
                    },
                  ),
                );
              },
              child: ClipOval(
                child: Container(
                  width: 110.0,
                  height: 100.0,
                  child: CachedNetworkImage(
                    imageUrl: (post.mediaUrl == "" || post.mediaUrl == null)
                        ? "assets/img/person.png"
                        : post.mediaUrl,
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
              post.style,
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
