import 'package:cloud_firestore/cloud_firestore.dart';

import 'extra_service.dart';

class Booking {
  static const String TABLE_NAME = "bookings";
  static const String FIELD_POST_ID = "postId";
  static const String FIELD_BOOKING = "booking";

  final String beautyProId;
  final String beautyProDisplayName;
  final String beautyProUserName;
  final String bookedBy;
  final String bookedByUserName;
  final String bookedByDisplayName;
  final String bookingId;
  final String mediaUrl;
  final String postId;
  final String style;
  final double price;
  final Timestamp timestamp;
  final Timestamp booking;
  final int isConfirmed;
  final List<ServiceCount> services;

  Booking.fromMap(Map<String, dynamic> map)
      : assert(map['bookedBy'] != null),
        assert(map['bookedByUserName'] != null),
        assert(map['bookedByDisplayName'] != null),
        assert(map['bookingId'] != null),
        assert(map['mediaUrl'] != null),
        assert(map['beautyProId'] != null),
        assert(map['beautyProDisplayName'] != null),
        assert(map['beautyProUserName'] != null),
        assert(map[FIELD_POST_ID] != null),
        assert(map['price'] != null),
        assert(map['style'] != null),
        beautyProId = map['beautyProId'],
        bookedBy = map['bookedBy'],
        bookedByUserName = map['bookedByUserName'],
        bookedByDisplayName = map['bookedByDisplayName'],
        bookingId = map['bookingId'],
        price = map['price'].toDouble(),
        timestamp = map['timestamp'],
        beautyProDisplayName = map["beautyProDisplayName"],
        beautyProUserName = map["beautyProUserName"],
        postId = map["postId"],
        isConfirmed = map["isConfirmed"],
        booking = map[FIELD_BOOKING],
        style = map["style"],
        mediaUrl = map["mediaUrl"],
        services = ServiceCount.fromListOfMaps(map["extraServices"]);

  Booking.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}
