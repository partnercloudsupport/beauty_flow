import 'dart:async';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final auth = Auth();

class InstaList extends StatefulWidget {
  const InstaList(
      {this.mediaUrl,
      this.displayName,
      this.price,
      this.description,
      this.likes,
      this.postId,
      this.ownerId});

  factory InstaList.fromDocument(DocumentSnapshot document) {
    return InstaList(
      displayName: document['displayName'],
      price: document['price'].toDouble(),
      mediaUrl: document['mediaUrl'],
      likes: document['likes'],
      description: document['description'],
      postId: document.documentID,
      ownerId: document['ownerId'],
    );
  }

  factory InstaList.fromJSON(Map data) {
    return InstaList(
      displayName: data['displayName'],
      price: data['price'].toDouble(),
      mediaUrl: data['mediaUrl'],
      likes: data['likes'],
      description: data['description'],
      ownerId: data['ownerId'],
      postId: data['postId'],
    );
  }

  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }

  final String mediaUrl;
  final String displayName;
  final double price;
  final String description;
  final likes;
  final String postId;
  final String ownerId;

  _InstaListState createState() => _InstaListState(
        mediaUrl: this.mediaUrl,
        displayName: this.displayName,
        price: this.price,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
      );
}

class _InstaListState extends State<InstaList> {
  final String mediaUrl;
  final String displayName;
  final double price;
  final String description;
  Map likes;
  int likeCount;
  final String postId;
  bool liked;
  final String ownerId;

  bool showHeart = false;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = Firestore.instance.collection('beautyPosts');

  _InstaListState(
      {this.mediaUrl,
      this.displayName,
      this.price,
      this.description,
      this.likes,
      this.postId,
      this.likeCount,
      this.ownerId});

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return Text("owner error");
    }

    return FutureBuilder(
      future: Firestore.instance
          .collection('users')
          .document(ownerId)
          .get(),
      builder: (context, snapshot) {
        String imageUrl = "";
        String username = "";

        if (snapshot.hasData) {
          imageUrl = snapshot.data.data['photoURL'];
          username = snapshot.data.data['displayName'];
        }
        if (!snapshot.hasData) {
          return Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator());
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                child: Row(
                  children: <Widget>[
                    new Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: (imageUrl == "" || imageUrl == null) ? AssetImage("assets/img/person.png") : NetworkImage(imageUrl),
                        ),
                      ),
                    ),
                    new SizedBox(
                      width: 10.0,
                    ),
                    new Text(
                      username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text("Options Comming Soon",textAlign: TextAlign.center,),
                        ));
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      onDoubleTap: () {
        _likePost(postId);
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image(
            fit: BoxFit.fill,
            image: (mediaUrl == "" || mediaUrl == null) ? AssetImage("assets/img/person.png") : NetworkImage(mediaUrl),
            height: 400.0,
          ),
          showHeart
              ? Positioned(
                  child: Opacity(
                      opacity: 0.85,
                      child: Icon(
                        FontAwesomeIcons.solidHeart,
                        size: 80.0,
                        color: Colors.red,
                      )),
                )
              : Container()
        ],
      ),
    );
  }

  IconButton buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
      icon = FontAwesomeIcons.solidHeart;
    } else {
      icon = FontAwesomeIcons.heart;
    }

    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: () {
        _likePost(postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    liked = (likes[currentUserModel.id.toString()] == true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildPostHeader(ownerId: ownerId),
        buildLikeableImage(),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  buildLikeIcon(),
                  new IconButton(
                    icon: Icon(FontAwesomeIcons.comment),
                    onPressed: () {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text("Comment Comming Soon",textAlign: TextAlign.center,),
                      ));
                    },
                  ),
                  new IconButton(
                    icon: Icon(FontAwesomeIcons.paperPlane),
                    onPressed: () {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text("Share Comming Soon",textAlign: TextAlign.center,),
                      ));
                    },
                  ),
                ],
              ),
              new IconButton(
                icon: Icon(FontAwesomeIcons.bookmark),
                onPressed: () {
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("BookMark Comming Soon",textAlign: TextAlign.center,),
                  ));
                },
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Liked by $likeCount People",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Description : $description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Price : $price",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 50.0)
      ],
    );
  }

  void _likePost(String postId2) {
    var userId = currentUserModel.id;
    bool _liked = likes[userId] == true;

    if (_liked) {
      reference.document(postId).updateData({
        'likes.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      setState(() {
        likeCount = likeCount - 1;
        liked = false;
        likes[userId] = false;
      });

      removeActivityFeedItem();
    }

    if (!_liked) {
      reference.document(postId).updateData({'likes.$userId': true});

      addActivityFeedItem();

      setState(() {
        likeCount = likeCount + 1;
        liked = true;
        likes[userId] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  void addActivityFeedItem() {
    Firestore.instance
        .collection("deautyFeed")
        .document(ownerId)
        .collection("items")
        .document(postId)
        .setData({
      "displayName": currentUserModel.displayName,
      "userId": currentUserModel.id,
      "type": "like",
      "userProfileImg": currentUserModel.photoURL,
      "mediaUrl": mediaUrl,
      "timestamp": DateTime.now(),
      "postId": postId,
    });
  }

  void removeActivityFeedItem() {
    Firestore.instance
        .collection("deautyFeed")
        .document(ownerId)
        .collection("items")
        .document(postId)
        .delete();
  }
}
