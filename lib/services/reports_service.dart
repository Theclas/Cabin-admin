import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/report.dart';

class ReportsService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colReports);

  Stream<List<Report>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Report.fromFirestore).toList());

  Future<List<Report>> getPending() async {
    final snap = await _col.where('status', isEqualTo: 'pending').get();
    return snap.docs.map(Report.fromFirestore).toList();
  }

  Future<void> resolve(String id, String adminId, String resolution) =>
      _col.doc(id).update({
        'status': ReportStatus.resolved.name,
        'resolvedBy': adminId,
        'resolution': resolution,
        'resolvedAt': Timestamp.now(),
      });

  Future<void> dismiss(String id, String adminId) =>
      _col.doc(id).update({
        'status': ReportStatus.dismissed.name,
        'resolvedBy': adminId,
        'resolvedAt': Timestamp.now(),
      });

  Future<void> setReviewing(String id) =>
      _col.doc(id).update({'status': ReportStatus.reviewing.name});

  Future<Map<String, int>> getStats() async {
    final all = await _col.get();
    int pending = 0, reviewing = 0, resolved = 0, dismissed = 0;
    for (final doc in all.docs) {
      final status = doc.data()['status'];
      if (status == 'pending') pending++;
      else if (status == 'reviewing') reviewing++;
      else if (status == 'resolved') resolved++;
      else if (status == 'dismissed') dismissed++;
    }
    return {
      'total': all.size,
      'pending': pending,
      'reviewing': reviewing,
      'resolved': resolved,
      'dismissed': dismissed,
    };
  }
}
