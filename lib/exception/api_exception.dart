class ApiException {
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    return 'ApiException{message: $message';
  }
}