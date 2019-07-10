import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String beautyPro, bookedBy,bookedByUserName, bookedByDisplayName, bookingId, displayName, mediaUrl, ownerId, ownerIdDisplayName, postId, style;
  final double price;
  final Timestamp timestamp;

  Booking.fromMap(Map<String, dynamic> map)
      : assert(map['bookedBy'] != null),
        assert(map['bookedByUserName'] != null),
        assert(map['bookedByDisplayName'] != null),
        assert(map['bookingId'] != null),
        assert(map['displayName'] != null),
        assert(map['beautyPro'] != null),
        assert(map['mediaUrl'] != null),
        assert(map['ownerId'] != null),
        assert(map['ownerIdDisplayName'] != null),
        assert(map['postId'] != null),
        assert(map['timestamp'] != null),
        assert(map['style'] != null),
        beautyPro = map['beautyPro'],
        bookedBy = map['bookedBy'],
        bookedByUserName = map['bookedByName'],
        bookedByDisplayName = map['bookedByDisplayName'],
        bookingId = map['bookingId'],
        displayName = map['displayName'],
        price = map['price'],
        timestamp = map['timestamp'],
        ownerId = map["ownerId"],
        ownerIdDisplayName = map["ownerIdDisplayName"],
        postId = map["postId"],
        style = map["style"],
        mediaUrl = map["mediaUrl"];

  Booking.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}