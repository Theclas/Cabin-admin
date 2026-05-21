import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final _service = DashboardService();

  Map<String, dynamic> _kpis = {};
  List<Map<String, dynamic>> _recentPlaces = [];
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _topRated = [];
  List<Map<String, dynamic>> _byState = [];
  bool _loading = false;
  String? _error;

  Map<String, dynamic> get kpis => _kpis;
  List<Map<String, dynamic>> get recentPlaces => _recentPlaces;
  List<Map<String, dynamic>> get recentUsers => _recentUsers;
  List<Map<String, dynamic>> get topRated => _topRated;
  List<Map<String, dynamic>> get byState => _byState;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getKpis(),
        _service.getRecentPlaces(),
        _service.getRecentUsers(),
        _service.getTopRatedPlaces(),
        _service.getPlacesByState(),
      ]);
      _kpis = results[0] as Map<String, dynamic>;
      _recentPlaces = results[1] as List<Map<String, dynamic>>;
      _recentUsers = results[2] as List<Map<String, dynamic>>;
      _topRated = results[3] as List<Map<String, dynamic>>;
      _byState = results[4] as List<Map<String, dynamic>>;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
