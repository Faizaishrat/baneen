// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class PersistentHttpClient {
//   PersistentHttpClient._privateConstructor();
//   static final PersistentHttpClient instance = PersistentHttpClient._privateConstructor();
//
//   Map<String, String> _cookies = {};
//
//   Future<http.Response> post(Uri uri, {Map<String, String>? headers, Object? body}) async {
//     final combinedHeaders = {...?headers};
//     if (_cookies.isNotEmpty) {
//       combinedHeaders['Cookie'] = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
//     }
//     final response = await http.post(uri, headers: combinedHeaders, body: body);
//     _saveCookies(response);
//     return response;
//   }
//
//   void _saveCookies(http.Response response) {
//     final rawCookies = response.headers['set-cookie'];
//     if (rawCookies != null) {
//       for (var cookie in rawCookies.split(',')) {
//         final split = cookie.split(';')[0].split('=');
//         if (split.length == 2) _cookies[split[0]] = split[1];
//       }
//     }
//   }
// }