import 'failures.dart';

/// Lightweight Either: every repository/use case returns a [Result] instead of
/// throwing, so callers are forced to handle the failure path.
sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) =>
      switch (this) {
        Ok<T>(:final data) => onSuccess(data),
        Err<T>(:final failure) => onFailure(failure),
      };

  bool get isOk => this is Ok<T>;

  T? get dataOrNull => switch (this) {
    Ok<T>(:final data) => data,
    Err<T>() => null,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);

  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
