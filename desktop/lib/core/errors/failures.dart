abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local Database Error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet Connection']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
