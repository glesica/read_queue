import 'dart:async';

import 'package:chrome/chrome_ext.dart' as chrome;
import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_events.dart';
import 'package:read_queue/src/read_queue_store.dart';

const int intervalMinutes = 5;

Future<Null> main() async {
  final now = new DateTime.now();
  final minute = now.minute;
  final seconds = now.second;
  final untilNext =
      intervalMinutes - (minute % intervalMinutes) - (seconds / 60);

  // Just allow this to re-register and overwrite every time, but
  // set it so it triggers roughly at a steady interval to prevent
  // weird drift as the extension is loaded and unloaded.
  chrome.alarms.create(
      new chrome.AlarmCreateInfo(
        delayInMinutes: untilNext,
        periodInMinutes: intervalMinutes,
      ),
      'snooze-alarm');

  final actions = new ReadQueueActions();
  final events = new ReadQueueEvents()
    ..didPopSnoozed.listen((url) async {
      await chrome.tabs
          .create(new chrome.TabsCreateParams(url: url, active: false));
    });
  final store = new ReadQueueStore(actions, events);
  await store.init();

  chrome.alarms.onAlarm.where((a) => a.name == 'snooze-alarm').listen((a) {
    actions.snoozeAlarm();
  });
}
