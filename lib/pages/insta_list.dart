import 'dart:async';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/comment_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

final auth = Auth();

class InstaList extends StatefulWidget {
  const InstaList(
      {this.mediaUrl,
      this.ownerIddisplayName,
      this.price,
      this.description,
      this.beautyProId,
      this.beautyProDisplayName,
      this.beautyProUserName,
      this.duration,
      this.likes,
      this.savedBy,
      this.postId,
      this.style,
      this.ownerId});

  factory InstaList.fromDocument(DocumentSnapshot document) {
    return InstaList(
      ownerIddisplayName: document['ownerIddisplayName'],
      price: document['price'].toDouble(),
      mediaUrl: document['mediaUrl'],
      style: document['style'],
      likes: document['likes'],
      savedBy: document['savedBy'],
      description: document['description'],
      beautyProId: document['beautyProId'],
      beautyProDisplayName: document['beautyProDisplayName'],
      beautyProUserName: document['beautyProUserName'],
      duration: document['duration'].toDouble(),
      postId: document.documentID,
      ownerId: document['ownerId'],
    );
  }

  factory InstaList.fromJSON(Map data) {
    return InstaList(
      ownerIddisplayName: data['ownerIddisplayName'],
      price: data['price'].toDouble(),
      mediaUrl: data['mediaUrl'],
      style: data['style'],
      likes: data['likes'],
      savedBy: data['savedBy'],
      description: data['description'],
      beautyProId: data['beautyProId'],
      beautyProDisplayName: data['beautyProDisplayName'],
      beautyProUserName: data['beautyProUserName'],
      duration: data['duration'].toDouble(),
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
  final String ownerIddisplayName;
  final String style;
  final double price;
  final double duration;
  final String description;
  final String beautyProId;
  final String beautyProDisplayName;
  final String beautyProUserName;
  final likes,savedBy;
  final String postId;
  final String ownerId;

  _InstaListState createState() => _InstaListState(
        mediaUrl: this.mediaUrl,
        ownerIddisplayName: this.ownerIddisplayName,
        style: this.style,
        price: this.price,
        duration: this.duration,
        description: this.description,
        beautyProId: this.beautyProId,
        beautyProDisplayName: this.beautyProDisplayName,
        beautyProUserName: this.beautyProUserName,
        likes: this.likes,
        savedBy: this.savedBy,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
      );
}

class _InstaListState extends State<InstaList> {
  final String mediaUrl;
  final String ownerIddisplayName;
  final String style;
  final double price;
  final double duration;
  final String description;
  final String beautyProId;
  final String beautyProDisplayName;
  final String beautyProUserName;
  Map likes,savedBy;
  int likeCount;
  final String postId;
  bool liked,saved;
  final String ownerId;

  bool showHeart = false;
  bool _isLoading;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = Firestore.instance.collection('beautyPosts');
  var savedPostRef = Firestore.instance.collection('users');

  _InstaListState(
      {this.mediaUrl,
      this.ownerIddisplayName,
      this.style,
      this.price,
      this.duration,
      this.description,
      this.beautyProId,
      this.beautyProUserName,
      this.beautyProDisplayName,
      this.likes,
      this.savedBy,
      this.postId,
      this.likeCount,
      this.ownerId});

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return Text("owner error");
    }

    return FutureBuilder(
      future: Firestore.instance.collection('users').document(ownerId).get(),
      builder: (context, snapshot) {
        String imageUrl = "";
        String username = "";

        if (snapshot.hasData) {
          imageUrl = snapshot.data.data['photoURL'];
          username = snapshot.data.data['displayName'];
        }
        return !snapshot.hasData
            ? Center(
                child: SpinKitChasingDots(
                  color: Colors.blueAccent,
                  size: 60.0,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                    child: Row(
                      children: <Widget>[
                        ClipOval(
                          child: new Container(
                            height: 40.0,
                            width: 40.0,
                            child: CachedNetworkImage(
                              imageUrl: (imageUrl == "" || imageUrl == null)
                                  ? "assets/img/person.png"
                                  : imageUrl,
                              fit: BoxFit.fill,
                              // fadeInDuration: Duration(milliseconds: 500),
                              // fadeInCurve: Curves.easeIn,
                              placeholder: (context, url) =>
                                  SpinKitFadingCircle(
                                color: Colors.blueAccent,
                                size: 30.0,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                        new SizedBox(
                          width: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Styled By : $beautyProUserName',
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ],
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
                          tooltip: "More Options",
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ],
              );
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
          CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: mediaUrl == null ? "assets/img/person.png" : mediaUrl,
            height: 400.0,
            fadeInDuration: Duration(milliseconds: 500),
            fadeInCurve: Curves.easeIn,
            placeholder: (context, url) => SpinKitFadingCircle(
              color: Colors.blueAccent,
              size: 30.0,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          showHeart
              ? Positioned(
                  child: Opacity(
                    opacity: 0.85,
                    child: Icon(
                      FontAwesomeIcons.solidHeart,
                      size: 80.0,
                      color: Colors.red,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  @override
  void initState() {
    _isLoading = false;
    super.initState();
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

  IconButton buildSavedIcon() {
    Color color;
    IconData icon;

    if (saved) {
      color = Colors.black;
      icon = FontAwesomeIcons.solidBookmark;
    } else {
      icon = FontAwesomeIcons.bookmark;
    }

    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: () {
        _savePost(postId);
      },
    );
  }

  IconButton buildbookingIcon() {
    bool isDisabled;
    if (beautyProId == currentUserModel.uid) {
      isDisabled = true;
    } else {
      isDisabled = false;
    }
    return IconButton(
      icon: Icon(FontAwesomeIcons.calendar),
      tooltip: "Book",
      onPressed: isDisabled
          ? null
          : () {
              _booking(postId);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    liked = (likes[currentUserModel.uid.toString()] == true);
    saved = (savedBy[currentUserModel.uid.toString()] == true);

    return Stack(
      children: <Widget>[
        Container(
          child: Column(
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
                          tooltip: "Comments",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentPage(postId),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.paperPlane),
                          tooltip: "Share",
                          onPressed: () {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "Share Comming Soon",
                                textAlign: TextAlign.center,
                              ),
                            ));
                          },
                        ),
                        buildbookingIcon(),
                      ],
                    ),
                    buildSavedIcon(),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Style : $style",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                    ),
                    Text(
                      "Description : $description",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                    ),
                    Text(
                      "Price : $price",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                    ),
                    Text(
                      "Time Duration : $duration Min.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.0)
            ],
          ),
        ),
      ],
    );
  }

  void _likePost(String postId2) {
    var userId = currentUserModel.uid;
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

    void _savePost(String postId) {
    var userId = currentUserModel.uid;
    bool _saved = savedBy[userId] == true;

    if (_saved) {
      reference.document(postId).updateData({
        'savedBy.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      savedPostRef.document(currentUserModel.uid).updateData({
        'savedPostIds.$postId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      setState(() {
        // likeCount = likeCount - 1;
        saved = false;
        savedBy[userId] = false;
      });

      // removeActivityFeedItem();
    }

    if (!_saved) {
      reference
          .document(postId)
          .updateData({'savedBy.$userId': true});

      savedPostRef
          .document(currentUserModel.uid)
          .updateData({'savedPostIds.$postId': true});

      //addActivityFeedItem();

      setState(() {
        // likeCount = likeCount + 1;
        saved = true;
        savedBy[userId] = true;
      });
    }
  }

  void _booking(String postId) async {
    setState(() {
      _isLoading = true;
    });
    var fsReference = Firestore.instance.collection("bookings");

    QuerySnapshot bookingRef = await Firestore.instance
        .collection("styles")
        .where("styleName", isEqualTo: style)
        .getDocuments();
    if (bookingRef.documents.isNotEmpty) {
      var list = bookingRef.documents.toList();
      print(list);
      var sReference =
          Firestore.instance.collection('styles').document(list[0].documentID);
      sReference.updateData({
        "bookings": (list[0]["bookings"] + 1),
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    fsReference.add({
      "postId": postId,
      "price": price,
      "mediaUrl": mediaUrl,
      "beautyProId": beautyProId,
      "beautyProDisplayName": beautyProDisplayName,
      "beautyProUserName": beautyProUserName,
      "style": style,
      "bookedBy": currentUserModel.uid,
      "bookedByUserName": currentUserModel.username,
      "bookedByDisplayName": currentUserModel.displayName,
      "isConfirmed": 0,
      "timestamp": FieldValue.serverTimestamp(),
    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      fsReference.document(docId).updateData({"bookingId": docId});
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "Booked",
          textAlign: TextAlign.center,
        ),
      ));
    });
    setState(() {
      _isLoading = false;
    });
  }

  void addActivityFeedItem() {
    Firestore.instance
        .collection("deautyFeed")
        .document(ownerId)
        .collection("items")
        .document(postId)
        .setData({
      "displayName": currentUserModel.displayName,
      "userId": currentUserModel.uid,
      "type": "like",
      "userProfileImg": currentUserModel.photoURL,
      "mediaUrl": mediaUrl,
      "timestamp": FieldValue.serverTimestamp(),
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
