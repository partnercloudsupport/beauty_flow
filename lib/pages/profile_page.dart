import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/main.dart';
import 'package:beauty_flow/pages/editprofile_page.dart';
import 'package:beauty_flow/pages/insta_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final VoidCallback onSignedOut;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Firestore _db = Firestore.instance;
  String currentUserId = currentUserModel.id;
  bool isFollowing = false;
  bool followButtonClicked = false;
  int postCount = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          User user = User.fromDocument(snapshot.data);

          if (user.followers.containsKey(currentUserId) &&
              user.followers[currentUserId] &&
              followButtonClicked == false) {
            isFollowing = true;
          }
          return Scaffold(
            appBar: AppBar(
              title: Center(child: Text("Beauty Flow")),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: _signOut,
                )
              ],
            ),
            body: ListView(
              children: <Widget>[
                SizedBox(height: 20.0),
                _profilePic(user.photoURL),
                _profileName(user.email, user.displayName),
                _following(user),
                buildProfileFollowButton(user),
                Divider(),
                _buildUserPosts()
              ],
            ),
          );
        });
  }

  _buildUserPosts() {
    Future<List<InstaList>> getPosts() async {
      List<InstaList> posts = [];
      var snap = await _db
          .collection('beautyPosts')
          .where('ownerId', isEqualTo: currentUserModel.id)
          .getDocuments();

      for (var doc in snap.documents) {
        posts.add(InstaList.fromDocument(doc));
      }
      setState(() {
        postCount = snap.documents.length;
      });
      return posts.reversed.toList();
    }

    return Container(
        child: FutureBuilder<List<InstaList>>(
      future: getPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator());
        return Column(
            children: snapshot.data.map((InstaList instaList) {
          return instaList;
        }).toList());
      },
    ));
  }

  _profilePic(String photoURL) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0),
      child: Column(children: <Widget>[
        Row(
          children: <Widget>[
            ClipOval(
              child: new Container(
                height: 50.0,
                width: 50.0,
                child: CachedNetworkImage(
                  imageUrl: (photoURL == "" || photoURL == null)
                      ? "assets/img/person.png"
                      : photoURL,
                  fit: BoxFit.fill,
                  fadeInDuration: Duration(milliseconds: 500),
                  fadeInCurve: Curves.easeIn,
                  placeholder: (context, url) =>
                      new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  _profileName(String email, String displayName) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      child: Text(
        displayName == null ? email : displayName,
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 17.0),
      ),
    );
  }

  _buildFollowButton(
      {String text,
      Color backgroundcolor,
      Color textColor,
      Color borderColor,
      Function function}) {
    return FlatButton(
      onPressed: function,
      child: Container(
        height: 40.0,
        width: 200.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: backgroundcolor,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: textColor, fontFamily: 'Montserrat', fontSize: 15.0),
          ),
        ),
      ),
    );
  }

  buildProfileFollowButton(User user) {
    // viewing your own profile - should show edit button
    if (currentUserId == widget.userId) {
      return FlatButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                    userId: widget.userId,
                  ),
            ),
          );
        },
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Color.fromRGBO(0, 60, 126, 1),
          ),
          child: Center(
            child: Text(
              "Edit Profile",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 15.0),
            ),
          ),
        ),
      );
    }

    if (isFollowing) {
      return _buildFollowButton(
        text: "Unfollow",
        backgroundcolor: Colors.white,
        textColor: Colors.black,
        borderColor: Colors.grey,
        function: unfollowUser,
      );
    }

    // does not follow user - should show follow button
    if (!isFollowing) {
      return _buildFollowButton(
        text: "Follow",
        backgroundcolor: Color.fromRGBO(0, 60, 126, 1),
        textColor: Colors.white,
        borderColor: Colors.blue,
        function: followUser,
      );
    }
  }

  followUser() {
    print('following user');
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    Firestore.instance.document("users/${widget.userId}").updateData({
      'followers.$currentUserId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("users/$currentUserId").updateData({
      'following.${widget.userId}': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    //updates activity feed
    Firestore.instance
        .collection("deautyFeed")
        .document(widget.userId)
        .collection("items")
        .document(currentUserId)
        .setData({
      "ownerId": widget.userId,
      "username": currentUserModel.username,
      "userId": currentUserId,
      "type": "follow",
      "userProfileImg": currentUserModel.photoURL,
      "timestamp": DateTime.now().toString()
    });
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    Firestore.instance.document("users/${widget.userId}").updateData({
      'followers.$currentUserId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("users/$currentUserId").updateData({
      'following.${widget.userId}': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance
        .collection("deautyFeed")
        .document(widget.userId)
        .collection("items")
        .document(currentUserId)
        .delete();
  }

  _following(User user) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                postCount.toString(),
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.red,
                    fontSize: 17.0),
              ),
              Text(
                'Posts',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _countFollowings(user.followers).toString(),
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.red,
                    fontSize: 17.0),
              ),
              Text(
                'Followers',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _countFollowings(user.following).toString(),
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.blue,
                    fontSize: 17.0),
              ),
              Text(
                'Following',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  int _countFollowings(Map followings) {
    int count = 0;

    void countValues(keys, values) {
      if (values) {
        count += 1;
      }
    }

    // hacky fix to enable a user's post to appear in their feed without skewing the follower/following count
    if (followings[widget.userId] != null && followings[widget.userId])
      count -= 1;

    followings.forEach(countValues);

    return count;
  }
}
