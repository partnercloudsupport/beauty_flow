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
                  return _createItem(context, snapshot, index);
                },
                itemCount: snapshot.data.times.length,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.save),
        label: Text("Save"),
      ),
    );
  }

  Padding _createItem(
      BuildContext context, AsyncSnapshot<TimeInfo> snapshot, int index) {
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
                  snapshot.data.titles[index],
                  style: _getItemTextStyle(context, snapshot.data, index),
                ),
                _getItemIcon(context, snapshot.data, index),
              ]),
        ),
        onPressed: () {
          _viewModel.selectTime(snapshot.data.times[index]);
        },
      ),
    );
  }

  TextStyle _getItemTextStyle(
    BuildContext context,
    TimeInfo data,
    int index,
  ) {
    if (data.bookingTime == data.times[index]) {
      return Theme.of(context).textTheme.button.copyWith(
          color: Theme.of(context).accentColor, fontWeight: FontWeight.bold);
    } else {
      return Theme.of(context).textTheme.button;
    }
  }

  Icon _getItemIcon(BuildContext context, TimeInfo data, int index) {
    if (data.bookingTime == data.times[index]) {
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
