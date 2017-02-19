import 'dart:async';

import 'package:chrome/chrome_ext.dart' as chrome;
import 'package:w_flux/w_flux.dart';

import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_events.dart';

class ReadQueueStore extends Store {
  ReadQueueEvents _events;
  List<String> _currentQueue = [];

  ReadQueueStore(ReadQueueActions actions, this._events) {
    actions..dequeue.listen(_handleDequeue)..enqueue.listen(_handleEnqueue);
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
    var tab = await chrome.tabs.getSelected();
    return tab.url;
  }

  Future<Null> _handleDequeue(_) async {
    await _loadQueue();
    if (_currentQueue.isEmpty) {
      // TODO: Show an error or something?
      return;
    }
    var url = _currentQueue.removeAt(0);
    await _saveQueue();
    _events.dispatchDidDequeueUrl(url);
  }

  Future<Null> _handleEnqueue(_) async {
    var url = await _getCurrentUrl();
    await _loadQueue();
    _currentQueue.add(url);
    await _saveQueue();
    _events.dispatchDidEnqueueUrl(url);
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
