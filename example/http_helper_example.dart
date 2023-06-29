import 'package:http_helper/http_helper.dart';

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
  String url = 'https://jsonplaceholder.typicode.com';
  String path = '/posts';

  // Make a GET request
  var response = await HttpHelper.makeRequest<Map<String, dynamic>>(
    url,
    path,
    HttpRequestMethod.get,
    (res) => res as Map<String, dynamic>,
  );

  // Print the response data
  print(response.data);
}
