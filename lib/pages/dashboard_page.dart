import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/datasearch_page.dart';
import 'package:beauty_flow/pages/insta_list.dart';
import 'package:beauty_flow/util/searchservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashBoardPage extends StatefulWidget {
  DashBoardPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => new _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage>
    with AutomaticKeepAliveClientMixin<DashBoardPage> {
  List<InstaList> feedData;
  final ref = Firestore.instance.collection('users');
  final queryResultSet = [];

  @override
  void initState() {
    super.initState();
    this._loadFeed();
  }

  buildFeed() {
    if (feedData != null) {
      if (feedData.length > 0) {
        return ListView(
          children: feedData,
        );
      } else {
        return Container(
          alignment: FractionalOffset.center,
          child: Center(child: Text("Pull To Refresh")),
        );
      }
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: buildFeed(),
      ),
    );
  }

  Future<Null> _refresh() async {
    await _getFeed();

    setState(() {});

    return;
  }

  _loadFeed() async {
    setState(() {
      SearchService().searchByName().then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    });

    if (currentUserModel == null) {
      DocumentSnapshot userRecord =
          await ref.document(widget.userId.toString()).get();
      currentUserModel = User.fromDocument(userRecord);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("feed");

    if (json != null) {
      List<Map<String, dynamic>> data =
          jsonDecode(json).cast<Map<String, dynamic>>();
      List<InstaList> listOfPosts = _generateFeed(data);
      setState(() {
        feedData = listOfPosts;
      });
    } else {
      _getFeed();
    }
  }

  _getFeed() async {
    print("Staring getFeed");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url =
        'https://us-central1-beauty-flow.cloudfunctions.net/getFeed?uid=' +
            widget.userId.toString();
    var httpClient = HttpClient();

    List<InstaList> listOfPosts;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        prefs.setString("feed", json);
        List<Map<String, dynamic>> data =
            jsonDecode(json).cast<Map<String, dynamic>>();
        listOfPosts = _generateFeed(data);
        result = "Success in http request for feed";
      } else {
        result =
            'Error getting a feed: Http status ${response.statusCode} | userId ${widget.userId.toString()}';
      }
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    print(result);

    setState(() {
      feedData = listOfPosts;
    });
  }

  List<InstaList> _generateFeed(List<Map<String, dynamic>> feedData) {
    List<InstaList> listOfPosts = [];

    for (var postData in feedData) {
      listOfPosts.add(InstaList.fromJSON(postData));
    }

    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}
