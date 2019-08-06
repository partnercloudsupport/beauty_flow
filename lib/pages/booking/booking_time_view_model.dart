import 'package:beauty_flow/Model/booking.dart';
import 'package:beauty_flow/Model/posts.dart';
import 'package:beauty_flow/pages/base/base_view_model.dart';
import 'package:beauty_flow/pages/base/live_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingTimeViewModel extends BaseViewModel {
  final _startTime = "00:00";
  final _endTime = "00:00";

  final _afternoonTime = "12:00";
  final _eveningTime = "18:00";

  final _bookingList = LiveData<List<Booking>>();
  final _post = LiveData<Posts>();

  final bookingDateList = LiveData<TimeInfo>();
  final selectedDay = LiveData<DateTime>();

  BookingTimeViewModel(String postId) {
    selectedDay.setValue(DateTime.now());
    _loadPost(postId);
    _loadBooking(postId);

    _observeBookingTime();
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
      createBookingTimeList(bookingList, post, date);
    });
  }

  void createBookingTimeList(List<Booking> list, Posts post, DateTime date) {
    DateTime afternoonTime = _updateDateByTimeString(date, _afternoonTime);
    DateTime eveningTime = _updateDateByTimeString(date, _eveningTime);

    DateTime startDate = _updateDateByTimeString(date, _startTime);
    DateTime endDate = _updateDateByTimeString(date, _endTime);
    if (_endTime == "00:00") {
      endDate = endDate.add(Duration(days: 1));
    }

    var nextDate = startDate;

    endDate = endDate.add(Duration(minutes: -post.duration));

    var dates = List<DateTime>();

    int position = -1;
    int morningPosition = -1;
    int afternoonPosition = -1;
    int eveningPosition = -1;
    while (nextDate.isBefore(endDate) && nextDate.isAtSameMomentAs(endDate)) {
      if (nextDate.isBefore(afternoonTime)) {
        morningPosition = position;
      } else if (nextDate.isBefore(eveningTime)) {
        afternoonPosition = position;
      } else {
        eveningPosition = position;
      }
      dates.add(nextDate);
      nextDate = nextDate.add(Duration(minutes: post.duration));
      position++;
    }

    List<DateTime> reservedList = list
        .where((it) {
          return dates.contains(it.booking.toDate());
        })
        .map((it) => it.booking.toDate())
        .toList();

    bookingDateList.setValue(TimeInfo(null, dates, reservedList, post.duration,
        morningPosition, afternoonPosition, eveningPosition));
  }

  DateTime _updateDateByTimeString(DateTime dateTime, String time) {
    List<String> timeArray = _startTime.split(":");
    return DateTime(dateTime.year, dateTime.month, dateTime.day,
        int.parse(timeArray.elementAt(0)), int.parse(timeArray.elementAt(1)));
  }
}

class TimeInfo {
  final DateFormat _dateFormat = DateFormat.jm();

  List<String> titles;
  final List<DateTime> times;
  final List<DateTime> reservedTimes;
  final DateTime bookingTime;
  final int morningPosition;
  final int afternoonPosition;
  final int eveningPosition;

  TimeInfo(this.bookingTime, this.times, this.reservedTimes, duration,
      this.morningPosition, this.afternoonPosition, this.eveningPosition) {
    final List<String> list = List<String>();
    times.forEach((it) {
      String title = _dateFormat.format(bookingTime) +
          " to " +
          _dateFormat.format(bookingTime.subtract(Duration(minutes: duration)));
      list.add(title);
    });
    titles = list;
  }
}

class BookingData {
  final List<DateTime> dates;

  final int morningPosition;
  final int afternoonPosition;
  final int eveningPosition;

  BookingData(this.dates, this.morningPosition, this.afternoonPosition,
      this.eveningPosition);
}
