import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// It is a stream object and can keep the last state. Also can have more than one subscription.
class LiveData<T> extends Stream<T> {
  StreamController<T> _controller;
  Stream<T> _stream;

  LiveData() {
    _controller = StreamController<T>();
    _stream = Observable<T>(_controller.stream).shareValue();
  }

  // Set a new value to keep and notify.
  setValue(T value) {
    _controller.add(value);
  }

  // Add a stream to use its emitted values.
  addStream(Stream<T> stream) {
    _controller.addStream(stream);
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
