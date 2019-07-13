import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String id;
  final String photoURL;
  final String username;
  final String displayName;
  final String bio;
  final Map followers;
  final Map following;
  final bool isPro;

  const User(
      {this.username,
      this.id,
      this.photoURL,
      this.email,
      this.displayName,
      this.bio,
      this.followers,
      this.following,
      this.isPro});
  @override
  String toString() => username;
  
  factory User.fromDocument(DocumentSnapshot document) {
    return User(
      email: document['email'],
      username: document['username'],
      photoURL: document['photoURL'],
      id: document.documentID,
      displayName: document['displayName'],
      bio: document['bio'],
      followers: document['followers'],
      following: document['following'],
      isPro: document['isPro']
    );
  }
}
