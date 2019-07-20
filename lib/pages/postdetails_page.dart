import 'dart:async';
import 'package:beauty_flow/pages/comment_page.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // Changeable in demo
  DateTime date = DateTime.now();
  String dateTimeString = "Pick Date";

  var reference = Firestore.instance.collection('beautyPosts');

  @override
  Widget build(BuildContext context) {
    liked = (widget.post.likes[currentUserModel.uid.toString()] == true);
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Beauty Flow"),
        centerTitle: true,
      ),
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
                  new IconButton(
                    icon: Icon(FontAwesomeIcons.bookmark),
                    tooltip: "BookMark",
                    onPressed: null,
                  )
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
            _dateTimePicker(),
            SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }

  Widget _dateTimePicker() {
    if (widget.post.beautyProId == currentUserModel.uid) {
      return Container();
    } else {
      return Padding(
        padding: EdgeInsets.only(right: 10, left: 10, bottom: 16.0, top: 20),
        child: Column(
          children: <Widget>[
            FlatButton(
              onPressed: _showDateTimePicker,
              child: Text(dateTimeString),
              color: Colors.tealAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Container(
              height: 40.0,
              padding: EdgeInsets.only(right: 10, left: 10),
              child: InkWell(
                onTap: () {
                  _booking();
                },
                child: Material(
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Colors.greenAccent,
                  color: Colors.green,
                  elevation: 7.0,
                  child: Center(
                    child: Text(
                      'Book',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showDateTimePicker() {
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime.parse('1999-01-01 00:00:00'),
      maxDateTime: DateTime.parse('2050-12-31 00:00:00'),
      initialDateTime: DateTime.now(),
      dateFormat: "yyyy.MM.dd G 'at' HH:mm:ss vvvv",
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
      ),
      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          date = dateTime;
          dateTimeString = date.toLocal().toString();
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          date = dateTime;
          dateTimeString = date.toLocal().toString();
        });
      },
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

  void _booking() async {
    if (date != null) {
      var fsReference = Firestore.instance.collection("bookings");

      QuerySnapshot bookingRef = await Firestore.instance
          .collection("styles")
          .where("styleName", isEqualTo: widget.post.style)
          .getDocuments();
      if (bookingRef.documents.isNotEmpty) {
        var list = bookingRef.documents.toList();
        var sReference = Firestore.instance
            .collection('styles')
            .document(list[0].documentID);
        sReference.updateData({
          "bookings": FieldValue.increment(1),
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      fsReference.add({
        "postId": widget.post.postId,
        "price": widget.post.price,
        "mediaUrl": widget.post.mediaUrl,
        "beautyProId": widget.post.beautyProId,
        "beautyProDisplayName": widget.post.beautyProDisplayName,
        "beautyProUserName": widget.post.beautyProUserName,
        "style": widget.post.style,
        "bookedBy": currentUserModel.uid,
        "bookedByUserName": currentUserModel.username,
        "bookedByDisplayName": currentUserModel.displayName,
        "booking": date,
        "isConfirmed": 0,
        "timestamp": FieldValue.serverTimestamp(),
      }).then((DocumentReference doc) {
        String docId = doc.documentID;
        fsReference.document(docId).updateData({"bookingId": docId});
      });

      Fluttertoast.showToast(
          msg: "Booking Confirmed on ${date.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Please Select Date",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
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
}
