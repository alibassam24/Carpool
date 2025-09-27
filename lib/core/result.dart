// lib/core/result.dart

/// Generic wrapper for success or failure outcomes.
class Result<T> {
  final T? _value;
  final AppFailure? _failure;

  const Result._(this._value, this._failure);

  /// ✅ Success
  factory Result.ok(T value) => Result._(value, null);

  /// ❌ Failure
  factory Result.err(AppFailure failure) => Result._(null, failure);

  bool get isOk => _failure == null;
  bool get isErr => _failure != null;

  T unwrap() {
    if (isErr) throw Exception("Tried to unwrap an error: $_failure");
    return _value as T;
  }

  AppFailure unwrapErr() {
    if (isOk) throw Exception("Tried to unwrap a success: $_value");
    return _failure!;
  }


  T unwrapOr(T fallback) => isOk ? _value as T : fallback;
  R when<R>({
    required R Function(T value) ok,
    required R Function(AppFailure failure) err,
  }) {
    if (isOk) return ok(_value as T);
    return err(_failure!);
  }
}

/// Represents an error with a code + message (for debugging & UI).
class AppFailure {
  final String code;    // e.g., "fetch_failed"
  final String message; // e.g., "Could not fetch rides"

  AppFailure(this.code, this.message);

  @override
  String toString() => "$code: $message";
}
