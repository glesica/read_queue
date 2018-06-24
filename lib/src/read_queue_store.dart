import 'dart:async';

import 'package:chrome/chrome_ext.dart' as chrome;
import 'package:w_flux/w_flux.dart';

import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_events.dart';

class ReadQueueStore extends Store {
  ReadQueueEvents _events;
  List<String> _currentQueue = [];

  ReadQueueStore(ReadQueueActions actions, this._events) {
    actions
      ..peekNext.listen(_handlePeekNext)
      ..popNext.listen(_handlePopNext)
      ..pushLater.listen(_handlePushLater)
      ..pushSooner.listen(_handlePushSooner);
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

  /// Load the queue from storage.
  Future<Null> _loadQueue() async {
    var json = await chrome.storage.sync.get({'queue': []});
    _currentQueue = json['queue'].toList();
  }

  /// Persist the current version of the store queue to storage.
  Future<Null> _saveQueue() async {
    await chrome.storage.sync.set({'queue': _currentQueue});
  }
}
