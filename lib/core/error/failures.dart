import 'package:equatable/equatable.dart';

/// Domain-level error returned inside a [Result]. UI code only ever sees these.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Could not access local storage.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read or save preferences.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

final class AiFailure extends Failure {
  const AiFailure([super.message = 'The assistant could not reply.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
