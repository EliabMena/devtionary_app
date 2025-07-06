import 'package:firebase_auth/firebase_auth.dart';

/// Resultado genérico para operaciones de servicios
class ServiceResult<T> {
  final bool success;
  final String? error;
  final T? data;
  final User? user;

  ServiceResult({
    required this.success,
    this.error,
    this.data,
    this.user,
  });

  factory ServiceResult.success(T data, {User? user}) {
    return ServiceResult(
      success: true,
      data: data,
      user: user,
    );
  }

  factory ServiceResult.error(String error) {
    return ServiceResult(
      success: false,
      error: error,
    );
  }
}
