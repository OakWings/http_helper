import 'package:http_helper/http_helper.dart';

import 'typicode_model_example.dart';

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
  var response = await HttpHelper.sendRequest<TypicodeModel>(url, path,
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
