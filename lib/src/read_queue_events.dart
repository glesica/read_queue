import 'dart:async';

class ReadQueueEvents {
  final StreamController<String> _didPeekNext =
      new StreamController<String>.broadcast();
  final StreamController<String> _didPopNext =
      new StreamController<String>.broadcast();
  final StreamController<String> _didPushLater =
      new StreamController<String>.broadcast();
  final StreamController<String> _didPushSooner =
      new StreamController<String>.broadcast();
  final StreamController<String> _didTriggerSnooze =
      new StreamController<String>.broadcast();

  Stream<String> get didPeekNext => _didPeekNext.stream;

  Stream<String> get didPopNext => _didPopNext.stream;

  Stream<String> get didPushLater => _didPushLater.stream;

  Stream<String> get didPushSooner => _didPushSooner.stream;

  Stream<String> get didTriggerSnooze => _didTriggerSnooze.stream;

  void dispatchDidPeekNext(String url) => _didPeekNext.add(url);

  void dispatchDidPopNext(String url) => _didPopNext.add(url);

  void dispatchDidPushLater(String url) => _didPushLater.add(url);

  void dispatchDidPushSooner(String url) => _didPushSooner.add(url);

  void dispatchDidTriggerSnooze(String url) => _didTriggerSnooze.add(url);
}
