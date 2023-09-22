import 'dart:async';
import 'dart:convert';
import 'package:http_helper/src/generic_response.dart';
import 'package:http_helper/src/http_error.dart';
import 'package:http/http.dart' as http;

/// An enumeration of HTTP request methods.
enum HttpRequestMethod {
  get,
  post,
  put,
  patch,
  delete,
}

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
  ///
  /// onBeforeSend can return an HttpError which will be returned by sendRequest, or null.
  /// If an httpError is returned, the request will not be sent.
  /// This can be used to perform logic before the request is sent, e.g. check if a user is logged in, or if a token is valid, etc. .
  static HttpError? Function()? onBeforeSend;

  /// A callback function that is invoked after an HTTP request has been sent and a response received.
  /// This is typically used for any request operations like logging, analytics, or response transformation.
  /// Note: onAfterSend will not be called when an exception occurs. When an exeption occurs, `onException` will be called instead.
  ///
  /// The `GenericResponse` object that has been received, will be passed automatically.
  static Function(GenericResponse)? onAfterSend;

  /// A callback function that is invoked when an exception occurs during the HTTP request process.
  /// This is useful for centralized error handling, such as logging the exception or showing an error message to the user.
  ///
  /// The callback takes an `Exception` parameter, which contains details about the exception that occurred.
  static Function(Exception)? onException;

  /// A callback function that is invoked when an HTTP request times out.
  /// This is typically used to handle timeout-specific logic, like retrying the request or
  /// showing a timeout error message to the user.
  ///
  /// The callback function takes no parameters, and is invoked when the request exceeds the specified time limit: 'timeoutDurationSeconds'.
  static Function()? onTimeout;

  /// Main function to make an HTTP request and return a `GenericResponse`.
  static Future<GenericResponse<T>> sendRequest<T>(
    String url,
    String path,
    HttpRequestMethod httpRequestMethod,
    T Function(dynamic response) converter, {
    String? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      if (onBeforeSend != null) {
        final httpError = onBeforeSend!.call();

        if (httpError != null) {
          GenericResponse<T>(error: httpError, statusCode: -1);
        }
      }
      // Merge default and custom parameters and headers
      final params = {...defaultParams, ...?queryParameters};
      final header = {...defaultHeaders, ...?headers};

      if (httpRequestMethod == HttpRequestMethod.get) {
        // "Content-Type" is removed for GET requests
        header.remove("Content-Type");
        // Body is not allowed on get requests
        if (body != null) {
          body = null;
          print(
              "http_helper: body not allowed on get requests -> reset body to null. Request was: 'get $url$path'");
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
      final uri = Uri.https(url, path, params.isEmpty ? null : stringParams);

      // Make the HTTP request based on the specified method
      final response = await _httpRequest(httpRequestMethod, uri, header, body);
      return _handleResponse(response, converter); // Handle the HTTP response
    } on Exception catch (e) {
      onException?.call(e); // Call onException if it's not null
      return httpExceptionError<T>(e); // Handle exception during HTTP request
    }
  }

  /// Makes an HTTP request based on the provided method, uri, and headers.
  static Future<http.Response> _httpRequest(
    HttpRequestMethod method,
    Uri uri,
    Map<String, String> headers,
    String? body,
  ) {
    switch (method) {
      // Each HTTP method corresponds to an HTTP request
      case HttpRequestMethod.get:
        return http.get(uri, headers: headers).timeout(
            Duration(seconds: timeoutDurationSeconds),
            onTimeout: httpTimeoutError);
      case HttpRequestMethod.post:
        return http.post(uri, headers: headers, body: body).timeout(
            Duration(seconds: timeoutDurationSeconds),
            onTimeout: httpTimeoutError);
      case HttpRequestMethod.put:
        return http.put(uri, headers: headers, body: body).timeout(
            Duration(seconds: timeoutDurationSeconds),
            onTimeout: httpTimeoutError);
      case HttpRequestMethod.patch:
        return http.patch(uri, headers: headers, body: body).timeout(
            Duration(seconds: timeoutDurationSeconds),
            onTimeout: httpTimeoutError);
      case HttpRequestMethod.delete:
        return http.delete(uri, headers: headers, body: body).timeout(
            Duration(seconds: timeoutDurationSeconds),
            onTimeout: httpTimeoutError);
    }
  }

  /// Handles the HTTP response and converts it into a `GenericResponse`. Default encoding is UTF-8, this cannot be changed.
  static GenericResponse<T> _handleResponse<T>(
      http.Response response, T Function(dynamic response) converter) {
    String body = "";

    try {
      body = const Utf8Decoder().convert(response.bodyBytes);
    } on Exception catch (e) {
      print(body);
      return httpExceptionError<T>(e);
    }

    // If status code is in 200 range, the request is considered to be successful
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Handle successful HTTP response
        dynamic nullableJson;
        nullableJson = jsonDecode(body);
        final genResponse = GenericResponse(
          data: converter(nullableJson),
          statusCode: response.statusCode,
        );

        onAfterSend?.call(genResponse); // Call onAfterSend if it's not null

        return genResponse;
      } on Exception catch (e) {
        print(body);
        return httpExceptionError<T>(e);
      }
    } else {
      // Handle non-successful HTTP response
      var message = response.bodyBytes.isEmpty
          ? "No error message provided"
          : jsonDecode(body);
      final genResponse = GenericResponse<T>(
        // If status code is 999, it means there was a timeout
        error: response.statusCode == 999
            ? HttpError(message: "Timeout Error")
            : HttpError.fromJson(message),
        statusCode: response.statusCode,
      );

      onAfterSend?.call(genResponse); // Call onAfterSend if it's not null

      if (genResponse.error!.message == null) {
        genResponse.error!.message = "No error message provided";
      }
      return genResponse;
    }
  }

  /// Handles the HTTP timeout error by returning a `Response` with a custom status code.
  static FutureOr<http.Response> httpTimeoutError() {
    onTimeout?.call(); // Call onTimeout if it's not null
    return http.Response("", 999); // Return custom response for timeout
  }

  /// Handles a caught exception during HTTP request by returning a `GenericResponse` with an `HttpError`.
  static GenericResponse<T> httpExceptionError<T>(Exception e) {
    // Return a GenericResponse with an HttpError containing the exception message
    return GenericResponse<T>(
        error: HttpError(message: "Http exception:\n${e.toString()}"),
        statusCode: -1);
  }
}
