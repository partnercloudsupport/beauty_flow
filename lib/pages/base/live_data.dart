import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// It is a stream object and can keep the last state. Also can have more than one subscription.
class LiveData<T> extends Stream<T> {

  /// Invoke listener only if values are unique and not nullable
  static observeMulti(
      List<LiveData<Object>> list, Function(List<Object>) listener) {
    List<Object> values = List(list.length);
    for (var index = 0; index < list.length; index++) {
      values[index] = null;
    }
    for (var index = 0; index < list.length; index++) {
      list[index].listen((it) {
        if (values[index] != it) {
          values[index] = it;
          if (values.every((it) => it != null)) {
            listener(values);
          }
        }
      });
    }
  }

  StreamController<T> _controller;
  ValueObservable<T> _stream;

  LiveData() {
    _controller = StreamController<T>();
    _stream = Observable<T>(_controller.stream).shareValue();
  }

  /// Set a new value to keep and notify.
  setValue(T value) {
    _controller.add(value);
  }

  /// Last emitted value, or null if there has been no emission yet
  T getValue() {
    return _stream.value;
  }

  /// Add a stream to use its emitted values.
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
