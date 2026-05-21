import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser;
      if (user == null) return 'Error desconocido';
      final doc = await _db.collection(AppConfig.colUsers).doc(user.uid).get();
      if (!doc.exists) return 'Usuario no encontrado';
      final role = doc.data()?['role'] ?? 'user';
      if (!AppConfig.adminRoles.contains(role)) {
        await _auth.signOut();
        return 'No tienes permisos de administrador';
      }
      await _db.collection(AppConfig.colUsers).doc(user.uid).update({
        'lastLogin': Timestamp.now(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection(AppConfig.colUsers).doc(user.uid).get();
    return doc.data();
  }

  String _mapError(String code) {
    return switch (code) {
      'user-not-found' => 'Usuario no encontrado',
      'wrong-password' || 'invalid-credential' => 'Contraseña incorrecta',
      'invalid-email' => 'Email inválido',
      'user-disabled' => 'Cuenta deshabilitada',
      'too-many-requests' => 'Demasiados intentos. Intenta más tarde',
      _ => 'Error de autenticación',
    };
  }
}
