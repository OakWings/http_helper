import 'dart:async';
import 'dart:convert';
import 'package:http_helper/src/generic_response.dart';
import 'package:http_helper/src/http_error.dart';
import 'package:http/http.dart';

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
  static Map<String, String> defaultHeaders = {"Content-Type": "application/json;charset=UTF-8", "Accept": "application/json"};

  /// Default parameters for HTTP requests.
  static Map<String, dynamic> defaultParams = {};

  /// Callbacks that can be assigned to handle different states of the HTTP request.
  static Function? onBeforeSend, onAfterSend, onException, onTimeout;

  /// Main function to make an HTTP request and return a `GenericResponse`.
  static Future<GenericResponse<T>> makeRequest<T>(String url, String path, HttpRequestMethod httpRequestMethod, T Function(dynamic response) converter,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      onBeforeSend?.call(); // Call onBeforeSend if it's not null

      // Merge default and custom parameters and headers
      final params = {...defaultParams, ...?queryParameters};
      final header = {...defaultHeaders, ...?headers};

      if (httpRequestMethod == HttpRequestMethod.get) header.remove("Content-Type"); // "Content-Type" is removed for GET requests

      // Construct the URI for the request
      final uri = Uri.https(url, path, params.isEmpty ? null : params);

      // Make the HTTP request based on the specified method
      final response = await _httpRequest(httpRequestMethod, uri, header);

      onAfterSend?.call(); // Call onAfterSend if it's not null
      return _handleResponse(response, converter); // Handle the HTTP response
    } on Exception catch (e) {
      onException?.call(); // Call onException if it's not null
      return httpExceptionError<T>(e); // Handle exception during HTTP request
    }
  }

  /// Makes an HTTP request based on the provided method, uri, and headers.
  static Future<Response> _httpRequest(HttpRequestMethod method, Uri uri, Map<String, String> headers) {
    switch (method) {
      // Each HTTP method corresponds to an HTTP request
      case HttpRequestMethod.get:
        return get(uri, headers: headers).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
      case HttpRequestMethod.post:
        return post(uri, headers: headers).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
      case HttpRequestMethod.put:
        return put(uri, headers: headers).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
      case HttpRequestMethod.patch:
        return patch(uri, headers: headers).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
      case HttpRequestMethod.delete:
        return delete(uri, headers: headers).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
    }
  }

  /// Handles the HTTP response and converts it into a `GenericResponse`.
  static GenericResponse<T> _handleResponse<T>(Response response, T Function(dynamic response) converter) {
    var body = const Utf8Decoder().convert(response.bodyBytes);
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      // Handle successful HTTP response
      dynamic nullableJson;
      try {
        nullableJson = jsonDecode(body);
      } catch (_) {
        print(body);
      }
      return GenericResponse(
        data: converter(nullableJson),
        statusCode: response.statusCode,
      );
    } else {
      // Handle non-successful HTTP response
      var message = response.bodyBytes.isEmpty ? "No message provided" : jsonDecode(body);
      return GenericResponse(
        // If status code is 999, it means there was a timeout
        error: response.statusCode == 999 ? HttpError(message: "Timeout Error") : HttpError.fromJson(message),
        statusCode: response.statusCode,
      );
    }
  }

  /// Handles the HTTP timeout error by returning a `Response` with a custom status code.
  static FutureOr<Response> httpTimeoutError() {
    onTimeout?.call(); // Call onTimeout if it's not null
    return Response("", 999); // Return custom response for timeout
  }

  /// Handles a caught exception during HTTP request by returning a `GenericResponse` with an `HttpError`.
  static Future<GenericResponse<T>> httpExceptionError<T>(Exception e) {
    // Return a GenericResponse with an HttpError containing the exception message
    return Future<GenericResponse<T>>.value(GenericResponse<T>(error: HttpError(message: "Http exception:\n${e.toString()}"), statusCode: -1));
  }
}
