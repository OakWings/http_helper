# http_helper

The `http_helper` is a powerful yet easy-to-use HTTP networking library for Dart, designed to encapsulate the complexities of making HTTP requests in client applications. 

This library provides a set of high-level API functions to send HTTP requests and receive responses. It wraps around the lower-level functionality of the `http` library, providing a simplified and more user-friendly interface for developers.

Key Features:

1. **Simplified Request Methods:** The package provides a simple way to send HTTP requests with any HTTP method (GET, POST, PUT, PATCH, DELETE).

2. **HTTP Error Handling:** The `http_helper` is equipped with comprehensive error handling features to catch and handle HTTP errors effectively.

3. **Timeouts:** The library includes built-in HTTP request timeout functionality to prevent requests from hanging indefinitely.

4. **Callbacks:** It offers callback functions that can be set to handle different stages of an HTTP request. 

5. **Default Headers and Parameters:** The library supports setting of default headers and parameters for HTTP requests, providing more convenience for developers who need to make many similar requests.

6. **Flexible Response Handling:** The library allows users to specify how to convert HTTP responses to their desired data format.

The `http_helper` is ideal for Dart developers who want to simplify their HTTP networking code while retaining full control over the request and response handling.

Whether you're building a large-scale client application, or you just need to make a few HTTP requests in a small project, the `http_helper` can help streamline your networking code and make your development process smoother and more efficient.

# Examples:

## Example 1: GET Request with an objects as response
```dart
import 'package:http_helper/http_helper.dart';

import 'typicode_model.dart';

void main() async {
  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts/1';

  // Make a GET request
  var response = await HttpHelper.makeRequest<TypicodeModel>(
    url,
    path,
    HttpRequestMethod.get,
    (response) => TypicodeModel.fromJson(response),
  );

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data.toString());
  } else {
    // Note: when not response.isSuccess, error and message will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 2: GET Request with a list of objects as response
```dart
import 'package:http_helper/http_helper.dart';

import 'typicode_model.dart';

void main() async {
  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';

  // Make a GET request
  var response = await HttpHelper.makeRequest<List<TypicodeModel>>(
      url, path, HttpRequestMethod.get, (response) {
    var responseList = response as List;
    var mappedList = responseList
        .map((e) => e == null
            ? null
            : TypicodeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    var withoutNulls =
        List<TypicodeModel>.from(mappedList.where((e) => e != null));
    return withoutNulls;
  });

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data);
  } else {
    // Note: when not response.isSuccess, error and message will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 2: POST Request with Headers and Query Parameters
```dart
import 'package:http_helper/http_helper.dart';

import 'typicode_model.dart';

void main() async {
// Define the URL, path, headers and query parameters
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';
  Map<String, String> headers = {"Authorization": "Bearer your_token_here"};
  Map<String, dynamic> queryParams = {
    "userId": 1,
    "title": "Test Title",
    "body": "Test Body"
  };

// Make a POST request
  var response = await HttpHelper.makeRequest<TypicodeModel>(url, path,
      HttpRequestMethod.post, (response) => TypicodeModel.fromJson(response),
      headers: headers, queryParameters: queryParams);

  print(response.statusCode);

// Print the response data
  if (response.isSuccess) {
    print(response.data);
  } else {
    // Note: when not response.isSuccess, error and message will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}

```

## Example 3: Using Callbacks
```dart
import 'package:http_helper/http_helper.dart';

import 'typicode_model.dart';

void main() async {
  HttpHelper.defaultHeaders = {"App-Language": "en"};
  HttpHelper.timeoutDurationSeconds = 5;

  // Set callback functions
  HttpHelper.onBeforeSend = () {
    print("Request is about to be sent");
  };

  HttpHelper.onAfterSend = (GenericResponse response) {
    print("Request has been sent, received response: ${response.statusCode}");
  };

  HttpHelper.onException = (Exception e) {
    print("An exception occurred: ${e.toString()}");
  };

  HttpHelper.onTimeout = () {
    print("Request timed out");
  };

  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';

  // Make a GET request
  var response = await HttpHelper.makeRequest<List<TypicodeModel>>(
      url, path, HttpRequestMethod.get, (response) {
    var responseList = response as List;
    var mappedList = responseList
        .map((e) => e == null
            ? null
            : TypicodeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    var withoutNulls =
        List<TypicodeModel>.from(mappedList.where((e) => e != null));
    return withoutNulls;
  });

  // Print the response data
  if (response.isSuccess) {
    print(response.data);
  } else {
    // Note: when not response.isSuccess, error and message will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```