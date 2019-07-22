import 'package:beauty_flow/Model/booking.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beauty_flow/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Beauty Flow"),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    if (currentUserModel.isPro) {
      return Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("bookings")
              .where("beautyProId", isEqualTo: widget.userId)
              .orderBy("booking", descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? Center(
                    child: SpinKitChasingDots(
                      color: Colors.blueAccent,
                      size: 60.0,
                    ),
                  )
                : _buildBookingForYouList(context, snapshot.data.documents);
          },
        ),
      );
    } else {
      return Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("bookings")
              .where("bookedBy", isEqualTo: widget.userId)
              .orderBy("booking", descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? Center(
                    child: SpinKitChasingDots(
                      color: Colors.blueAccent,
                      size: 60.0,
                    ),
                  )
                : _buildYourBookingList(context, snapshot.data.documents);
          },
        ),
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
        return BookingList(booking: Booking.fromSnapshot(snapshots[index]));
      },
    );
  }
}

class BookingList extends StatelessWidget {
  BookingList({
    Key key,
    this.booking,
  }) : super(key: key);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                width: 120,
                imageUrl: (booking.mediaUrl == "" || booking.mediaUrl == null)
                    ? "assets/img/person.png"
                    : booking.mediaUrl,
                fit: BoxFit.fill,
                // fadeInDuration: Duration(milliseconds: 500),
                // fadeInCurve: Curves.easeIn,
                placeholder: (context, url) => SpinKitFadingCircle(
                  color: Colors.blueAccent,
                  size: 30.0,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 2.0, 10.0),
                  child: _BookingArticleDescription(
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
      ),
    );
  }
}

class _BookingArticleDescription extends StatelessWidget {
  _BookingArticleDescription({Key key, this.booking}) : super(key: key);

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
                'Booking For: ${booking.booking.toDate()}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Booking Status: ${booking.isConfirmed == 0 ? 'Pending' : booking.isConfirmed == 1 ? 'Confirmed' : 'Rejected'}',
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
                icon: Icon(Icons.check),
                color: Colors.black,
                tooltip: 'Confirm',
                onPressed:
                    (booking.isConfirmed == 0 || booking.isConfirmed == -1)
                        ? _bookingStatusConfirm
                        : null,
              ),
              IconButton(
                icon: Icon(Icons.close),
                color: Colors.black,
                tooltip: 'Reject',
                onPressed:
                    (booking.isConfirmed == 0 || booking.isConfirmed == 1)
                        ? _bookingStatusReject
                        : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _bookingStatusConfirm() {
    Firestore.instance
        .collection('bookings')
        .document(booking.bookingId)
        .updateData(
            {'isConfirmed': 1, 'timestamp': FieldValue.serverTimestamp()});
  }

  _bookingStatusReject() {
    Firestore.instance
        .collection('bookings')
        .document(booking.bookingId)
        .updateData(
            {'isConfirmed': -1, 'timestamp': FieldValue.serverTimestamp()});
  }
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
        return YourBookingList(booking: Booking.fromSnapshot(snapshots[index]));
      },
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
        height: 200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: (booking.mediaUrl == "" || booking.mediaUrl == null)
                    ? "assets/img/person.png"
                    : booking.mediaUrl,
                fit: BoxFit.contain,
                width: 120,
                // fadeInDuration: Duration(milliseconds: 500),
                // fadeInCurve: Curves.easeIn,
                placeholder: (context, url) => SpinKitFadingCircle(
                  color: Colors.blueAccent,
                  size: 30.0,
                ),
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
      ),
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
                'Beautician: ${booking.beautyProDisplayName}',
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
                'Booking For: ${booking.booking == null ? DateTime.now() : booking.booking.toDate()}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                'Booking Status: ${booking.isConfirmed == 0 ? 'Pending' : booking.isConfirmed == 1 ? 'Confirmed' : 'Rejected'}',
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
                icon: Icon(Icons.close),
                color: Colors.black,
                tooltip: 'Cancel',
                onPressed:
                    (booking.isConfirmed == 0) ? _bookingStatusReject : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _bookingStatusReject() {
    Firestore.instance
        .collection('bookings')
        .document(booking.bookingId)
        .updateData(
            {'isConfirmed': -1, 'timestamp': FieldValue.serverTimestamp()});
  }
}
