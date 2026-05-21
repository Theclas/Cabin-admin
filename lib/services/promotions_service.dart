import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/promotion.dart';

class PromotionsService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colPromotions);

  Stream<List<Promotion>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Promotion.fromFirestore).toList());

  Future<List<Promotion>> getActive() async {
    final snap = await _col.where('status', isEqualTo: 'active').get();
    return snap.docs.map(Promotion.fromFirestore).toList();
  }

  Future<String> create(Map<String, dynamic> data) async {
    data['createdAt'] = Timestamp.now();
    data['usageCount'] = 0;
    final ref = await _col.add(data);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> setStatus(String id, PromotionStatus status) =>
      _col.doc(id).update({'status': status.name});
}
