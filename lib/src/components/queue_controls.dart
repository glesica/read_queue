import 'package:over_react/over_react.dart';

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
          ..className = 'button enqueue-button'
          ..onClick = (_) async {
            await props.actions.enqueue(null);
          })('Enqueue'),
        (Dom.div()
          ..className = 'button dequeue-button'
          ..onClick = (_) async {
            await props.actions.dequeue(null);
          })('Dequeue (${props.store.currentQueue.length})'));
  }
}
