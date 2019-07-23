import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoURL;
  final String username;
  final String displayName;
  final String bio;
  final Map followers;
  final Map following,savedPostIds;
  final bool isPro;
  final int followersCount, followingCount;

  const User(
      {this.username,
      this.uid,
      this.photoURL,
      this.email,
      this.displayName,
      this.bio,
      this.followers,
      this.following,
      this.followersCount,
      this.followingCount,
      this.savedPostIds,
      this.isPro});
  @override
  String toString() => username;
  
  factory User.fromDocument(DocumentSnapshot document) {
    return User(
      email: document['email'],
      username: document['username'],
      photoURL: document['photoURL'],
      uid: document.documentID,
      displayName: document['displayName'],
      bio: document['bio'],
      followers: document['followers'],
      following: document['following'],
      savedPostIds : document['savedPostIds'],
      followersCount: document['followersCount'],
      followingCount: document['followingCount'],
      isPro: document['isPro']
    );
  }

  User.fromMap(Map<String, dynamic> map)
      : assert(map['email'] != null),
        assert(map['username'] != null),
        assert(map['uid'] != null),
        assert(map['isPro'] != null),
        email = map['email'],
        username = map['username'],
        photoURL = map['photoURL'] == null ? "" : map['photoURL'],
        displayName = map['displayName'],
        uid = map['uid'],
        bio = map['bio'],
        followers = map['followers'],
        following = map['following'],
        savedPostIds = map['savedPostIds'],
        followersCount = map['followersCount'],
        followingCount = map['followingCount'],
        isPro = map['isPro'];

  User.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}
