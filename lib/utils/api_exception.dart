class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return statusCode != null
        ? 'ApiException: $message (Status Code: $statusCode)'
        : 'ApiException: $message';
  }
}
