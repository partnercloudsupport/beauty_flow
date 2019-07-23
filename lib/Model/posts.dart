import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String beautyProDisplayName,
      beautyProId,
      beautyProUserName,
      description,
      mediaUrl,
      ownerId,
      ownerIddisplayName,
      postId,
      style;
  final int duration, price;
  final Timestamp timestamp;
  final Map likes, savedBy;

  const Posts(
      {this.beautyProDisplayName,
      this.beautyProId,
      this.beautyProUserName,
      this.description,
      this.mediaUrl,
      this.ownerId,
      this.ownerIddisplayName,
      this.postId,
      this.style,
      this.duration,
      this.price,
      this.timestamp,
      this.likes,
      this.savedBy});

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
        savedBy = map["savedBy"],
        duration = map["duration"];

  Posts.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

  Posts.fromDocument(DocumentSnapshot document) : this.fromMap(document.data);

  factory Posts.fromJSON(Map data) {
    return Posts(
      beautyProDisplayName : data['beautyProDisplayName'],
      beautyProId : data['beautyProId'],
      beautyProUserName : data['beautyProUserName'],
      description : data['description'],
      mediaUrl : data['mediaUrl'],
      ownerId : data['ownerId'],
      ownerIddisplayName : data['ownerIddisplayName'],
      postId : data["postId"],
      price : data["price"],
      style : data["style"],
      likes : data["likes"],
      savedBy : data["savedBy"],
      duration : data["duration"],
    );
  }
}
