import 'dart:async';

import 'package:chrome/chrome_ext.dart' as chrome;
import 'package:read_queue/src/constants.dart';
import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_events.dart';
import 'package:read_queue/src/read_queue_store.dart';

Future<Null> main() async {
  final alarm = await chrome.alarms.get('snooze-alarm');
  if (alarm == null) {
    chrome.alarms.create(
        new chrome.AlarmCreateInfo(
          delayInMinutes: intervalMins,
          periodInMinutes: intervalMins,
        ),
        'snooze-alarm');
  }

  final actions = new ReadQueueActions();
  final events = new ReadQueueEvents()
    ..didPopSnoozed.listen((url) async {
      print('[debug] didPopSnoozed -> $url');
      await chrome.tabs
          .create(new chrome.TabsCreateParams(url: url, active: false));
    });
  final store = new ReadQueueStore(actions, events);
  await store.init();

  chrome.alarms.onAlarm.where((a) => a.name == 'snooze-alarm').listen((a) {
    print('[debug] alarm triggered');
    actions.snoozeAlarm();
  });
}
