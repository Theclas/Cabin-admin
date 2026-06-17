import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/places_service.dart';

enum LoadStatus { idle, loading, loaded, error }

class PlacesProvider extends ChangeNotifier {
  final _service = PlacesService();

  List<Place> _places = [];
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  String _search = '';
  String _filterState = '';
  bool? _filterActive;

  List<Place> get places => _filtered;
  LoadStatus get status => _status;
  String? get error => _error;
  String get search => _search;
  String get filterState => _filterState;
  bool? get filterActive => _filterActive;

  List<Place> get _filtered {
    // La lista normal "Lugares" solo muestra aprobados (los pending/rejected
    // viven en la sección "Pendientes"). Así no se rompe la vista existente.
    var list = _places.where((p) => p.status != 'pending' && p.status != 'rejected').toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.state.toLowerCase().contains(q)).toList();
    }
    if (_filterState.isNotEmpty) {
      list = list.where((p) => p.state == _filterState).toList();
    }
    if (_filterActive != null) {
      list = list.where((p) => p.isActive == _filterActive).toList();
    }
    return list;
  }

  void setSearch(String v) { _search = v; notifyListeners(); }
  void setFilterState(String v) { _filterState = v; notifyListeners(); }
  void setFilterActive(bool? v) { _filterActive = v; notifyListeners(); }
  void clearFilters() { _search = ''; _filterState = ''; _filterActive = null; notifyListeners(); }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _places = await _service.getAll();
      _status = LoadStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<String> create(Map<String, dynamic> data) async {
    final id = await _service.create(data);
    await load();
    return id;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _service.update(id, data);
    await load();
  }

  Future<void> delete(String id) async {
    await _service.delete(id);
    _places.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> setActive(String id, bool active) async {
    await _service.setActive(id, active);
    final idx = _places.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _places[idx] = _places[idx].copyWith(isActive: active);
      notifyListeners();
    }
  }

  Future<void> setFeatured(String id, bool featured) async {
    await _service.setFeatured(id, featured);
    final idx = _places.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _places[idx] = _places[idx].copyWith(isFeatured: featured);
      notifyListeners();
    }
  }
}
