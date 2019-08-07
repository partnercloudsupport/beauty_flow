import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// It is a stream object and can keep the last state. Also can have more than one subscription.
class LiveData<T> extends Stream<T> {
  /// Invoke listener only if values are unique and not nullable
  static observePair<T1, T2>(
      LiveData<T1> t1, LiveData<T2> t2, Function(T1 t1, T2 t2) listener) {
    T1 value1;
    T2 value2;
    t1.listen((it) {
      if (value1 != it) {
        value1 = it;
        if (value1 != null && value2 != null) {
          listener(value1, value2);
        }
      }
    });
    t2.listen((it) {
      if (value2 != it) {
        value2 = it;
        if (value1 != null && value2 != null) {
          listener(value1, value2);
        }
      }
    });
  }

  /// Invoke listener only if values are unique and not nullable
  static observeTriple<T1, T2, T3>(LiveData<T1> t1, LiveData<T2> t2,
      LiveData<T3> t3, Function(T1 t1, T2 t2, T3 t3) listener) {
    T1 value1;
    T2 value2;
    T3 value3;
    t1.listen((it) {
      if (value1 != it) {
        value1 = it;
        if (value1 != null && value2 != null && value3 != null) {
          listener(value1, value2, value3);
        }
      }
    });
    t2.listen((it) {
      if (value2 != it) {
        value2 = it;
        if (value1 != null && value2 != null && value3 != null) {
          listener(value1, value2, value3);
        }
      }
    });
    t3.listen((it) {
      if (value3 != it) {
        value3 = it;
        if (value1 != null && value2 != null && value3 != null) {
          listener(value1, value2, value3);
        }
      }
    });
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
