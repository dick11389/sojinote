class ApiConstants {
  // Bible API
  static const String bibleApiBaseUrl = 'https://bible-api.com';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Error Messages
  static const String noInternetError = 'No internet connection. Please check your network.';
  static const String serverError = 'Server error. Please try again later.';
  static const String verseNotFoundError = 'Bible verse not found. Please check the reference.';
  static const String timeoutError = 'Connection timeout. Please try again.';
  static const String unknownError = 'An unknown error occurred.';
}
