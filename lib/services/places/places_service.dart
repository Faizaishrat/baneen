import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Place suggestion from Google Places Autocomplete.
class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion({required this.description, required this.placeId});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      description: json['description'] as String? ?? '',
      placeId: json['place_id'] as String? ?? '',
    );
  }
}

/// Google Places Autocomplete and details.
class PlacesService {
  static const _autocompleteBase =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _detailsBase =
      'https://maps.googleapis.com/maps/api/place/details/json';

  /// Fetch place suggestions for user input (e.g. "New Katarian").
  /// Uses country filter from [AppConstants.placesCountryCode].
  Future<List<PlaceSuggestion>> getSuggestions(String input) async {
    if (input.trim().isEmpty) return [];
    final query = {
      'input': input.trim(),
      'key': AppConstants.googlePlacesApiKey,
      'components': 'country:${AppConstants.placesCountryCode}',
    };
    final uri = Uri.parse(_autocompleteBase).replace(queryParameters: query);
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>?;
    final predictions = data?['predictions'] as List<dynamic>?;
    if (predictions == null) return [];
    return predictions
        .map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get lat/lng for a place_id (optional; use for distance/estimate).
  Future<Map<String, double>?> getLatLng(String placeId) async {
    final query = {
      'place_id': placeId,
      'fields': 'geometry',
      'key': AppConstants.googlePlacesApiKey,
    };
    final uri = Uri.parse(_detailsBase).replace(queryParameters: query);
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>?;
    final location = data?['result']?['geometry']?['location'];
    if (location == null) return null;
    return {
      'latitude': (location['lat'] as num).toDouble(),
      'longitude': (location['lng'] as num).toDouble(),
    };
  }
}
