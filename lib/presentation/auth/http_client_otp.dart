import 'package:http/http.dart' as http;

/// Singleton http.Client to preserve cookies / session across requests
class PersistentHttpClient {
  static final http.Client _client = http.Client();

  static http.Client get instance => _client;

  /// Optional: call this when app is fully closing (rarely needed)
  static void close() {
    _client.close();
  }
}