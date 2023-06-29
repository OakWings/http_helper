import 'package:json_annotation/json_annotation.dart';

part 'typicode_model.g.dart';

// We use the package json_serializable and json_annotation here to make it easier to serialize and deserialize json objects.
// To generate the outputs, run: `dart run build_runner build --delete-conflicting-outputs`.
// In this case, a 'typicode_model.g.dart' file will be generated.

// // See: https://jsonplaceholder.typicode.com/ for more informations about the free fake API for testing and prototyping
@JsonSerializable()
class TypicodeModel {
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

  // Creates a new instance of an `TypicodeModel`.
  //
  // See: https://jsonplaceholder.typicode.com/ for more informations
  TypicodeModel(this.userId, this.id, this.title, this.body);

  // Creates a new instance of `HttpError` from a map.
  //
  // This factory constructor allows for the creation of an `HttpError`
  // instance from a JSON map. This is useful when receiving an HTTP
  // error in the form of JSON from an API.
  factory TypicodeModel.fromJson(Map<String, dynamic> json) =>
      _$TypicodeModelFromJson(json);

  // Converts the `TypicodeModel` instance to a map.
  //
  // This method serializes the `TypicodeModel` instance into a JSON map,
  // which can be useful when sending HTTP errors to an API in the
  // form of JSON.
  Map<String, dynamic> toJson() => _$TypicodeModelToJson(this);

  // Let's provide a toString method so we can debug it better.
  @override
  String toString() {
    return 'TypicodeModel(\n  userId: $userId, \n  id: $id, \n  title: $title, \n  body: $body)';
  }
}
