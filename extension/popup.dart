import 'dart:async';
import 'dart:html';

import 'package:chrome/chrome_ext.dart' as chrome;
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react_client.dart' as react_client;

import 'package:read_queue/src/components/queue_controls.dart';
import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_events.dart';
import 'package:read_queue/src/read_queue_store.dart';

Future<Null> main() async {
  var actions = new ReadQueueActions();

  var events = new ReadQueueEvents()
    ..didPeekNext.listen((url) async {
      await chrome.tabs
          .create(new chrome.TabsCreateParams(url: url, active: true));
      window.close();
    })
    ..didPopNext.listen((url) async {
      await chrome.tabs
          .create(new chrome.TabsCreateParams(url: url, active: true));
      window.close();
    })
    ..didPushLater.listen((_url) {
      window.close();
    })
    ..didPushSooner.listen((_url) {
      window.close();
    });

  var store = new ReadQueueStore(actions, events);
  await store.init();

  react_client.setClientConfiguration();
  final container = querySelector('#container');
  react_dom.render(
      (QueueControls()
        ..actions = actions
        ..store = store)(),
      container);
}
