/// Exceptions thrown by the data layer. Repositories convert them into
/// [Failure]s (see `guard`) so they never leak into the domain/presentation.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

final class AiEngineException extends AppException {
  const AiEngineException(super.message);
}
