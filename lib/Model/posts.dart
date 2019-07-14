import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String beautyProDisplayName,beautyProId,beautyProUserName,description,mediaUrl,ownerId,ownerIddisplayName,postId,style;
  final int duration,price;
  final Timestamp timestamp;
  final Map likes;

  Posts.fromMap(Map<String, dynamic> map)
      : assert(map['beautyProDisplayName'] != null),
        assert(map['beautyProId'] != null),
        assert(map['beautyProUserName'] != null),
        assert(map['description'] != null),
        assert(map['mediaUrl'] != null),
        assert(map['ownerId'] != null),
        assert(map['ownerIddisplayName'] != null),
        assert(map['postId'] != null),
        assert(map['timestamp'] != null),
        assert(map['price'] != null),
        assert(map['style'] != null),
        assert(map['duration'] != null),
        assert(map['likes'] != null),
        beautyProDisplayName = map['beautyProDisplayName'],
        beautyProId = map['beautyProId'],
        beautyProUserName = map['beautyProUserName'],
        description = map['description'],
        mediaUrl = map['mediaUrl'],
        ownerId = map['ownerId'],
        ownerIddisplayName = map['ownerIddisplayName'],
        postId = map["postId"],
        timestamp = map["timestamp"],
        price = map["price"],
        style = map["style"],
        likes = map["likes"],
        duration = map["duration"];

  Posts.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

  Posts.fromDocument(DocumentSnapshot document) : this.fromMap(document.data);

}