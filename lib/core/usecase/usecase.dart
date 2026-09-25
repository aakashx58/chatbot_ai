import 'package:equatable/equatable.dart';

import '../error/result.dart';

/// A single application action. Presentation depends on these, never on
/// repositories directly.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// A use case that emits a sequence of values (e.g. a streamed AI reply).
abstract interface class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
