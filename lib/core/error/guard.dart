import 'dart:developer';

import 'exceptions.dart';
import 'failures.dart';
import 'result.dart';

/// Runs [action] and maps any thrown exception to a typed [Failure].
///
/// This is the single place where data-layer exceptions become domain
/// failures, so repositories don't repeat try/catch blocks.
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on AppException catch (e) {
    return Err(mapExceptionToFailure(e));
  } catch (e, stackTrace) {
    log('Unexpected error', error: e, stackTrace: stackTrace, name: 'guard');
    return const Err(UnexpectedFailure());
  }
}

Failure mapExceptionToFailure(Object error) => switch (error) {
  StorageException(:final message) => StorageFailure(message),
  CacheException(:final message) => CacheFailure(message),
  NotFoundException(:final message) => NotFoundFailure(message),
  AiEngineException(:final message) => AiFailure(message),
  Failure() => error,
  _ => const UnexpectedFailure(),
};
