// lib/core/result.dart
class AppFailure {
  final String code;
  final String message;
  AppFailure(this.code, this.message);
}
class Result<T> {
  final T? data;
  final AppFailure? error;
  const Result._(this.data, this.error);
  factory Result.ok(T data) => Result._(data, null);
  factory Result.err(AppFailure e) => Result._(null, e);

  void when({required void Function(T data) ok, required void Function(AppFailure e) err}) {
    if (data != null) ok(data as T); else err(error!);
  }
}
