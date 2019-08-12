import 'package:cloud_firestore/cloud_firestore.dart';

import 'extra_service.dart';

class Post {
  static const String TABLE_NAME = "beautyPosts";
  static const String FIELD_EXTRA_SERVICES = "extraServices";

  final String beautyProDisplayName;
  final String beautyProId;
  final String beautyProUserName;
  final String description;
  final String mediaUrl;
  final String ownerId;
  final String ownerIdDisplayName;
  final String postId;
  final String style;
  final int duration;
  final int price;
  final Timestamp timestamp;
  final Map likes;
  final Map savedBy;
  final List<ExtraService> extraServices;

  const Post(
      {this.beautyProDisplayName,
      this.beautyProId,
      this.beautyProUserName,
      this.description,
      this.mediaUrl,
      this.ownerId,
      this.ownerIdDisplayName,
      this.postId,
      this.style,
      this.duration,
      this.price,
      this.timestamp,
      this.likes,
      this.savedBy,
      this.extraServices});

  Post.fromMap(Map<String, dynamic> map)
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
        ownerIdDisplayName = map['ownerIddisplayName'],
        postId = map["postId"],
        timestamp = map["timestamp"],
        price = map["price"],
        style = map["style"],
        likes = map["likes"],
        savedBy = map["savedBy"],
        duration = map["duration"],
        extraServices = ExtraService.fromListOfMaps(map[FIELD_EXTRA_SERVICES]);

  Post.fromDocument(DocumentSnapshot document) : this.fromMap(document.data);

  factory Post.fromJSON(Map data) {
    return Post(
      beautyProDisplayName: data['beautyProDisplayName'],
      beautyProId: data['beautyProId'],
      beautyProUserName: data['beautyProUserName'],
      description: data['description'],
      mediaUrl: data['mediaUrl'],
      ownerId: data['ownerId'],
      ownerIdDisplayName: data['ownerIddisplayName'],
      postId: data["postId"],
      price: data["price"],
      style: data["style"],
      likes: data["likes"],
      savedBy: data["savedBy"],
      duration: data["duration"],
    );
  }
}
