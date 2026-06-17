import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../models/popup_ad.dart';

class PopupAdsService {
  final _col = FirebaseFirestore.instance.collection(AppConfig.colPopupAds);
  final _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  Stream<List<PopupAd>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(PopupAd.fromFirestore).toList());

  Future<List<PopupAd>> getAll() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map(PopupAd.fromFirestore).toList();
  }

  Future<PopupAd?> getById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return PopupAd.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }

  /// Creates a new popup document and returns its generated ID.
  Future<String> create(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['totalImpressions'] = 0;
    data['totalClicks'] = 0;
    data['totalDismissed'] = 0;
    final ref = await _col.add(data);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _col.doc(id).update(data);
  }

  Future<void> delete(String id) async {
    // Remove image from Storage before deleting document
    try {
      final doc = await _col.doc(id).get();
      final imageUrl = (doc.data() as Map?)?.containsKey('imageUrl') == true
          ? doc['imageUrl'] as String?
          : null;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _deleteStorageUrl(imageUrl);
      }
    } catch (_) {}
    await _col.doc(id).delete();
  }

  Future<void> setActive(String id, {required bool active}) async {
    await _col.doc(id).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Uploads [bytes] to Storage and returns the download URL.
  /// If [oldUrl] is provided and differs from the new file, the old one is deleted.
  Future<String> uploadImage(Uint8List bytes, {String? oldUrl}) async {
    final name = '${_uuid.v4()}.jpg';
    final ref = _storage.ref('${AppConfig.storagePopupAds}/$name');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    if (oldUrl != null && oldUrl.isNotEmpty) {
      await _deleteStorageUrl(oldUrl);
    }
    return url;
  }

  Future<void> _deleteStorageUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }

  /// Duplicates a popup document (resets stats and deactivates the copy).
  Future<String> duplicate(PopupAd original) async {
    final data = original.toMap()
      ..addAll({
        'title': '${original.title} (copia)',
        'active': false,
        'totalImpressions': 0,
        'totalClicks': 0,
        'totalDismissed': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    final ref = await _col.add(data);
    return ref.id;
  }
}
