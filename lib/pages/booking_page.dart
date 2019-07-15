import 'dart:typed_data';

import 'package:beauty_flow/Model/booking.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key key, this.auth, this.userId}) : super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.calendar_today),
                child: Text(
                  "Your Bookings",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Tab(
                icon: Icon(Icons.calendar_view_day),
                child: Text(
                  "Bookings For You",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                  ),
                ),
              )
            ],
          ),
          title: Text('Beauty Flow'),
        ),
        body: TabBarView(
          children: [
            Container(
              height: 400.0,
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("bookings")
                    .where("bookedBy", isEqualTo: widget.userId)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Center(child: CircularProgressIndicator())
                      : _buildYourBookingList(context, snapshot.data.documents);
                },
              ),
            ),
            Container(
              height: 400.0,
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("bookings")
                    .where("beautyProId", isEqualTo: widget.userId)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Center(child: CircularProgressIndicator())
                      : _buildBookingForYouList(
                          context, snapshot.data.documents);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourBookingList(
      BuildContext context, List<DocumentSnapshot> snapshots) {
    double height = MediaQuery.of(context).size.height;
    if (snapshots.length == 0) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: height < 600 ? 30.0 : 40.0,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            Text(
              "Not booked a style yet?",
              style: TextStyle(
                fontSize: height < 600 ? 20.0 : 25.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
            Text(
              "Go book the look you've been dreaming of",
              style: TextStyle(
                fontSize: height < 600 ? 15.0 : 18.0,
                fontFamily: 'Montserrat',
              ),
            ),
            Text(
              "and we'll keep the details in here for you",
              style: TextStyle(
                fontSize: height < 600 ? 15.0 : 18.0,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: snapshots.length,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return YourBookingList(
              booking: Booking.fromSnapshot(snapshots[index]));
        },
      );
    }
  }
}

Widget _buildBookingForYouList(
    BuildContext context, List<DocumentSnapshot> snapshots) {
  double height = MediaQuery.of(context).size.height;
  if (snapshots.length == 0) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            size: height < 600 ? 30.0 : 40.0,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          ),
          Text(
            "No bookings found for you",
            style: TextStyle(
              fontSize: height < 600 ? 18.0 : 22.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  } else {
    return ListView.builder(
      itemCount: snapshots.length,
      scrollDirection: Axis.vertical,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        return BookingForList(booking: Booking.fromSnapshot(snapshots[index]));
      },
    );
  }
}

class _YourBookingListArticleDescription extends StatelessWidget {
  _YourBookingListArticleDescription({Key key, this.booking}) : super(key: key);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Beauty Pro: ${booking.beautyProUserName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Beautician: ${booking.beautyProDisplayName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Cost: ${booking.price} in Rs.',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                'Booked On: ${booking.timestamp.toDate()}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class YourBookingList extends StatelessWidget {
  YourBookingList({
    Key key,
    this.booking,
  }) : super(key: key);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 160,
        decoration: new BoxDecoration(
          color: Colors.tealAccent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: (booking.mediaUrl == "" || booking.mediaUrl == null)
                  ? "assets/img/person.png"
                  : booking.mediaUrl,
              fit: BoxFit.fill,
              fadeInDuration: Duration(milliseconds: 500),
              fadeInCurve: Curves.easeIn,
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 2.0, 10.0),
                child: _YourBookingListArticleDescription(
                  booking: booking,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingForYouListArticleDescription extends StatelessWidget {
  _BookingForYouListArticleDescription({Key key, this.booking})
      : super(key: key);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Booked By: ${booking.bookedByUserName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Booked Id: ${booking.bookingId}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Booked Style: ${booking.style}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Cost: ${booking.price} in Rs.',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Booking For: ${booking.booking != null ? booking.booking.toDate() : ''}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon:
                    booking.isConfirmed ? Icon(Icons.close) : Icon(Icons.check),
                color: Colors.black,
                tooltip: 'Confirm/Reject',
                onPressed: () {
                  _bookingStatus(booking.isConfirmed);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _bookingStatus(bool isConfirmed) {
    print(isConfirmed);
    bool bookingStatus = !isConfirmed;
    Firestore.instance
        .collection('bookings')
        .document(booking.bookingId)
        .updateData({
      'isConfirmed': bookingStatus,
      'timestamp': FieldValue.serverTimestamp()
    });
  }
}

class BookingForList extends StatelessWidget {
  BookingForList({
    Key key,
    this.booking,
  }) : super(key: key);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 160,
        decoration: new BoxDecoration(
          color: Colors.tealAccent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: (booking.mediaUrl == "" || booking.mediaUrl == null)
                  ? "assets/img/person.png"
                  : booking.mediaUrl,
              fit: BoxFit.fill,
              fadeInDuration: Duration(milliseconds: 500),
              fadeInCurve: Curves.easeIn,
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 2.0, 10.0),
                child: _BookingForYouListArticleDescription(
                  booking: booking,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 30),
            )
          ],
        ),
      ),
    );
  }
}
