import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';
import '../models/place.dart';

class PlacesService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colPlaces);

  Stream<List<Place>> watchAll() => _col
      .snapshots()
      .map((s) => s.docs.map(Place.fromFirestore).toList());

  Future<List<Place>> getAll() async {
    final snap = await _col.get();
    final places = snap.docs.map(Place.fromFirestore).toList();
    places.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return places;
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
    // Lo creado desde el admin nace aprobado (su flujo no cambia).
    data['status'] ??= 'approved';
    data['source'] ??= 'admin';
    final ref = await _col.add(data);
    return ref.id;
  }

  /// Stream en tiempo real de los lugares enviados por usuarios (status='pending'),
  /// ordenados por fecha de envío (más recientes primero). Orden en cliente para
  /// no requerir índice compuesto.
  Stream<List<Place>> watchPending() => _col
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) {
        final list = s.docs.map(Place.fromFirestore).toList();
        list.sort((a, b) => (b.submittedAt ?? b.createdAt)
            .compareTo(a.submittedAt ?? a.createdAt));
        return list;
      });

  /// Conteo en vivo de pendientes (para el badge del sidebar).
  Stream<int> pendingCount() =>
      _col.where('status', isEqualTo: 'pending').snapshots().map((s) => s.size);

  /// Aprueba un lugar: pasa a 'approved' y se vuelve visible (isActive=true).
  Future<void> approve(String id, String reviewerUid) =>
      _col.doc(id).update({
        'status': 'approved',
        'isActive': true,
        'active': true,
        'reviewedBy': reviewerUid,
        'reviewedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

  /// Rechaza un lugar: queda 'rejected' y oculto (isActive=false), con motivo.
  Future<void> reject(String id, String reviewerUid, String reason) =>
      _col.doc(id).update({
        'status': 'rejected',
        'isActive': false,
        'active': false,
        'reviewedBy': reviewerUid,
        'reviewedAt': Timestamp.now(),
        'rejectionReason': reason,
        'updatedAt': Timestamp.now(),
      });

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
