import 'package:w_flux/w_flux.dart';

class ReadQueueActions {
  final Action<Null> peekNext = new Action<Null>();
  final Action<Null> popNext = new Action<Null>();
  final Action<Null> pushLater = new Action<Null>();
  final Action<Null> pushSooner = new Action<Null>();
  final Action<Null> snooze = new Action<Null>();
  final Action<Null> snoozeAlarm = new Action<Null>();
}
