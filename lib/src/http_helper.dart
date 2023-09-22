import 'dart:async';
import 'dart:convert';
import 'package:http_helper/src/generic_response.dart';
import 'package:http_helper/src/http_error.dart';
import 'package:http/http.dart' as http;
import 'package:http_helper/src/http_request.dart';
import 'package:http_helper/src/http_request_method.dart';

const _httpTimeoutErrorCode = 999;

class HttpHelper {
  /// Default timeout duration in seconds for HTTP requests.
  static int timeoutDurationSeconds = 10;

  /// Default headers for HTTP requests.
  /// Default is: {"Content-Type": "application/json;charset=UTF-8", "Accept": "application/json"}
  static Map<String, String> defaultHeaders = {
    "Content-Type": "application/json;charset=UTF-8",
    "Accept": "application/json"
  };

  /// A map containing default query parameters that are included in every HTTP request.
  static Map<String, dynamic> defaultParams = {};

  /// A callback function that is invoked immediately before sending the HTTP request.
  /// This can be used to log details, or execute any pre-send logic.
  /// onBeforeSend can return an HttpError which will be returned by sendRequest, or null.
  /// If an httpError is returned, the request will not be sent.
  /// This can be used to perform logic before the request is sent, e.g. check if a user is logged in, or if a token is valid, etc. .
  static HttpError? Function(HttpRequest)? onBeforeSend;

  /// A callback function that is invoked after an HTTP request has been sent and a response received.
  /// This is typically used for any request operations like logging, analytics, or response transformation.
  /// Note: onAfterSend will not be called when an exception occurs. When an exeption occurs, `onException` will be called instead.
  /// The `GenericResponse` object that has been received, will be passed automatically.
  static Function(HttpRequest, GenericResponse)? onAfterSend;

  /// A callback function that is invoked when an exception occurs during the HTTP request process.
  /// This is useful for centralized error handling, such as logging the exception or showing an error message to the user.
  /// The callback takes an `Exception` parameter, which contains details about the exception that occurred.
  static Function(HttpRequest, Exception)? onException;

  /// A callback function that is invoked when an error occurs during the HTTP request process.
  /// This is useful for centralized error handling, such as logging the error or showing an error message to the user.
  /// The callback takes an `Error` parameter, which contains details about the error that occurred.
  static Function(HttpRequest, Error)? onError;

  /// A callback function that is invoked when an HTTP request times out.
  /// This is typically used to handle timeout-specific logic, like retrying the request or
  /// showing a timeout error message to the user.
  /// The callback function takes no parameters, and is invoked when the request exceeds the specified time limit: 'timeoutDurationSeconds'.
  static Function(HttpRequest)? onTimeout;

  /// Sends an HTTP request and returns a response wrapped in a `GenericResponse` object.
  /// This method allows you to make HTTP requests with different request methods, headers, query parameters, and body content.
  /// It internally handles the preparation of the HTTP request, merging default parameters and headers with provided custom ones,
  /// and sending the request to the specified URL.
  /// ### Type Parameters
  /// - `T`: The type of the data that you expect in the response.
  /// ### Parameters
  /// - `url`: The base URL to which the request should be sent.
  /// - `path`: The specific path within the base URL.
  /// - `httpRequestMethod`: The HTTP method to use for making the request.
  /// - `converter`: A function that takes a dynamic response and converts it into a type `T`.
  /// ### Optional Named Parameters
  /// - `body`: The HTTP request body, applicable for methods that allow a body (e.g., POST, PUT).
  /// - `queryParameters`: A map containing query parameters to include in the request.
  /// - `headers`: A map containing additional HTTP headers to include in the request.
  /// ### Returns
  /// A `Future<GenericResponse<T>>` containing the response data or error details.
  static Future<GenericResponse<T>> sendRequest<T>(
    HttpRequest<T> request,
  ) async {
    try {
      if (onBeforeSend != null) {
        final httpError = onBeforeSend!.call(request);

        if (httpError != null) {
          GenericResponse<T>(error: httpError, statusCode: -1);
        }
      }
      // Merge default and custom parameters and headers
      final params = {...defaultParams, ...?request.queryParameters};
      final header = {...defaultHeaders, ...?request.headers};

      if (request.method == HttpRequestMethod.get) {
        // "Content-Type" is removed for GET requests
        header.remove("Content-Type");
        // Body is not allowed on get requests
        if (request.body != null) {
          print(
              "http_helper: body not allowed on get requests -> reset body to null. Request was: 'get ${request.url}${request.path}'");
        }
      }

      // Convert all values in params to String because in Dart,
      // the Uri.https method expects the query parameters to be a Map<String, dynamic>,
      // where the dynamic type can be String or Iterable<String>.
      // If you provide a value that is not a String or Iterable<String>, you will get a TypeError.
      final stringParams = params.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      // Construct the URI for the request
      final uri = Uri.https(
          request.url, request.path, params.isEmpty ? null : stringParams);

      // Make the HTTP request based on the specified method
      final response = await _httpRequest(uri, request);
      // Handle the HTTP response
      return _handleResponse(request, response, request.converter);
    } on Exception catch (e) {
      onException?.call(request, e);
      return _httpException<T>(request, e);
    } on Error catch (e) {
      onError?.call(request, e);
      return _httpError<T>(request, e);
    }
  }

