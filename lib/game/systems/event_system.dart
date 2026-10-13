/// Generic decoupled event bus for VAYAL gameplay events.
class GameEvent {
  final DateTime timestamp = DateTime.now();
}

class MoneyChangedEvent extends GameEvent {
  final int newAmount;
  final int delta;
  MoneyChangedEvent(this.newAmount, this.delta);
}

class ReputationChangedEvent extends GameEvent {
  final int newAmount;
  final int delta;
  ReputationChangedEvent(this.newAmount, this.delta);
}

class ItemAcquiredEvent extends GameEvent {
  final String itemId;
  final int quantity;
  ItemAcquiredEvent(this.itemId, this.quantity);
}

class CheckpointSavedEvent extends GameEvent {
  final String checkpointName;
  CheckpointSavedEvent(this.checkpointName);
}

class EventSystem {
  final Map<Type, List<void Function(dynamic)>> _listeners = {};

  void on<T extends GameEvent>(void Function(T) callback) {
    _listeners.putIfAbsent(T, () => []).add((e) => callback(e as T));
  }

  void off<T extends GameEvent>(void Function(T) callback) {
    _listeners[T]?.remove(callback);
  }

  void emit<T extends GameEvent>(T event) {
    final list = _listeners[T];
    if (list != null) {
      for (final listener in List.of(list)) {
        listener(event);
      }
    }
  }

  void clear() {
    _listeners.clear();
  }
}
