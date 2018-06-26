import 'dart:async';
import 'package:over_react/over_react.dart';
import 'package:react/react.dart' show SyntheticMouseEvent;

import 'package:read_queue/src/read_queue_actions.dart';
import 'package:read_queue/src/read_queue_store.dart';

@Factory()
UiFactory<QueueControlsProps> QueueControls;

@Props()
class QueueControlsProps extends FluxUiProps<ReadQueueActions, ReadQueueStore> {
}

@Component()
class QueueControlsComponent extends FluxUiComponent<QueueControlsProps> {
  @override
  dynamic render() {
    return (Dom.div()..id = 'queue-controls')(
      (Dom.div()
        ..className = 'button sooner-button'
        ..onClick = (_) async {
          await props.actions.pushSooner(null);
        })('Sooner'),
      (Dom.div()
        ..className = 'button later-button'
        ..onClick = (_) async {
          await props.actions.pushLater(null);
        })('Later'),
      (Dom.div()
            ..className = 'button now-button'
            ..onClick = _handleNowButtonClick
            ..onContextMenu = _handleNowButtonContextClick)(
          'Now (${props.store.currentQueue.length})'),
      (Dom.div()
        ..className = 'button snooze-button'
        ..onClick = _handleSnoozeButtonClick)('Snooze for 24 hours'),
    );
  }

  Future<Null> _handleNowButtonClick(SyntheticMouseEvent e) async {
    if (props.store.currentQueue.isEmpty) {
      return;
    }
    await props.actions.popNext(null);
  }

  Future<Null> _handleNowButtonContextClick(SyntheticMouseEvent e) async {
    if (props.store.currentQueue.isEmpty) {
      return;
    }
    e.stopPropagation();
    e.preventDefault();
    await props.actions.peekNext(null);
  }

  Future<Null> _handleSnoozeButtonClick(SyntheticMouseEvent e) async {
    await props.actions.snooze();
  }
}
