import 'dart:async';

import 'package:chrome/chrome_ext.dart' as chrome;
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
    final alarmTime = new DateTime.now().add(new Duration(days: 1));
    final url = await _getCurrentUrl();
    final page = new SnoozedPage(alarmTime: alarmTime, url: url);
    await _loadSnoozeQueue();
    _currentSnoozeQueue.add(page);
    await _saveSnoozeQueue();
    _events.dispatchDidTriggerSnooze(url);
  }

  Future<Null> _handleSnoozeAlarm(_) async {
    await _loadSnoozeQueue();
    if (_currentSnoozeQueue.isEmpty) {
      return;
    }
    final now = new DateTime.now();
    while (_currentSnoozeQueue.isNotEmpty &&
        _currentSnoozeQueue.first.alarmTime.isBefore(now)) {
      final page = _currentSnoozeQueue.removeAt(0);
      _events.dispatchDidPopSnoozed(page.url);
    }
    await _saveSnoozeQueue();
  }

  /// Load the queue from storage.
  Future<Null> _loadQueue() async {
    var json = await chrome.storage.sync.get({'queue': []});
    _currentQueue = json['queue'].toList();
  }

  Future<Null> _loadSnoozeQueue() async {
    final json = await chrome.storage.sync.get({'snooze-queue': []});
    _currentSnoozeQueue = json['snooze-queue']
        .toList()
        .map((m) => new SnoozedPage.fromMap(m))
        .toList();
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
  }
}
