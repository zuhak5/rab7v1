sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.message, {this.code, this.error, this.stackTrace});

  final String message;
  final String? code;
  final Object? error;
  final StackTrace? stackTrace;
}
