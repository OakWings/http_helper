import '../http_helper.dart';

/// Represents an HTTP request with various configurations.
/// This class encapsulates the details needed to make an HTTP request including
/// the URL, path, request method, and optional body, query parameters, and headers.
/// It also includes a `converter` function that defines how to convert the response
/// into the desired data type `T`.
class HttpRequest<T> {
  /// The base URL to which the request should be sent.
  final String url;

  /// The specific path within the base URL.
  final String path;

  /// The HTTP method to use for making the request.
  final HttpRequestMethod method;

  /// A function that takes a dynamic response and converts it into a type `T`.
  final T Function(dynamic response) converter;

  /// The HTTP request body, applicable for methods that allow a body (e.g., POST, PUT).
  final String? body;

  /// A map containing query parameters to include in the request.
  final Map<String, dynamic>? queryParameters;

  /// A map containing additional HTTP headers to include in the request.
  final Map<String, String>? headers;

  /// Creates an instance of [HttpRequest] with the given configurations.
  /// - `url`: The base URL for the HTTP request.
  /// - `path`: The path at which the resource resides.
  /// - `requestMethod`: The HTTP method (e.g., GET, POST) to use.
  /// - `converter`: A function to convert the received response into type `T`.
  /// - `body`: (Optional) The request body as a String.
  /// - `queryParameters`: (Optional) A map of query parameters to append to the URL.
  /// - `headers`: (Optional) A map of HTTP headers to include in the request.
  HttpRequest({
    required this.url,
    required this.path,
    required this.method,
    required this.converter,
    this.body,
    this.queryParameters,
    this.headers,
  });
}
