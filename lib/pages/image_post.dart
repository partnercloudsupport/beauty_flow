import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImagePost extends StatefulWidget {
  const ImagePost(
      {this.mediaUrl,
      this.displayName,
      this.price,
      this.description,
      this.likes,
      this.postId,
      this.ownerId,
      this.userId});

  factory ImagePost.fromDocument(DocumentSnapshot document) {
    return ImagePost(
      displayName: document['displayName'],
      price: document['price'],
      mediaUrl: document['mediaUrl'],
      likes: document['likes'],
      description: document['description'],
      postId: document.documentID,
      ownerId: document['ownerId'],
    );
  }

  factory ImagePost.fromJSON(Map data) {
    return ImagePost(
      displayName: data['displayName'],
      price: data['price'],
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
  final String userId;

  _ImagePost createState() => _ImagePost(
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

class _ImagePost extends State<ImagePost> {
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

  _ImagePost(
      {this.mediaUrl,
      this.displayName,
      this.price,
      this.description,
      this.likes,
      this.postId,
      this.likeCount,
      this.ownerId});

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
      icon = FontAwesomeIcons.solidHeart;
    } else {
      icon = FontAwesomeIcons.heart;
    }

    return GestureDetector(
        child: Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        onTap: () {
          _likePost(postId);
        });
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      onDoubleTap: () => _likePost(postId),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
//          FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: mediaUrl),
          new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image(
                fit: BoxFit.fitWidth,
                image: NetworkImage(mediaUrl),
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
          showHeart
              ? Positioned(
                  child: Opacity(
                      opacity: 0.85,
                      child: Icon(
                        FontAwesomeIcons.solidHeart,
                        size: 80.0,
                        color: Colors.white,
                      )),
                )
              : Container()
        ],
      ),
    );
  }

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return Text("owner error");
    }

    return FutureBuilder(
        future: Firestore.instance.collection('users').document(ownerId).get(),
        builder: (context, snapshot) {
          String imageUrl = " ";
          String username = " ";

          if (snapshot.data != null) {
            imageUrl = snapshot.data.data['photoURL'];
            username = snapshot.data.data['displayName'];
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              child: Text(username, style: boldStyle),
              onTap: () {},
            ),
            subtitle: Text(this.price.toString()),
            trailing: const Icon(Icons.more_vert),
          );
        });
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    liked = (likes[widget.userId.toString()] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(ownerId: ownerId),
        buildLikeableImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
            buildLikeIcon(),
            Padding(padding: const EdgeInsets.only(right: 20.0)),
            GestureDetector(
                child: const Icon(
                  FontAwesomeIcons.comment,
                  size: 25.0,
                ),
                onTap: () {}),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: boldStyle,
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "$displayName ",
                  style: boldStyle,
                )),
            Expanded(child: Text(description)),
          ],
        ),
        SizedBox(height: 50.0)
      ],
    );
  }

  void _likePost(String postId2) {
    var userId = widget.ownerId;
    bool _liked = likes[userId] == true;

    if (_liked) {
      print('removing like');
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
      print('liking');
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
      "username": widget.displayName,
      "userId": widget.userId,
      "type": "like",
      "userProfileImg": widget.mediaUrl,
      "mediaUrl": mediaUrl,
      "timestamp": DateTime.now().toString(),
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

class ImagePostFromId extends StatelessWidget {
  final String id;

  const ImagePostFromId({this.id});

  getImagePost() async {
    var document =
        await Firestore.instance.collection('beautyPosts').document(id).get();
    return ImagePost.fromDocument(document);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getImagePost(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator());
          return snapshot.data;
        });
  }
}
