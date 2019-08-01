import 'dart:async';
import 'dart:io';

import 'package:beauty_flow/Model/Style.dart';
import 'package:beauty_flow/Model/User.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/pages/base/base_view_model.dart';
import 'package:beauty_flow/pages/base/live_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geo_firestore/geo_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DashboardViewModel extends BaseViewModel {
  StreamSubscription iosSubscription;

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _store = Firestore.instance;
  final String _userId;

  final LiveData<List<Style>> styleList = LiveData();
  final LiveData<List<User>> proUserList = LiveData();
  final LiveData<List<Posts>> postList = LiveData();

  DashboardViewModel(this._userId) {
    _prepareToSaveDeviceToken();
    _setLocation();
    _loadNearestPosts();
    _loadProUsers();
    _loadStyles();
  }

  void _loadProUsers() {
     var stream = Firestore.instance
        .collection("users")
        .where('isPro', isEqualTo: true)
        .orderBy("followersCount", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((it) => User.fromSnapshot(it)).toList();
    });
    proUserList.addStream(stream);
  }

  void _loadStyles() {
    var stream = Firestore.instance
        .collection("styles")
        .orderBy("bookings", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((it) => Style.fromSnapshot(it)).toList();
    });
    styleList.addStream(stream);
  }

  _loadNearestPosts() async {
    final Position position = await _getGeolocation();

    GeoFirestore geoFirestore =
        GeoFirestore(Firestore.instance.collection('beautyPosts'));
    List<DocumentSnapshot> list = await geoFirestore.getAtLocation(
        GeoPoint(position.latitude, position.longitude), 5);
    postList.setValue(list.map((it) => Posts.fromDocument(it)).toList());
  }

  Future<Position> _getGeolocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position == null) {
      position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    }
    return position;
  }

  _setLocation() async {
    Firestore firestore = Firestore.instance;
    GeoFirestore geoFirestore =
        GeoFirestore(firestore.collection('beautyPosts'));
    await geoFirestore.setLocation(
        '-LkzDF9JV_5RqzP2BRRo', GeoPoint(37.7853889, -122.4056973));
  }

  void _prepareToSaveDeviceToken() {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }
  }

  _saveDeviceToken() async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();
    print(fcmToken);
    // Save it to Firestore
    if (fcmToken != null) {
      print(fcmToken);
      var tokens = _store
          .collection('users')
          .document(_userId)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
  }
}