  // Makes an HTTP request based on the provided method, uri, and headers.
  static Future<http.Response> _httpRequest(
    Uri uri,
    HttpRequest request,
  ) {
    switch (request.method) {
      // Each HTTP method corresponds to an HTTP request
      case HttpRequestMethod.get:
        return http.get(uri, headers: request.headers).timeout(
              Duration(seconds: timeoutDurationSeconds),
              onTimeout: () => _httpTimeoutError(request),
            );
      case HttpRequestMethod.post:
        return http
            .post(uri, headers: request.headers, body: request.body)
            .timeout(
              Duration(seconds: timeoutDurationSeconds),
              onTimeout: () => _httpTimeoutError(request),
            );
      case HttpRequestMethod.put:
        return http
            .put(uri, headers: request.headers, body: request.body)
            .timeout(
              Duration(seconds: timeoutDurationSeconds),
              onTimeout: () => _httpTimeoutError(request),
            );
      case HttpRequestMethod.patch:
        return http
            .patch(uri, headers: request.headers, body: request.body)
            .timeout(
              Duration(seconds: timeoutDurationSeconds),
              onTimeout: () => _httpTimeoutError(request),
            );
      case HttpRequestMethod.delete:
        return http
            .delete(uri, headers: request.headers, body: request.body)
            .timeout(
              Duration(seconds: timeoutDurationSeconds),
              onTimeout: () => _httpTimeoutError(request),
            );
    }
  }

  // Handles the HTTP response and converts it into a `GenericResponse`. Default encoding is UTF-8, this cannot be changed.
  static GenericResponse<T> _handleResponse<T>(
    HttpRequest<T> request,
    http.Response response,
    T Function(dynamic response) converter,
  ) {
    String body = "";

    try {
      body = const Utf8Decoder().convert(response.bodyBytes);
    } on Exception catch (e) {
      onException?.call(request, e);
      return _httpException<T>(request, e);
    } on Error catch (e) {
      onError?.call(request, e);
      return _httpError<T>(request, e);
    }

    // If status code is in 200 range, the request is considered to be successful
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Handle successful HTTP response
        dynamic nullableJson;
        nullableJson = jsonDecode(body);
        final data = converter(nullableJson);
        final genResponse = GenericResponse(
          data: data,
          statusCode: response.statusCode,
        );

        onAfterSend?.call(request, genResponse);

        return genResponse;
      } on Exception catch (e) {
        onException?.call(request, e);
        return _httpException<T>(request, e);
      } on Error catch (e) {
        onError?.call(request, e);
        return _httpError<T>(request, e);
      }
    } else {
      // Handle non-successful HTTP response
      var message = response.bodyBytes.isEmpty
          ? "No error message provided"
          : jsonDecode(body);
      final genResponse = GenericResponse<T>(
        error: response.statusCode == _httpTimeoutErrorCode
            ? HttpError(message: "Timeout Error")
            : HttpError.fromJson(message),
        statusCode: response.statusCode,
      );

      onAfterSend?.call(request, genResponse);

      if (genResponse.error!.message == null) {
        genResponse.error!.message = "No error message provided";
      }
      return genResponse;
    }
  }

  // Handles the HTTP timeout error by returning a `Response` with a custom status code.
  static FutureOr<http.Response> _httpTimeoutError(HttpRequest request) {
    onTimeout?.call(request); // Call onTimeout if it's not null
    return http.Response(
        "", _httpTimeoutErrorCode); // Return custom response for timeout
  }

  // Handles a caught exception during HTTP request by returning a `GenericResponse` with an `HttpError`.
  static GenericResponse<T> _httpException<T>(
      HttpRequest request, Exception e) {
    // Return a GenericResponse with an HttpError containing the exception message
    return GenericResponse<T>(
      error: HttpError(
        message: _constuctHttpErrorMessage(request, e.toString(), "exception"),
      ),
      statusCode: -1,
    );
  }

  // Handles a caught error during HTTP request by returning a `GenericResponse` with an `HttpError`.
  static GenericResponse<T> _httpError<T>(HttpRequest request, Error e) {
    // Return a GenericResponse with an HttpError containing the error message
    return GenericResponse<T>(
      error: HttpError(
        message: _constuctHttpErrorMessage(request, e.toString(), "error"),
      ),
      statusCode: -1,
    );
  }

  static String _constuctHttpErrorMessage(
      HttpRequest request, String message, String typeString) {
    return """
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
HTTP ${typeString.toUpperCase()}:
             url:\t${request.method.name.toUpperCase()} ${request.url}${request.path}:
       exception:\t$message
         headers:\t${request.headers}
query parameters:\t${request.queryParameters}
            body:\t${request.body}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n""";
  }
}
