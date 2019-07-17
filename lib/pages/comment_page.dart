import 'package:beauty_flow/Model/comment.dart';
import 'package:beauty_flow/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentPage extends StatefulWidget {
  CommentPage(this.postId);

  final String postId;
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("post_comments")
                  .document(widget.postId)
                  .collection("comments")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                      alignment: FractionalOffset.center,
                      child: CircularProgressIndicator());
                return ListTile(
                  title: _buildCommentList(context, snapshot.data.documents),
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Write a comment...'),
              onFieldSubmitted: addComment,
            ),
            trailing: OutlineButton(
              onPressed: () {
                addComment(_commentController.text);
              },
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          ),
        ],
      ),
    );
  }

  addComment(String comment) {
    _commentController.clear();
    Firestore.instance
        .collection("post_comments")
        .document(widget.postId)
        .collection("comments")
        .add({
      "username": currentUserModel.username,
      "comment": comment,
      "timestamp": FieldValue.serverTimestamp(),
      "avatarUrl": currentUserModel.photoURL,
      "userId": currentUserModel.uid,
      "likes": {}
    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      Firestore.instance
          .collection("post_comments")
          .document(widget.postId)
          .collection("comments")
          .document(docId)
          .updateData({"commentId": docId});
    });

    //adds to postOwner's activity feed
    // Firestore.instance
    //     .collection("insta_a_feed")
    //     .document(postOwner)
    //     .collection("items")
    //     .add({
    //   "username": currentUserModel.username,
    //   "userId": currentUserModel.uid,
    //   "type": "comment",
    //   "userProfileImg": currentUserModel.photoURL,
    //   "commentData": comment,
    //   "timestamp": DateTime.now().toString(),
    //   "postId": widget.postId,
    //   "mediaUrl": postMediaUrl,
    // });
  }

  Widget _buildCommentList(
      BuildContext context, List<DocumentSnapshot> snapshots) {
    double height = MediaQuery.of(context).size.height;
    if (snapshots.length == 0) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No Comments Found",
              style: TextStyle(
                fontSize: height < 600 ? 20.0 : 25.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: snapshots.length,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          var comment = Comment.fromDocument(snapshots[index]);
          return ListTile(
            leading: ClipOval(
              child: new Container(
                height: 50.0,
                width: 50.0,
                child: CachedNetworkImage(
                  imageUrl:
                      (comment.avatarUrl == "" || comment.avatarUrl == null)
                          ? ""
                          : comment.avatarUrl,
                  fit: BoxFit.fill,
                  fadeInDuration: Duration(milliseconds: 500),
                  fadeInCurve: Curves.easeIn,
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            title: Text(comment.username),
            subtitle: Text("Comment : ${comment.comment}"),
            trailing: _buildLikeButton(comment),
          );
        },
      );
    }
  }

  _buildLikeButton(Comment comment) {
    bool isLike = (comment.likes[currentUserModel.uid.toString()] == true);

    if (isLike) {
      return IconButton(
        icon: Icon(FontAwesomeIcons.solidHeart),
        iconSize: 15,
        onPressed: () {
          _likePost(comment);
        },
      );
    } else {
      return IconButton(
        icon: Icon(FontAwesomeIcons.heart),
        iconSize: 15,
        onPressed: () {
          _likePost(comment);
        },
      );
    }
  }

  void _likePost(Comment comment) {
    var userId = currentUserModel.uid;
    bool _liked = comment.likes[userId] == true;

    if (_liked) {
      Firestore.instance
          .collection("post_comments")
          .document(widget.postId)
          .collection("comments")
          .document(comment.commentId)
          .updateData({
        'likes.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });
    }

    if (!_liked) {
      Firestore.instance
          .collection("post_comments")
          .document(widget.postId)
          .collection("comments")
          .document(comment.commentId)
          .updateData({'likes.$userId': true});
    }
  }
}
