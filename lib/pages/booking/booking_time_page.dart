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
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text("Select time"),
        bottom: PreferredSize(
            child: StreamBuilder<DateTime>(
              stream: _viewModel.selectedDay,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return MaterialButton(
                    child: Text(snapshot.data.toIso8601String()),
                    onPressed: () => _selectDate(context, snapshot.data),
                  );
                } else {
                  return Scaffold();
                }
              }
            ),
            preferredSize: Size.fromHeight(50)),
      ),
    ));
  }

  _selectDate(BuildContext context, DateTime date) async {
    DateTime newDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().add(Duration(days: -1)),
      lastDate: DateTime.now().add(Duration(days: 360))
    );
    _viewModel.selectedDay.setValue(newDate);
  }
}
