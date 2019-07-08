import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String beautyPro, bookedBy, bookingId, displayName, mediaUrl, ownerId, postId, style;
  final double price;
  final Timestamp timestamp;

  Booking.fromMap(Map<String, dynamic> map)
      : assert(map['bookedBy'] != null),
        assert(map['bookingId'] != null),
        assert(map['displayName'] != null),
        assert(map['beautyPro'] != null),
        assert(map['mediaUrl'] != null),
        assert(map['ownerId'] != null),
        assert(map['postId'] != null),
        assert(map['timestamp'] != null),
        assert(map['style'] != null),
        beautyPro = map['beautyPro'],
        bookedBy = map['bookedBy'],
        bookingId = map['bookingId'],
        displayName = map['displayName'],
        price = map['price'],
        timestamp = map['timestamp'],
        ownerId = map["ownerId"],
        postId = map["postId"],
        style = map["style"],
        mediaUrl = map["mediaUrl"];

  Booking.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}