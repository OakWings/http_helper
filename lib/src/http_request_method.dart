/// An enumeration representing the various HTTP request methods.
/// This enum provides a type-safe way to specify the HTTP method to be used
/// when making a request. It supports the common HTTP methods: GET, POST,
/// PUT, PATCH, and DELETE.
enum HttpRequestMethod {
  /// Represents the HTTP GET method.
  /// Typically used for retrieving resources without side effects. A Body is not allowed in GET requests
  get,

  /// Represents the HTTP POST method.
  /// Typically used for sending data to be processed to create a new resource.
  post,

  /// Represents the HTTP PUT method.
  /// Typically used for updating an existing resource with new data.
  put,

  /// Represents the HTTP PATCH method.
  /// Typically used for making partial updates to an existing resource.
  patch,

  /// Represents the HTTP DELETE method.
  /// Typically used for deleting a resource specified by a URL.
  delete,
}
