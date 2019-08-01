import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/pages/booking_page.dart';
import 'package:beauty_flow/pages/dashboard/dashboard_page.dart';
import 'package:beauty_flow/pages/profile_page.dart';

class BottomBarPage extends StatefulWidget {
  BottomBarPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _BottomBarPageState createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _page = 1;

  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_page),
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        items: [
          Icon(Icons.calendar_today, size: 30),
          Icon(Icons.home, size: 30),
          Icon(Icons.person, size: 30)
        ],
        key: bottomNavigationKey,
        index: 1,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 250),
        onTap: (position) {
          setState(() {
            _page = position;
          });
        },
      ),
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return BookingPage(userId: widget.userId, auth: widget.auth);
      case 1:
        return NewDashBoardPage(
            userId: widget.userId,
            auth: widget.auth,
            onSignedOut: widget.onSignedOut);
      case 2:
        return ProfilePage(
            userId: widget.userId,
            auth: widget.auth,
            onSignedOut: widget.onSignedOut);
      default:
        return NewDashBoardPage(userId: widget.userId, auth: widget.auth);
    }
  }
}
