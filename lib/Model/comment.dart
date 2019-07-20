import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String avatarUrl,comment,userId,username,commentId;
  final Timestamp timestamp;
  final Map likes;

  Comment.fromMap(Map<String, dynamic> map)
      : assert(map['comment'] != null),
        assert(map['userId'] != null),
        assert(map['username'] != null),
        avatarUrl = map['avatarUrl'],
        comment = map['comment'],
        userId = map['userId'],
        username = map['username'],
        timestamp = map["timestamp"],
        commentId = map["commentId"],
        likes = map["likes"];

  Comment.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

  Comment.fromDocument(DocumentSnapshot document) : this.fromMap(document.data);

}