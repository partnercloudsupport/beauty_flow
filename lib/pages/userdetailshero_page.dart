import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/postdetails_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailsHeroPage extends StatefulWidget {
  UserDetailsHeroPage(this.user);
  final User user;

  @override
  _UserDetailsHeroPageState createState() => _UserDetailsHeroPageState();
}

class _UserDetailsHeroPageState extends State<UserDetailsHeroPage> {
  bool isFollowing = false;
  bool followButtonClicked = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    if (widget.user.followers.containsKey(currentUserModel.uid) &&
        widget.user.followers[currentUserModel.uid] &&
        followButtonClicked == false) {
      isFollowing = true;
    }
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('beautyPosts')
            .where("ownerId", isEqualTo: widget.user.uid)
            .limit(40)
            .snapshots(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: [
                    SliverAppBar(
                      expandedHeight: height / 2.5,
                      backgroundColor: Colors.white,
                      leading: IconButton(
                        icon: Icon(Icons.close),
                        color: Colors.black,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      pinned: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                            ),
                            Hero(
                              tag: widget.user.uid,
                              child: ClipOval(
                                child: new Container(
                                  height: 100.0,
                                  width: 100.0,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.user.photoURL,
                                    fit: BoxFit.fill,
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
                            SizedBox(height: 10.0),
                            Text(
                              widget.user.username,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              '${widget.user.displayName}',
                              style: TextStyle(
                                  fontFamily: 'Montserrat', color: Colors.grey),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        widget.user.followersCount.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'FOLLOWERS',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        widget.user.followingCount.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'FOLLOWING',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        snapshot.data.documents.length
                                            .toString(), //widget.posts.length.toString(),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'POSTS',
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildFollowutton(),
                          ],
                        ),
                      ),
                    ),
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        var posts =
                            Posts.fromMap(snapshot.data.documents[index].data);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailsPage(posts),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(2, 2),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                ),
                              ],
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              child: Hero(
                                tag: posts.postId,
                                child: CachedNetworkImage(
                                  imageUrl: posts.mediaUrl,
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
                        );
                      }, childCount: snapshot.data.documents.length),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  _unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    Firestore.instance.document("users/${widget.user.uid}").updateData({
      'followers.${currentUserModel.uid}': false,
      'followersCount': FieldValue.increment(-1)
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("users/${currentUserModel.uid}").updateData({
      'following.${widget.user.uid}': false,
      'followingCount':FieldValue.increment(-1)
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance
        .collection("deautyFeed")
        .document(widget.user.uid)
        .collection("items")
        .document(currentUserModel.uid)
        .delete();
  }

  _followUser() {
    print('following user');
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    Firestore.instance.document("users/${widget.user.uid}").updateData({
      'followers.${currentUserModel.uid}': true,
      'followersCount': FieldValue.increment(1)
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("users/${currentUserModel.uid}").updateData({
      'following.${widget.user.uid}': true,
      'followingCount':FieldValue.increment(1)
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    //updates activity feed
    Firestore.instance
        .collection("deautyFeed")
        .document(widget.user.uid)
        .collection("items")
        .document(currentUserModel.uid)
        .setData({
      "ownerId": widget.user.uid,
      "username": currentUserModel.username,
      "userId": currentUserModel.uid,
      "type": "follow",
      "userProfileImg": currentUserModel.photoURL,
      "timestamp": FieldValue.serverTimestamp()
    });
  }

  _buildFollowutton() {
    if (currentUserModel.uid == widget.user.uid) {
      return Container();
    }

    if (isFollowing) {
      return GestureDetector(
        onTap: _unfollowUser,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: new Border.all(
                color: Colors.lightBlue, width: 2.0, style: BorderStyle.solid),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              'UNFOLLOW',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 15.0),
            ),
          ),
        ),
      );
    } else if (!isFollowing) {
      return GestureDetector(
        onTap: _followUser,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: new Border.all(
                color: Colors.lightBlue, width: 2.0, style: BorderStyle.solid),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              'FOLLOW',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 15.0),
            ),
          ),
        ),
      );
    }
  }
}
