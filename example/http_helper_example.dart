import 'package:http_helper/http_helper.dart';

import 'typicode_model_example.dart';

void main() async {
// Define the URL, path, headers and query parameters
  String url = 'jsonplaceholder.typicode.com';
  String path = '/posts/1';

// Define the body
  final body = """
    {
      "userId": 1,
      "id": 101,
      "title": "foo",
      "body": "bar"
    }
  """;

// Make a POST request
  var response = await HttpHelper.sendRequest<TypicodeModel>(
    url,
    path,
    HttpRequestMethod.put,
    (response) => TypicodeModel.fromJson(response),
    body: body,
  );

  print(response.statusCode);

// Print the response data
  if (response.isSuccess) {
    print(response.data);
  } else {
    // Note: when not response.isSuccess, error and message will never be null, so it is save to access them!
    print(response.error!.message!);
  }
}
