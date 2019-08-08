import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'booking_time_view_model.dart';

class BookingTimePage extends StatelessWidget {
  final String _postId;
  BookingTimeViewModel _viewModel;

  BookingTimePage(this._postId) {
    _viewModel = BookingTimeViewModel(_postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(
          "Select time",
          style: Theme.of(context).textTheme.title,
        ),
        bottom: PreferredSize(
            child: StreamBuilder<DateTime>(
                stream: _viewModel.selectedDay,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return OutlineButton(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          snapshot.data.toIso8601String(),
                        ),
                      ),
                      onPressed: () => _selectDate(context, snapshot.data),
                    );
                  } else {
                    return Scaffold();
                  }
                }),
            preferredSize: Size.fromHeight(40)),
      ),
      body: StreamBuilder<TimeInfo>(
          stream: _viewModel.timeInfo,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 80, top: 8),
                itemBuilder: (context, index) {
                  switch(snapshot.data.getItemType(index)) {
                    case ItemType.item:
                      return _createItem(context, snapshot, index);
                    case ItemType.morning:
                      return _createTitle(context, "Morning");
                    case ItemType.afternoon:
                      return _createTitle(context, "Afternoon");
                    case ItemType.evening:
                      return _createTitle(context, "Evening");
                    default:
                      throw StateError("Unexpected state ");
                  }
                },
                itemCount: snapshot.data.getLength(),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.send),
        label: Text("Book"),
      ),
    );
  }

  Widget _createItem(
      BuildContext context, AsyncSnapshot<TimeInfo> snapshot, int index) {
    final time = snapshot.data.getTime(index);
    final title = snapshot.data.getTitle(index);
    final bookingTime = snapshot.data.bookingTime;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
      child: FlatButton(
        textTheme: ButtonTextTheme.normal,
        color: Color.fromARGB(255, 246, 246, 248),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: _getItemTextStyle(context, time, bookingTime),
                ),
                _getItemIcon(context, time, bookingTime),
              ]),
        ),
        onPressed: () {
          _viewModel.selectTime(time);
        },
      ),
    );
  }

  Widget _createTitle(
      BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
      child: Text(text),
    );
  }

  TextStyle _getItemTextStyle(
      BuildContext context, DateTime time, DateTime bookingTime) {
    if (bookingTime == time) {
      return Theme.of(context).textTheme.button.copyWith(
          color: Theme.of(context).accentColor, fontWeight: FontWeight.bold);
    } else {
      return Theme.of(context).textTheme.button;
    }
  }

  Icon _getItemIcon(BuildContext context, DateTime time, DateTime bookingTime) {
    if (bookingTime == time) {
      return Icon(
        Icons.check_circle_outline,
        color: Theme.of(context).accentColor,
      );
    } else {
      return Icon(
        Icons.radio_button_unchecked,
        color: Colors.grey,
      );
    }
  }

  _selectDate(BuildContext context, DateTime date) async {
    DateTime newDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime.now().add(Duration(days: -1)),
        lastDate: DateTime.now().add(Duration(days: 360)));
    if (newDate != null) {
      _viewModel.selectedDay.setValue(newDate);
    }
  }
}
