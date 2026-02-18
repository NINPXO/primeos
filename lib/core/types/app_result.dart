sealed class AppResult<T> {
  const AppResult();
}

final class AppSuccess<T> extends AppResult<T> {
  final T data;
  const AppSuccess(this.data);
}

final class AppError<T> extends AppResult<T> {
  final Failure failure;
  const AppError(this.failure);
}

sealed class Failure {
  const Failure();
}

final class DatabaseFailure extends Failure {
  final String message;
  const DatabaseFailure(this.message);
}

final class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure(this.message);
}
