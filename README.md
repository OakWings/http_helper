# http_helper

The `http_helper` is a powerful yet easy-to-use HTTP networking library for Dart, designed to encapsulate the complexities of making HTTP requests in client applications.

This library provides a set of high-level API functions to send HTTP requests and receive responses. It wraps around the lower-level functionality of the `http` library, providing a simplified and more user-friendly interface for developers.

Key Features:

1. **Simplified Request Methods:** The package provides a simple way to send HTTP requests with any HTTP method (GET, POST, PUT, PATCH, DELETE).

2. **HTTP Error Handling:** The `http_helper` is equipped with comprehensive error handling features to catch and handle HTTP errors effectively.

3. **Timeouts:** The library includes built-in HTTP request timeout functionality to prevent requests from hanging indefinitely.

4. **Callbacks/Middleware:** It offers callback/middleware functions that can be set to handle different stages of an HTTP request.

5. **Default Headers and Parameters:** The library supports setting of default headers and parameters for HTTP requests, providing more convenience for developers who need to make many similar requests.

6. **Flexible Response Handling:** The library allows users to specify how to convert HTTP responses to their desired data format.

The `http_helper` is ideal for Dart developers who want to simplify their HTTP networking code while retaining full control over the request and response handling.

Whether you're building a large-scale client application, or you just need to make a few HTTP requests in a small project, the `http_helper` can help streamline your networking code and make your development process smoother and more efficient.

# Examples:

## Example 1: GET Request with an object as response

```dart
import 'package:http_helper/http_helper.dart';

import 'my_model.dart';

void main() async {
  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts/1';

  // Define your converter that will be used to convert the response to a MyModel object
  myToJsonConverter(response) {
    return MyModel.fromJson(response);
  }

  // Define the get request
  final request = HttpRequest(
    url: url,
    path: path,
    method: HttpRequestMethod.get,
    converter: myToJsonConverter,
  );

  // Make the GET request
  var response = await HttpHelper.sendRequest<MyModel>(request);

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data.toString());
  } else {
    // Note: when `response.isSuccess` is false, `error` and `message` will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 2: GET Request with a list of objects as response

```dart
import 'package:http_helper/http_helper.dart';

import 'my_model.dart';

void main() async {
  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';

  // Define your converter that will be used to convert the response to a MyModel object
  myToJsonConverter(response) {
    var responseList = response as List;
    var mappedList = responseList
        .map((e) =>
            e == null ? null : MyModel.fromJson(e as Map<String, dynamic>))
        .toList();
    var withoutNulls = List<MyModel>.from(mappedList.where((e) => e != null));
    return withoutNulls;
  }

  // Define the get request
  final request = HttpRequest(
    url: url,
    path: path,
    method: HttpRequestMethod.get,
    converter: myToJsonConverter,
  );

  // Make the GET request
  var response = await HttpHelper.sendRequest<List<MyModel>>(request);

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data.toString());
  } else {
    // Note: when `response.isSuccess` is false, `error` and `message` will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 2: POST Request with Headers and Query Parameters

```dart
import 'package:http_helper/http_helper.dart';

import 'my_model.dart';

void main() async {
  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';

  Map<String, String> headers = {"Authorization": "Bearer your_token_here"};
  Map<String, dynamic> queryParams = {
    "userId": 1,
    "title": "Test Title",
    "body": "Test Body"
  };

  // Define your converter that will be used to convert the response to a MyModel object
  myToJsonConverter(response) {
    return MyModel.fromJson(response);
  }

  // Define the get request
  final request = HttpRequest(
    url: url,
    path: path,
    method: HttpRequestMethod.post,
    converter: myToJsonConverter,
    queryParameters: queryParams,
    headers: headers,
  );

  // Make the GET request
  var response = await HttpHelper.sendRequest<MyModel>(request);

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data.toString());
  } else {
    // Note: when `response.isSuccess` is false, `error` and `message` will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 3: POST Request with Body

```dart
import 'package:http_helper/http_helper.dart';

import 'my_model.dart';

void main() async {
  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';

  // Define the body
  final body = """
    {
      "userId": 1,
      "id": 10111,
      "title": "foo",
      "body": "bar"
    }
  """;

  // Define your converter that will be used to convert the response to a MyModel object
  myToJsonConverter(response) {
    return MyModel.fromJson(response);
  }

  // Define the get request
  final request = HttpRequest(
    url: url,
    path: path,
    method: HttpRequestMethod.post,
    converter: myToJsonConverter,
    body: body,
  );

  // Make the GET request
  var response = await HttpHelper.sendRequest<MyModel>(request);

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data.toString());
  } else {
    // Note: when `response.isSuccess` is false, `error` and `message` will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 4: Using Middleware to handle different stages of an HTTP request

```dart
import 'package:http_helper/http_helper.dart';

import 'my_model.dart';

void main() async {
  HttpHelper.defaultHeaders = {"App-Language": "en"};
  HttpHelper.timeoutDurationSeconds = 5;

  // Set middleware functions
  HttpHelper.onBeforeSend = (request) {
    // Perform any pre-send logic here
    print(
        "Request ${request.method.name.toUpperCase()} is about to be sent: ${request.url}${request.path}");
    // Return an HttpError here if your pre-send logic determined that the request should not be sent
    return null;
  };

  HttpHelper.onAfterSend = (request, response) {
    print("Request has been sent, received response: ${response.statusCode}");
  };

  HttpHelper.onException = (request, exception) {
    print("An exception occurred: ${exception.toString()}");
  };

  HttpHelper.onTimeout = (request) {
    print("Request ${request.method} timed out: ${request.url}${request.path}");
  };

  // Define the URL and path
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts';

  // Define your converter that will be used to convert the response to a MyModel object
  myToJsonConverter(response) {
    return MyModel.fromJson(response);
  }

  // Define the get request
  final request = HttpRequest(
    url: url,
    path: path,
    method: HttpRequestMethod.post,
    converter: myToJsonConverter,
  );

  // Make the GET request
  var response = await HttpHelper.sendRequest<MyModel>(request);

  print(response.statusCode);

  // Print the response data
  if (response.isSuccess) {
    print(response.data.toString());
  } else {
    // Note: when `response.isSuccess` is false, `error` and `message` will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
```

## Example 5: Using the middleware onBeforeSend to prevent users that are not logged in from entering the private area (fictional example)

```dart
import 'package:http_helper/http_helper.dart';

import 'typicode_model.dart';

void main() async {

  // Set middleware functions
  HttpHelper.onBeforeSend = (request) {
    if (!user.loggedIn) {
      // By returning an HttpError here, all 'sendRequest' calls will not send the request but will return this error if 'user.loggedIn' is false
      return HttpError(
        message: "You must be logged in to enter the private area",
      )
    }
    return null;
  };

  // Define the URL and path
  String url = 'accounts.example.com';
  String path = '/private';

  // Define your converter that will be used to convert the response to a MyModel object
  myToJsonConverter(response) {
    return UserPrivateDetails.fromJson(response);
  }

  // Define the get request
  final request = HttpRequest(
    url: url,
    path: path,
    method: HttpRequestMethod.get,
    converter: myToJsonConverter,
  );

  // Make a GET request
  final response = await HttpHelper.sendRequest<UserPrivateDetails>(request);

  // Print the response data
  if (response.isSuccess) {
    print(response.data);
  } else {
    // This will print the message defined in the HttpError above: 'You must be logged in to enter the private area'
    print(response.error!.message!);
  }
}
```
