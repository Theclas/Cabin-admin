import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class DashboardService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getKpis() async {
    final results = await Future.wait([
      _db.collection(AppConfig.colPlaces).count().get(),
      _db.collection(AppConfig.colUsers).count().get(),
      _db.collection(AppConfig.colReviews).count().get(),
      _db.collection(AppConfig.colReports)
          .where('status', isEqualTo: 'pending')
          .count()
          .get(),
    ]);

    return {
      'totalPlaces': results[0].count ?? 0,
      'totalUsers': results[1].count ?? 0,
      'totalReviews': results[2].count ?? 0,
      'pendingReports': results[3].count ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentPlaces({int limit = 5}) async {
    final snap = await _db.collection(AppConfig.colPlaces).limit(limit * 3).get();
    final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    docs.sort((a, b) {
      final aTs = a['createdAt'];
      final bTs = b['createdAt'];
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return (bTs as dynamic).compareTo(aTs);
    });
    return docs.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) async {
    final snap = await _db.collection(AppConfig.colUsers).limit(limit * 3).get();
    final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    docs.sort((a, b) {
      final aTs = a['createdAt'];
      final bTs = b['createdAt'];
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return (bTs as dynamic).compareTo(aTs);
    });
    return docs.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> getTopRatedPlaces({int limit = 5}) async {
    final snap = await _db
        .collection(AppConfig.colPlaces)
        .where('isActive', isEqualTo: true)
        .get();
    final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    docs.sort((a, b) {
      final aR = (a['rating'] as num?)?.toDouble() ?? 0;
      final bR = (b['rating'] as num?)?.toDouble() ?? 0;
      return bR.compareTo(aR);
    });
    return docs.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> getPlacesByState() async {
    final snap = await _db
        .collection(AppConfig.colPlaces)
        .where('isActive', isEqualTo: true)
        .get();
    final counts = <String, int>{};
    for (final doc in snap.docs) {
      final state = doc.data()['state'] as String? ?? 'Sin estado';
      counts[state] = (counts[state] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => {'state': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }
}
