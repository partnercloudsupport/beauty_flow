import 'package:cloud_firestore/cloud_firestore.dart';

class Style {
  final String styleName, imageUrl;
  final int bookings,styleId;
  final Timestamp timestamp;

  Style.fromMap(Map<String, dynamic> map)
      : assert(map['styleName'] != null),
        assert(map['bookings'] != null),
        assert(map['imageUrl'] != null),
        assert(map['styleId'] != null),
        styleName = map['styleName'],
        imageUrl = map['imageUrl'],
        bookings = map['bookings'],
        styleId = map['styleId'],
        timestamp = map['timestamp'];

  Style.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}