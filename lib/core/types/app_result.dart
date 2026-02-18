sealed class AppResult<T> {
  const AppResult();

  factory AppResult.success(T data) => AppSuccess(data);
  factory AppResult.failure(Failure failure) => AppError(failure);

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      AppSuccess<T>(data: final data) => onSuccess(data),
      AppError<T>(failure: final failure) => onFailure(failure),
    };
  }
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

final class NotFoundFailure extends Failure {
  final String message;
  const NotFoundFailure({required this.message});
}
