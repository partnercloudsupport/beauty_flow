import 'dart:async';

/// It is a stream object without keeping last data.
/// Also can have more than one subscription.
class SingleLivedEvent<T> extends Stream<T> {
  StreamController<T> _controller;
  Stream<T> _stream;

  SingleLivedEvent() {
    _controller = StreamController.broadcast();
    _stream = _controller.stream;
  }

  /// Set a new value to keep and notify.
  sentValue(T value) {
    _controller.add(value);
  }

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
