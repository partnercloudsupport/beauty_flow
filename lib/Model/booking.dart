import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String beautyProId,beautyProDisplayName, beautyProUserName, bookedBy,bookedByUserName, bookedByDisplayName, bookingId, mediaUrl, postId, style;
  final double price;
  final Timestamp timestamp;

  Booking.fromMap(Map<String, dynamic> map)
      : assert(map['bookedBy'] != null),
        assert(map['bookedByUserName'] != null),
        assert(map['bookedByDisplayName'] != null),
        assert(map['bookingId'] != null),
        assert(map['mediaUrl'] != null),
        assert(map['beautyProId'] != null),
        assert(map['beautyProDisplayName'] != null),
        assert(map['beautyProUserName'] != null),
        assert(map['postId'] != null),
        assert(map['timestamp'] != null),
        assert(map['price'] != null),
        assert(map['style'] != null),
        beautyProId = map['beautyProId'],
        bookedBy = map['bookedBy'],
        bookedByUserName = map['bookedByUserName'],
        bookedByDisplayName = map['bookedByDisplayName'],
        bookingId = map['bookingId'],
        price = map['price'],
        timestamp = map['timestamp'],
        beautyProDisplayName = map["beautyProDisplayName"],
        beautyProUserName = map["beautyProUserName"],
        postId = map["postId"],
        style = map["style"],
        mediaUrl = map["mediaUrl"];

  Booking.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}