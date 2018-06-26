import 'dart:async';

import 'package:chrome/chrome_ext.dart' as chrome;
import 'package:read_queue/src/constants.dart';
import 'package:read_queue/src/models/snoozed_page.dart';
import 'package:w_flux/w_flux.dart';

import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_events.dart';

class ReadQueueStore extends Store {
  ReadQueueEvents _events;
  List<String> _currentQueue = [];
  List<SnoozedPage> _currentSnoozeQueue = [];

  ReadQueueStore(ReadQueueActions actions, this._events) {
    actions
      ..peekNext.listen(_handlePeekNext)
      ..popNext.listen(_handlePopNext)
      ..pushLater.listen(_handlePushLater)
      ..pushSooner.listen(_handlePushSooner)
      ..snooze.listen(_handleSnooze)
      ..snoozeAlarm.listen(_handleSnoozeAlarm);
    chrome.storage.onChanged.listen((_) async {
      await _loadQueue();
      trigger();
    });
  }

  Future<Null> init() async {
    await _loadQueue();
  }

  Iterable<String> get currentQueue => _currentQueue;

  /// Get the URL of the currently active / selected tab.
  Future<String> _getCurrentUrl() async {
    final activeTabs =
        await chrome.tabs.query(new chrome.TabsQueryParams()..active = true);
    return activeTabs.first.url;
  }

  Future<Null> _handlePeekNext(_) async {
    await _loadQueue();
    if (_currentQueue.isEmpty) {
      return;
    }
    var url = _currentQueue.first;
    _events.dispatchDidPeekNext(url);
  }

  Future<Null> _handlePopNext(_) async {
    await _loadQueue();
    if (_currentQueue.isEmpty) {
      // TODO: Show an error or something?
      return;
    }
    var url = _currentQueue.removeAt(0);
    await _saveQueue();
    _events.dispatchDidPopNext(url);
  }

  Future<Null> _handlePushLater(_) async {
    var url = await _getCurrentUrl();
    await _loadQueue();
    _currentQueue.add(url);
    await _saveQueue();
    _events.dispatchDidPushLater(url);
  }

  Future<Null> _handlePushSooner(_) async {
    var url = await _getCurrentUrl();
    await _loadQueue();
    _currentQueue.insert(0, url);
    await _saveQueue();
    _events.dispatchDidPushSooner(url);
  }

  Future<Null> _handleSnooze(_) async {
    final page = new SnoozedPage(
        epochMs: new DateTime.now().millisecondsSinceEpoch + hourMs,
        url: await _getCurrentUrl());
    print(
        '[debug] _handleSnooze: {"epochMs": "${page.epochMs}", "url": "${page.url}"}');
    await _loadSnoozeQueue();
    _currentSnoozeQueue.add(page);
    await _saveSnoozeQueue();
    _events.dispatchDidTriggerSnooze(page.url);
  }

  Future<Null> _handleSnoozeAlarm(_) async {
    print('[debug] _handleSnoozeAlarm');
    await _loadSnoozeQueue();
    if (_currentSnoozeQueue.isEmpty) {
      print('[debug] _handleSnoozeAlarm -> _currentSnoozeQueue.isEmpty');
      return;
    }
    final now = new DateTime.now();
    print('[debug] current epoch -> ${now.millisecondsSinceEpoch}');
    _currentSnoozeQueue
        .where((p) => p.epochMs <= now.millisecondsSinceEpoch)
        .toList()
        .forEach((p) {
      _currentSnoozeQueue.remove(p);
      _events.dispatchDidPopSnoozed(p.url);
    });
    await _saveSnoozeQueue();
  }

  /// Load the queue from storage.
  Future<Null> _loadQueue() async {
    var dataMap = await chrome.storage.sync.get({'queue': []});
    _currentQueue = dataMap['queue'].toList();
  }

  Future<Null> _loadSnoozeQueue() async {
    final dataMap = await chrome.storage.sync.get({'snooze-queue': []});
    _currentSnoozeQueue = dataMap['snooze-queue']
        .toList()
        .map((m) => new SnoozedPage.fromMap(m))
        .toList();
    print('[debug] _loadSnoozeQueue -> $_currentSnoozeQueue');
  }

  /// Persist the current version of the store queue to storage.
  Future<Null> _saveQueue() async {
    await chrome.storage.sync.set({
      'queue': _currentQueue,
    });
  }

  Future<Null> _saveSnoozeQueue() async {
    await chrome.storage.sync.set({
      'snooze-queue': _currentSnoozeQueue.map((p) => p.toMap()).toList(),
    });
    print('[debug] _saveSnoozeQueue -> $_currentSnoozeQueue');
  }
}
