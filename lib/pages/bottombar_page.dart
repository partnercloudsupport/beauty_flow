import 'package:beauty_flow/authentication/authentication.dart';
import 'package:beauty_flow/pages/dashboard_page.dart';
import 'package:beauty_flow/pages/newpost_page.dart';
import 'package:beauty_flow/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';

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
  int currentPage = 0;

  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(currentPage),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.home, title: "Home"),
          TabData(iconData: Icons.add, title: "New Post"),
          TabData(iconData: Icons.person, title: "Profile")
        ],
        initialSelection: 0,
        key: bottomNavigationKey,
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return DashBoardPage(
          userId: widget.userId,
          auth: widget.auth,
          onSignedOut: widget.onSignedOut
        );
      case 1:
        return NewPostPage(
          userId: widget.userId,
          auth: widget.auth
        );
      case 2:
        return ProfilePage(
          userId: widget.userId,
          auth: widget.auth,
          onSignedOut: widget.onSignedOut
        );
      default:
        return DashBoardPage(
          userId: widget.userId,
          auth: widget.auth
        );
    }
  }
}