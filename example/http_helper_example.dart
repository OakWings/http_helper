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
