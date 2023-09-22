import 'package:http_helper/http_helper.dart';

import 'typicode_model_example.dart';

void main() async {
  HttpHelper.defaultHeaders = {"App-Language": "en"};
  HttpHelper.timeoutDurationSeconds = 5;

  // Set middleware functions
  HttpHelper.onBeforeSend = () {
    // Perform any pre-send logic here
    print("Request is about to be sent");
    // Return an HttpError here if your pre-send logic determined that the request should not be sent
    return null;
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
  var response = await HttpHelper.sendRequest<List<TypicodeModel>>(
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
    // Note: when `response.isSuccess` is false, `error` and `message` will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
