import 'http_error.dart';

/// A generic class used for HTTP responses.
///
/// This class represents a generic response model for HTTP requests.
/// It wraps the response data and provides additional information
/// like the status code and any possible errors.
///
/// The class is generic, which allows for flexibility in the type of
/// the `data` field. This can be any type that is expected as the
/// response of the HTTP request.
///
/// The `statusCode` represents the HTTP status code of the response.
/// The `data` is the response body of successful requests, and `error`
/// contains error information for unsuccessful requests.
class GenericResponse<T> {
  /// Indicates if the request was successful.
  ///
  /// A request is considered successful if `data` is not null and `error` is null.
  bool get isSuccess => data != null && error == null;

  /// The HTTP status code of the response.
  final int statusCode;

  /// The data received in the response.
  ///
  /// This will be null if the request was unsuccessful.
  T? data;

  /// An `HttpError` that represents an error that occurred during the request.
  ///
  /// This will be null if the request was successful.
  HttpError? error;

  /// Creates a new instance of a generic HTTP response.
  ///
  /// The `statusCode` is required, while `data` and `error` are optional.
  GenericResponse({
    this.data,
    this.error,
    required this.statusCode,
  });
}
