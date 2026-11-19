sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('Unable to connect. Check your connection.');
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('The request timed out. Please try again.');
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Your session has expired.');
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure()
    : super('You do not have permission to perform this action.');
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('The requested resource was not found.');
}

final class ServerFailure extends Failure {
  const ServerFailure() : super('The server could not complete the request.');
}

final class RequestFailure extends Failure {
  const RequestFailure() : super('The request could not be completed.');
}

final class RequestCancelledFailure extends Failure {
  const RequestCancelledFailure() : super('The request was cancelled.');
}

final class StorageFailure extends Failure {
  const StorageFailure() : super('Local storage is unavailable.');
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('An unexpected error occurred.');
}
