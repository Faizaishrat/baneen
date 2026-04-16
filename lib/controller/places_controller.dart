import 'package:flutter/material.dart';
import '../services/places/places_service.dart';

export '../services/places/places_service.dart' show PlaceSuggestion;

/// Handles Places (Google) API via Provider: autocomplete suggestions and place details.
class PlacesProvider with ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  bool _isLoadingSuggestions = false;
  String? _errorMessage;
  List<PlaceSuggestion> _pickupSuggestions = [];
  List<PlaceSuggestion> _destinationSuggestions = [];

  bool get isLoadingSuggestions => _isLoadingSuggestions;
  String? get errorMessage => _errorMessage;
  List<PlaceSuggestion> get pickupSuggestions => List.unmodifiable(_pickupSuggestions);
  List<PlaceSuggestion> get destinationSuggestions => List.unmodifiable(_destinationSuggestions);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearPickupSuggestions() {
    _pickupSuggestions = [];
    notifyListeners();
  }

  void clearDestinationSuggestions() {
    _destinationSuggestions = [];
    notifyListeners();
  }

  /// Fetch place suggestions for pickup field (country-filtered).
  Future<void> fetchPickupSuggestions(String input) async {
    if (input.trim().length < 2) {
      _pickupSuggestions = [];
      _destinationSuggestions = [];
      notifyListeners();
      return;
    }
    _isLoadingSuggestions = true;
    _errorMessage = null;
    _destinationSuggestions = [];
    notifyListeners();
    try {
      _pickupSuggestions = await _placesService.getSuggestions(input);
      _isLoadingSuggestions = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _pickupSuggestions = [];
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  /// Fetch place suggestions for destination field (country-filtered).
  Future<void> fetchDestinationSuggestions(String input) async {
    if (input.trim().length < 2) {
      _destinationSuggestions = [];
      _pickupSuggestions = [];
      notifyListeners();
      return;
    }
    _isLoadingSuggestions = true;
    _errorMessage = null;
    _pickupSuggestions = [];
    notifyListeners();
    try {
      _destinationSuggestions = await _placesService.getSuggestions(input);
      _isLoadingSuggestions = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _destinationSuggestions = [];
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  /// Get lat/lng for a place_id (e.g. for distance/estimate).
  Future<Map<String, double>?> getLatLng(String placeId) async {
    try {
      return await _placesService.getLatLng(placeId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
