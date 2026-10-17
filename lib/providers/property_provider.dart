import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/property_model.dart';

class PropertyProvider extends ChangeNotifier {
  final List<PropertyModel> _properties = seedProperties();
  final Set<String> _favoriteIds = {};

  // فلاتر البحث
  String _query = '';
  PropertyPurpose? _purposeFilter;
  PropertyCategory? _categoryFilter;

  List<PropertyModel> get all => List.unmodifiable(_properties);

  List<PropertyModel> get featured =>
      _properties.where((p) => p.isFeatured).toList();

  Set<String> get favoriteIds => _favoriteIds;

  List<PropertyModel> get favorites =>
      _properties.where((p) => _favoriteIds.contains(p.id)).toList();

  String get query => _query;
  PropertyPurpose? get purposeFilter => _purposeFilter;
  PropertyCategory? get categoryFilter => _categoryFilter;

  List<PropertyModel> get filtered {
    return _properties.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.title.contains(_query) ||
          p.location.contains(_query);
      final matchesPurpose = _purposeFilter == null || p.purpose == _purposeFilter;
      final matchesCategory = _categoryFilter == null || p.category == _categoryFilter;
      return matchesQuery && matchesPurpose && matchesCategory;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setPurposeFilter(PropertyPurpose? p) {
    _purposeFilter = p;
    notifyListeners();
  }

  void setCategoryFilter(PropertyCategory? c) {
    _categoryFilter = c;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _purposeFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  void addProperty(PropertyModel property) {
    _properties.insert(0, property);
    notifyListeners();
  }

  void removeProperty(String id) {
    _properties.removeWhere((p) => p.id == id);
    _favoriteIds.remove(id);
    notifyListeners();
  }

  void toggleFeatured(String id) {
    final p = _properties.firstWhere((p) => p.id == id);
    p.isFeatured = !p.isFeatured;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  List<PropertyModel> byOwner(String ownerId) =>
      _properties.where((p) => p.ownerId == ownerId).toList();
}
