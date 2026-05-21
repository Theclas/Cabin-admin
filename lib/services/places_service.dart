import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/place.dart';

class PlacesService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colPlaces);

  Stream<List<Place>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Place.fromFirestore).toList());

  Future<List<Place>> getAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map(Place.fromFirestore).toList();
  }

  Future<Place?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Place.fromFirestore(doc);
  }

  Future<String> create(Map<String, dynamic> data) async {
    data['createdAt'] = Timestamp.now();
    data['updatedAt'] = Timestamp.now();
    data['rating'] = 0.0;
    data['reviewCount'] = 0;
    final ref = await _col.add(data);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _col.doc(id).update(data);
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> setActive(String id, bool active) =>
      _col.doc(id).update({'isActive': active, 'updatedAt': Timestamp.now()});

  Future<void> setFeatured(String id, bool featured) =>
      _col.doc(id).update({'isFeatured': featured, 'updatedAt': Timestamp.now()});

  Future<Map<String, int>> getStats() async {
    final all = await _col.get();
    int active = 0, inactive = 0, featured = 0;
    for (final doc in all.docs) {
      final d = doc.data();
      if (d['isActive'] == true) active++;
      else inactive++;
      if (d['isFeatured'] == true) featured++;
    }
    return {'total': all.size, 'active': active, 'inactive': inactive, 'featured': featured};
  }
}
