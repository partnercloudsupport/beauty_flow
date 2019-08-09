import 'package:beauty_flow/Model/booking.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/pages/base/base_view_model.dart';
import 'package:beauty_flow/pages/base/live_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingTimeViewModel extends BaseViewModel {
  final DateFormat _dateFormat = DateFormat.yMMMMd();
  final DateFormat _timeFormat = DateFormat.jm();

  final _startTime = "06:00";
  final _endTime = "20:00";

  final _afternoonTime = "12:00";
  final _eveningTime = "18:00";

  final _bookingList = LiveData<List<Booking>>();
  final _post = LiveData<Posts>();

  final timeInfoList = LiveData<TimeInfoList>();
  final selectedDay = LiveData<DateTime>();

  BookingTimeViewModel(String postId) {
    selectedDay.setValue(DateTime.now());
    _loadPost(postId);
    _loadBooking(postId);

    _observeBookingTime();
  }

  String formatSelectedDate(DateTime date) {
    return _dateFormat.format(date);
  }

  String formatTimePeriod(DateTime time, int duration) {
    return _timeFormat.format(time) +
        " to " +
        _timeFormat.format(time.add(Duration(minutes: duration)));
  }

  void _loadBooking(String postId) {
    var stream = Firestore.instance
        .collection(Booking.TABLE_NAME)
        .orderBy(Booking.FIELD_BOOKING)
        .where(Booking.FIELD_POST_ID, isEqualTo: postId)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((it) => Booking.fromSnapshot(it)).toList();
    });
    _bookingList.addStream(stream);
  }

  void _loadPost(String postId) {
    var stream = Firestore.instance
        .document(Posts.TABLE_NAME + "/" + postId)
        .snapshots()
        .map((it) => Posts.fromDocument(it));
    _post.addStream(stream);
  }

  _observeBookingTime() {
    LiveData.observeTriple(_bookingList, _post, selectedDay,
        (List<Booking> bookingList, Posts post, DateTime date) {
      _createBookingTimeList(bookingList, post, date);
    });
  }

  void _createBookingTimeList(List<Booking> list, Posts post, DateTime date) {
    DateTime afternoonTime = _updateDateByTimeString(date, _afternoonTime);
    DateTime eveningTime = _updateDateByTimeString(date, _eveningTime);

    DateTime startDate = _updateDateByTimeString(date, _startTime);
    DateTime endDate = _updateDateByTimeString(date, _endTime);
    if (_endTime == "00:00") {
      endDate = endDate.add(Duration(days: 1));
    }

    var nextDate = startDate;

    endDate = endDate.add(Duration(minutes: -post.duration));

    final List<DateTime> morningTimes = List();
    final List<DateTime> afternoonTimes = List();
    final List<DateTime> eveningTimes = List();
    while (nextDate.isBefore(endDate) || nextDate.isAtSameMomentAs(endDate)) {
      if (nextDate.isBefore(afternoonTime)) {
        morningTimes.add(nextDate);
      } else if (nextDate.isBefore(eveningTime)) {
        afternoonTimes.add(nextDate);
      } else {
        eveningTimes.add(nextDate);
      }
      nextDate = nextDate.add(Duration(minutes: post.duration));
    }

    List<DateTime> reservedList = list
        .where((it) {
          return morningTimes.contains(it.booking.toDate()) ||
              afternoonTimes.contains(it.booking.toDate()) ||
              eveningTimes.contains(it.booking.toDate());
        })
        .map((it) => it.booking.toDate())
        .toList();

    timeInfoList.setValue(TimeInfoList(null, morningTimes, afternoonTimes,
        eveningTimes, reservedList, post.duration));
  }

  DateTime _updateDateByTimeString(DateTime dateTime, String time) {
    List<String> timeArray = time.split(":");
    return DateTime(dateTime.year, dateTime.month, dateTime.day,
        int.parse(timeArray.elementAt(0)), int.parse(timeArray.elementAt(1)));
  }

  void selectTime(DateTime time) {
    assert(timeInfoList.getValue() != null);
    var value = timeInfoList.getValue();
    value.bookingTime = time;
    timeInfoList.setValue(value);
  }

  void bookTime() {}
}

class TimeInfoList {
  DateTime bookingTime;
  final List<DateTime> _morningTimes;
  final List<DateTime> _afternoonTimes;
  final List<DateTime> _eveningTimes;

  final List<DateTime> reservedTimes;
  final int duration;

  TimeInfoList(this.bookingTime, this._morningTimes, this._afternoonTimes,
      this._eveningTimes, this.reservedTimes, this.duration);

  ItemType getItemType(int index) {
    if (_getMorningIndex() == index) {
      return ItemType.morning;
    } else if (_getAfternoonIndex() == index) {
      return ItemType.afternoon;
    } else if (_getEveningIndex() == index) {
      return ItemType.evening;
    } else {
      return ItemType.item;
    }
  }

  DateTime getTime(int index) {
    var morningLength = _morningTimes.length;
    if (morningLength >= index) {
      return _morningTimes[index - 1];
    }
    var afternoonLength = _afternoonTimes.length;
    if (afternoonLength >= index - morningLength) {
      return _afternoonTimes[index - morningLength];
    }

    if (_eveningTimes.length >= index - afternoonLength - morningLength) {
      return _afternoonTimes[index - afternoonLength - morningLength];
    }
    throw StateError("It is an impassible state you have to check the logic.");
  }

  bool isTimeSelected() {
    return bookingTime != null;
  }

  int getLength() {
    return _morningTimes.length +
        _afternoonTimes.length +
        _eveningTimes.length +
        (_morningTimes.length > 0 ? 0 : 1) +
        (_afternoonTimes.length > 0 ? 0 : 1) +
        (_eveningTimes.length > 0 ? 0 : 1);
  }

  int _getMorningIndex() {
    if (_morningTimes.length > 0) {
      return 0;
    } else {
      return -1;
    }
  }

  int _getAfternoonIndex() {
    if (_afternoonTimes.length > 0) {
      return _morningTimes.length;
    } else {
      return -1;
    }
  }

  int _getEveningIndex() {
    if (_eveningTimes.length > 0) {
      return _afternoonTimes.length + _morningTimes.length;
    } else {
      return -1;
    }
  }
}

enum ItemType { item, morning, afternoon, evening }
