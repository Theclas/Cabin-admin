import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/review.dart';

class ReviewsService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colReviews);

  Stream<List<Review>> watchAll() => _col
      .snapshots()
      .map((s) => s.docs.map(Review.fromFirestore).toList());

  Future<List<Review>> getAll() async {
    final snap = await _col.get();
    final reviews = snap.docs.map(Review.fromFirestore).toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  Future<List<Review>> getFlagged() async {
    final snap = await _col.where('isFlagged', isEqualTo: true).get();
    return snap.docs.map(Review.fromFirestore).toList();
  }

  Future<void> setVisible(String id, bool visible) =>
      _col.doc(id).update({'isVisible': visible});

  Future<void> flag(String id, bool flagged) =>
      _col.doc(id).update({'isFlagged': flagged});

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<Map<String, int>> getStats() async {
    final all = await _col.get();
    int visible = 0, flagged = 0, hidden = 0;
    for (final doc in all.docs) {
      final d = doc.data();
      if (d['isVisible'] == true) visible++;
      else hidden++;
      if (d['isFlagged'] == true) flagged++;
    }
    return {'total': all.size, 'visible': visible, 'hidden': hidden, 'flagged': flagged};
  }
}
