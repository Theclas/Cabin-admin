import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  Map<String, dynamic>? _userData;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String? get error => _error;
  String get displayName => _userData?['displayName'] ?? _user?.displayName ?? 'Admin';
  String get email => _user?.email ?? '';
  String get role => _userData?['role'] ?? 'user';
  bool get isSuperAdmin => role == AppConfig.roleSuperAdmin;

  AuthProvider() {
    _service.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _userData = null;
    } else {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppConfig.colUsers)
            .doc(user.uid)
            .get();
        _userData = doc.data();
        final userRole = _userData?['role'] ?? 'user';
        if (AppConfig.adminRoles.contains(userRole)) {
          _status = AuthStatus.authenticated;
        } else {
          await _service.signOut();
          _status = AuthStatus.unauthenticated;
          _error = 'Sin permisos de administrador';
        }
      } catch (_) {
        _status = AuthStatus.authenticated;
      }
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    _error = null;
    notifyListeners();
    final err = await _service.signIn(email, password);
    if (err != null) {
      _error = err;
      notifyListeners();
    }
    return err;
  }

  Future<void> signOut() => _service.signOut();
}
