import 'package:json_annotation/json_annotation.dart';

part 'http_error.g.dart';

/// Represents an HTTP error.
///
/// This class provides a model for HTTP errors. It contains a message
/// that describes the error in detail.
///
/// The class includes methods for converting to and from JSON, making it
/// easier to serialize and deserialize the error when sending or
/// receiving HTTP requests.
@JsonSerializable()
class HttpError {
  /// A message that describes the HTTP error.
  String? message;

  /// Creates a new instance of an HTTP error.
  ///
  /// The `message` parameter is required, and it provides a description of the error.
  HttpError({required this.message});

  /// Creates a new instance of `HttpError` from a map.
  ///
  /// This factory constructor allows for the creation of an `HttpError`
  /// instance from a JSON map. This is useful when receiving an HTTP
  /// error in the form of JSON from an API.
  factory HttpError.fromJson(Map<String, dynamic> json) =>
      _$HttpErrorFromJson(json);

  /// Converts the `HttpError` instance to a map.
  ///
  /// This method serializes the `HttpError` instance into a JSON map,
  /// which can be useful when sending HTTP errors to an API in the
  /// form of JSON.
  Map<String, dynamic> toJson() => _$HttpErrorToJson(this);
}
