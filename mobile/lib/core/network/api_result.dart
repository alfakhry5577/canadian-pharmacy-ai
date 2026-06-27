import 'package:equatable/equatable.dart';

/// A minimal Result type so repositories never throw across layers —
/// UI code always pattern-matches on success/failure explicitly.
sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Error<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is Success<T>;
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ApiResult<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Describes why a call failed, in a UI-friendly shape.
class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final FailureType type;

  const Failure({required this.message, this.statusCode, this.type = FailureType.unknown});

  factory Failure.network() => const Failure(
        message: 'لا يوجد اتصال بالإنترنت',
        type: FailureType.network,
      );

  factory Failure.unauthorized() => const Failure(
        message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجددًا',
        statusCode: 401,
        type: FailureType.unauthorized,
      );

  factory Failure.server(String message, [int? statusCode]) =>
      Failure(message: message, statusCode: statusCode, type: FailureType.server);

  @override
  List<Object?> get props => [message, statusCode, type];
}

enum FailureType { network, unauthorized, server, validation, unknown }
