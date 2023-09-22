## 1.0.7

- GET requests are not allowed to have a body; therefore an info will now be printed to the console to inform the user.
- A malformed response will now return a httpExceptionError instead of thwrowing an exception, making sure the app does not crash
- 'onBeforeSend' can now return an HttpError which will be returned by sendRequest for more details see 'onBeforeSend'

## 1.0.6

- Added an optional body parameter to 'sendRequest'

## 1.0.5

- Renamed `makeRequest` to `sendRequest`

## 1.0.4

- Renamed the file typicode_model.dart to typicode_model_example.dart to ensure it is displayed in the examples tab on pub.dev.

## 1.0.3

- Fixed a bug that caused an exception to be thrown when using integers in query parameters.
- Fixed a bug where `error.message` was null, despite it should never happen.
- Updated the example.
- Updated the examples in the readme.

## 1.0.2

- All 2xx status codes will now be treated as successful.

## 1.0.1

- Updated the package description to meet the required 60 to 180 character length requirement.
- Formatted the code with the Dart formatter to comply with the requirements of the pub.dev analyzer.

## 1.0.0

- Initial version.
