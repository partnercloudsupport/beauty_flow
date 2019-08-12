import 'package:beauty_flow/Model/extra_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'extra_services_view_model.dart';

class ExtraServicesPage extends StatelessWidget {
  final String _postId;
  final DateTime _selectedDate;
  final ExtraServicesViewModel _viewModel;

  ExtraServicesPage(this._postId, this._selectedDate)
      : _viewModel = ExtraServicesViewModel(_postId, _selectedDate);

  @override
  Widget build(BuildContext context) {
    var uploadingDialog =
        new ProgressDialog(context, ProgressDialogType.Normal);
    _viewModel.uploading.listen((isLoading) {
      if (isLoading) {
        uploadingDialog.show();
      } else {
        uploadingDialog.hide();
      }
    });
    _viewModel.messageEvent.listen((message) {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    });
    _viewModel.routeBackEvent.listen((it) {
      Navigator.pop(context);
      Navigator.pop(context);
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          "EXTRAS",
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: StreamBuilder<List<ServiceCount>>(
          stream: _viewModel.services,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _createItemWidget(context, snapshot.data[index]));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget _createItemWidget(BuildContext context, ServiceCount serviceCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                serviceCount.title,
                style: Theme.of(context).textTheme.title,
              ),
              Text(serviceCount.description,
                  style: Theme.of(context).textTheme.subtitle),
              Text(serviceCount.price.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Theme.of(context).accentColor))
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                  visible: serviceCount.count > 0,
                  child: Ink(
                    height: 30,
                    width: 30,
                    decoration: ShapeDecoration(
                      color: Colors.black12,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          _viewModel.removeCount(serviceCount);
                        }),
                  )),
              Visibility(
                  visible: serviceCount.count > 0,
                  child: Container(
                    width: 25,
                    child: Center(
                      child: Text(
                        serviceCount.count.toString(),
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  )),
              Ink(
                height: 30,
                width: 30,
                decoration: ShapeDecoration(
                  color: Colors.grey,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _viewModel.addCount(serviceCount);
                    }),
              )
            ],
          )
        ],
      ),
    );
  }
}
