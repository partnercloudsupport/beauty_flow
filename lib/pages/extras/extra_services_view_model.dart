import 'package:beauty_flow/Model/extra_service.dart';
import 'package:beauty_flow/Model/post.dart';
import 'package:beauty_flow/pages/base/live_data.dart';
import 'package:beauty_flow/pages/base/single_live_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';

class ExtraServicesViewModel {
  final DateTime _bookingDate;
  final String _postId;

  final uploading = LiveData<bool>();
  final messageEvent = SingleLivedEvent<String>();
  final routeBackEvent = SingleLivedEvent<bool>();

  final _post = LiveData<Post>();
  final services = LiveData<List<ServiceCount>>();
  final number = LiveData<int>();

  ExtraServicesViewModel(this._postId, this._bookingDate) {
    _observePost(_postId);
    _observeServices();
    _observeNumber();
  }

  void _observeNumber() {
    services.listen((it) {
      int newNumber;
      it.forEach((item) {
        newNumber += item.count;
      });
      number.setValue(newNumber);
    });
  }

  void _observeServices() {
    _post.listen((it) {
      if(it.extraServices.length > 0) {
        var newList = List<ServiceCount>();
        it.extraServices.forEach((item) {
          newList.add(ServiceCount.fromExtraService(item));
        });
        services.setValue(newList);
      } else {
        bookTime();
      }
    });
  }

  void _observePost(String postId) {
    var stream = Firestore.instance
        .document(Post.TABLE_NAME + "/" + postId)
        .snapshots()
        .map((it) => Post.fromDocument(it));
    _post.addStream(stream);
  }

  Future bookTime() async {
    var post = _post.getValue();
    assert(post != null);
    assert(_bookingDate != null);

    uploading.setValue(true);

    var fsReference = Firestore.instance.collection("bookings");

    QuerySnapshot bookingRef = await Firestore.instance
        .collection("styles")
        .where("styleName", isEqualTo: post.style)
        .getDocuments();
    if (bookingRef.documents.isNotEmpty) {
      var list = bookingRef.documents.toList();
      var sReference =
          Firestore.instance.collection('styles').document(list[0].documentID);
      sReference.updateData({
        "bookings": FieldValue.increment(1),
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    fsReference.add({
      "postId": post.postId,
      "price": post.price,
      "mediaUrl": post.mediaUrl,
      "beautyProId": post.beautyProId,
      "beautyProDisplayName": post.beautyProDisplayName,
      "beautyProUserName": post.beautyProUserName,
      "style": post.style,
      "bookedBy": currentUserModel.uid,
      "bookedByUserName": currentUserModel.username,
      "bookedByDisplayName": currentUserModel.displayName,
      "booking": Timestamp.fromDate(_bookingDate),
      "isConfirmed": 0,
      "timestamp": FieldValue.serverTimestamp(),
    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      fsReference.document(docId).updateData({"bookingId": docId});
    });

    uploading.setValue(false);
    messageEvent.sentValue("Booking Confirmed");
    routeBackEvent.sentValue(null);
  }

  void removeCount(ServiceCount serviceCount) {
    var list = services.getValue();
    var indexOf = list.lastIndexOf(serviceCount);
    list.insert(indexOf,
        list.removeAt(indexOf).copyWith(count: serviceCount.count - 1));
    services.setValue(list);
  }

  void addCount(ServiceCount serviceCount) {
    var list = services.getValue();
    var indexOf = list.lastIndexOf(serviceCount);
    list.insert(indexOf,
        list.removeAt(indexOf).copyWith(count: serviceCount.count + 1));
    services.setValue(list);
  }
}
