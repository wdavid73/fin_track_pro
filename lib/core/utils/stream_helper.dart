import 'dart:async';

/// Provides a convenient way to wait for a specific state in a [Stream].
///
/// Adds a `waitForState` method to asynchronously listen to a `Stream<T>`
/// and complete when a given condition is met.
Future<void> waitForState<T>({
  /// The stream to listen to for state changes.
  ///
  /// This should typically be a `Bloc.stream` or any other reactive state stream.
  required Stream<T> stream,

  /// The condition to determine when the waiting should complete.
  ///
  /// This function receives the emitted state and returns `true` when the
  /// desired state is reached.
  required bool Function(T state) condition,
}) async {
  final completer = Completer<void>();

  final subscription = stream.listen((state) {
    if (condition(state) && !completer.isCompleted) {
      completer.complete();
    }
  });

  await completer.future;
  await subscription.cancel();
}
