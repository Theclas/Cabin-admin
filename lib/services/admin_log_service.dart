import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class AdminLogService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colAdminLogs);

  Future<void> log({
    required String adminId,
    required String adminEmail,
    required String action,
    required String targetType,
    String? targetId,
    Map<String, dynamic>? details,
  }) =>
      _col.add({
        'adminId': adminId,
        'adminEmail': adminEmail,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'details': details ?? {},
        'createdAt': Timestamp.now(),
      });

  Future<List<Map<String, dynamic>>> getRecent({int limit = 50}) async {
    final snap = await _col.orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
