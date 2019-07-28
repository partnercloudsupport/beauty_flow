import 'dart:async';
import 'dart:io';

import 'package:beauty_flow/pages/base/base_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DashboardViewModel extends BaseViewModel {
  StreamSubscription iosSubscription;

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final _store = Firestore.instance;
  final String _userId;

  DashboardViewModel(this._userId) {
    _prepareToSaveDeviceToken();
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
