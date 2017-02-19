import 'package:w_flux/w_flux.dart';

class ReadQueueActions {
  final Action<Null> dequeue = new Action<Null>();
  final Action<Null> enqueue = new Action<Null>();
}
