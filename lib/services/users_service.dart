import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/app_user.dart';

class UsersService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colUsers);

  Stream<List<AppUser>> watchAll() => _col
      .snapshots()
      .map((s) => s.docs.map(AppUser.fromFirestore).toList());

  Future<List<AppUser>> getAll() async {
    final snap = await _col.get();
    final users = snap.docs.map(AppUser.fromFirestore).toList();
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  Future<AppUser?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> setRole(String uid, String role) =>
      _col.doc(uid).update({'role': role});

  Future<void> setActive(String uid, bool active) =>
      _col.doc(uid).update({'isActive': active});

  Future<void> ban(String uid, String reason) => _col.doc(uid).update({
        'isBanned': true,
        'isActive': false,
        'banReason': reason,
      });

  Future<void> unban(String uid) => _col.doc(uid).update({
        'isBanned': false,
        'isActive': true,
        'banReason': null,
      });

  Future<Map<String, int>> getStats() async {
    final all = await _col.get();
    int active = 0, banned = 0, admins = 0;
    for (final doc in all.docs) {
      final d = doc.data();
      if (d['isActive'] == true) active++;
      if (d['isBanned'] == true) banned++;
      if (AppConfig.adminRoles.contains(d['role'])) admins++;
    }
    return {'total': all.size, 'active': active, 'banned': banned, 'admins': admins};
  }
}
