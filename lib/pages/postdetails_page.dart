import 'dart:async';

import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/comment_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'booking/booking_time_page.dart';

class PostDetailsPage extends StatefulWidget {
  PostDetailsPage(this.post);

  final Posts post;

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  bool showHeart = false;
  int likeCount;
  bool liked;
  bool saved;

  // Changeable in demo
  DateTime date = DateTime.now();
  String dateTimeString = "Pick Date";

  var reference = Firestore.instance.collection('beautyPosts');
  var savedPostRef = Firestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    liked = (widget.post.likes[currentUserModel.uid.toString()] == true);
    saved = (widget.post.savedBy[currentUserModel.uid.toString()] == true);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Beauty Flow"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BookingTimePage(widget.post.postId);
                },
              ),
            );
          },
          backgroundColor: Colors.green,
          label: Text("Book")),
      body: Container(
        child: ListView(
          children: <Widget>[
            Row(
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
                            imageUrl: widget.post.mediaUrl,
                            fit: BoxFit.fill,
                            // fadeInDuration: Duration(milliseconds: 500),
                            // fadeInCurve: Curves.easeIn,
                            placeholder: (context, url) =>
                                new SpinKitFadingCircle(
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
                            widget.post.ownerIddisplayName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Styled By : ${widget.post.beautyProUserName}',
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
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onDoubleTap: () {
                _likePost(widget.post.postId);
              },
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: height / 2,
                    child: Hero(
                      tag: widget.post.postId,
                      child: CachedNetworkImage(
                        imageUrl: widget.post.mediaUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeInCurve: Curves.easeIn,
                        placeholder: (context, url) => SpinKitFadingCircle(
                          color: Colors.blueAccent,
                          size: 30.0,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
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
            ),
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
                              builder: (context) =>
                                  CommentPage(widget.post.postId),
                            ),
                          );
                        },
                      ),
                      new IconButton(
                        icon: Icon(FontAwesomeIcons.paperPlane),
                        tooltip: "Share",
                        onPressed: null,
                      ),
                    ],
                  ),
                  buildSavedIcon(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Liked by ${getLikeCount(widget.post.likes)} People",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Style : ${widget.post.style}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  ),
                  Text(
                    "Description : ${widget.post.description}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  ),
                  Text(
                    "Price : ${widget.post.price}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                  ),
                  Text(
                    "Time Duration : ${widget.post.duration} Min.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
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

  void _savePost(Posts post) {
    var userId = currentUserModel.uid;
    bool _saved = widget.post.savedBy[userId] == true;

    if (_saved) {
      reference.document(widget.post.postId).updateData({
        'savedBy.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      savedPostRef.document(currentUserModel.uid).updateData({
        'savedPostIds.${post.postId}': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      setState(() {
        // likeCount = likeCount - 1;
        saved = false;
        widget.post.savedBy[userId] = false;
      });

      // removeActivityFeedItem();
    }

    if (!_saved) {
      reference
          .document(widget.post.postId)
          .updateData({'savedBy.$userId': true});

      savedPostRef
          .document(currentUserModel.uid)
          .updateData({'savedPostIds.${post.postId}': true});

      //addActivityFeedItem();

      setState(() {
        // likeCount = likeCount + 1;
        saved = true;
        widget.post.savedBy[userId] = true;
      });
    }
  }

  void _likePost(String postId2) {
    var userId = currentUserModel.uid;
    bool _liked = widget.post.likes[userId] == true;

    if (_liked) {
      reference.document(widget.post.postId).updateData({
        'likes.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      setState(() {
        // likeCount = likeCount - 1;
        liked = false;
        widget.post.likes[userId] = false;
      });

      // removeActivityFeedItem();
    }

    if (!_liked) {
      reference
          .document(widget.post.postId)
          .updateData({'likes.$userId': true});

      //addActivityFeedItem();

      setState(() {
        // likeCount = likeCount + 1;
        liked = true;
        widget.post.likes[userId] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
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
        _likePost(widget.post.postId);
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
        _savePost(widget.post);
      },
    );
  }
}
