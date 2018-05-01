import 'dart:async';

class ReadQueueEvents {
  final StreamController<String> _didDequeueUrl =
      new StreamController<String>.broadcast();
  final StreamController<String> _didEnqueueUrl =
      new StreamController<String>.broadcast();
  final StreamController<String> _didPeekUrl =
      new StreamController<String>.broadcast();

  Stream<String> get didDequeueUrl => _didDequeueUrl.stream;

  Stream<String> get didEnqueueUrl => _didEnqueueUrl.stream;

  Stream<String> get didPeekUrl => _didPeekUrl.stream;

  void dispatchDidDequeueUrl(String url) => _didDequeueUrl.add(url);

  void dispatchDidEnqueueUrl(String url) => _didEnqueueUrl.add(url);

  void dispatchDidPeekUrl(String url) => _didPeekUrl.add(url);
}
