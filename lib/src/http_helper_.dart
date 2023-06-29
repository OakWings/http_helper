import 'dart:async';
import 'dart:convert';

import 'package:http_helper/src/generic_response.dart';
import 'package:http_helper/src/http_error.dart';
import 'package:http/http.dart';

enum HttpRequestMethod_ {
  get,
  post,
  put,
  patch,
  delete,
}

class HttpHelper_ {
  static int timeoutDurationSeconds = 10;
  static Map<String, String> defaultHeaders = {"Content-Type": "application/json;charset=UTF-8", "Accept": "application/json"};
  static Map<String, dynamic> defaultParams = {};
  static Function? onBeforeSend;
  static Function? onAfterSend;
  static Function? onException;
  static Function? onTimeout;

  static Future<GenericResponse<T>> makeRequestMap<T>(String path, String url, HttpRequestMethod_ httpRequestMethod, T Function(Map<String, dynamic> response) converter,
      [Map<String, dynamic>? queryParameters, Map<String, String>? headers]) {
    return makeRequest(path, url, httpRequestMethod, queryParameters: queryParameters, headers: headers, (response) => converter(response as Map<String, dynamic>));
  }

  static Future<GenericResponse<T>> makeRequest<T>(String url, String path, HttpRequestMethod_ httpRequestMethod, T Function(dynamic response) converter,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      onBeforeSend?.call();

      Map<String, dynamic>? params = queryParameters != null ? {...defaultParams, ...queryParameters} : {...defaultParams};
      if (params.isEmpty) params = null;
      final header = headers != null ? {...defaultHeaders, ...headers} : {...defaultHeaders};

      if (httpRequestMethod == HttpRequestMethod_.get) {
        // in a get request, content type is not allowed when no body is present
        header.removeWhere((key, _) => key == "Content-Type");
      }

      final uri = Uri.https(url, path, params);

      Response response;

      switch (httpRequestMethod) {
        case HttpRequestMethod_.get:
          response = await get(uri, headers: header).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
        case HttpRequestMethod_.post:
          response = await post(uri, headers: header).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
        case HttpRequestMethod_.put:
          response = await put(uri, headers: header).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
        case HttpRequestMethod_.patch:
          response = await patch(uri, headers: header).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
        case HttpRequestMethod_.delete:
          response = await delete(uri, headers: header).timeout(Duration(seconds: timeoutDurationSeconds), onTimeout: httpTimeoutError);
      }

      onAfterSend?.call();
      return _handleResponse(response, converter);
    } on Exception catch (e) {
      onException?.call();
      return httpExceptionError<T>(e);
    }
  }

  static GenericResponse<T> _handleResponse<T>(Response response, T Function(dynamic response) converter) {
    var body = const Utf8Decoder().convert(response.bodyBytes);
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      if (T == bool) {
        dynamic nullableJson;
        try {
          nullableJson = jsonDecode(body);
        } catch (e) {
          print(body);
        }
        return GenericResponse(
          data: converter(nullableJson),
          statusCode: response.statusCode,
        );
      }
      GenericResponse<T> genResponseModel = GenericResponse(
        data: converter(jsonDecode(body)),
        statusCode: response.statusCode,
      );
      return genResponseModel;
    } else if (response.statusCode == 999) {
      GenericResponse<T> genResponseModel = GenericResponse(error: HttpError(message: "Timeout Error"), statusCode: response.statusCode);
      return genResponseModel;
    } else {
      GenericResponse<T> genResponseModel = GenericResponse(
          error: response.bodyBytes.isEmpty ? HttpError(message: "No message provided") : HttpError.fromJson(jsonDecode(body) as Map<String, dynamic>),
          statusCode: response.statusCode);

      // Make sure in both of the cases above, message is not null in an error case
      if (genResponseModel.error!.message == null) {
        genResponseModel.error!.message = "No message provided";
      }
      return genResponseModel;
    }
  }

  // Errors
  static FutureOr<Response> httpTimeoutError() {
    onTimeout?.call();
    return Response("", 999);
  }

  static Future<GenericResponse<T>> httpExceptionError<T>(Exception e) {
    return Future<GenericResponse<T>>.value(GenericResponse<T>(error: HttpError(message: "Http exception:\n${e.toString()}"), statusCode: -1));
  }
}
