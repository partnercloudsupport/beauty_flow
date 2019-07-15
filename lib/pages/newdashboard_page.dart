import 'package:beauty_flow/Model/Style.dart';
import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/datasearch_page.dart';
import 'package:beauty_flow/pages/topstype_page.dart';
import 'package:beauty_flow/pages/userdetailshero_page.dart';
import 'package:beauty_flow/util/searchservice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    this._loadSearchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Beauty Flow")),
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
                        ? Center(child: CircularProgressIndicator())
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
                height: 150.0,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection("users")
                      .orderBy("followersCount", descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? Center(child: CircularProgressIndicator())
                        : _buildTopPros(context, snapshot.data.documents);
                  },
                ),
              ),
            ],
          ),
        ],
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
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeInCurve: Curves.easeIn,
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(),
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

class TopPros extends StatelessWidget {
  TopPros({
    Key key,
    this.pros,
  }) : super(key: key);

  final User pros;

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
                      return UserDetailsHeroPage(pros);
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
                        tag: pros.uid,
                        child: CachedNetworkImage(
                          imageUrl:
                              (pros.photoURL == "" || pros.photoURL == null)
                                  ? "assets/img/person.png"
                                  : pros.photoURL,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration(milliseconds: 500),
                          fadeInCurve: Curves.easeIn,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0, left: 90.0),
                    child: ClipOval(
                      child: Center(
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(color: Colors.lightBlue),
                          child: Padding(
                            padding: EdgeInsets.only(top: 4,left: 3),
                            child: Text(
                              "Pro",
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Text(
              '${pros.username}',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
