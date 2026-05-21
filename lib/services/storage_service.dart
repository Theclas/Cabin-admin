import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  Future<String> uploadBytes(Uint8List bytes, String folder, String ext) async {
    final name = '${_uuid.v4()}.$ext';
    final ref = _storage.ref('$folder/$name');
    final meta = SettableMetadata(contentType: _mimeType(ext));
    await ref.putData(bytes, meta);
    return await ref.getDownloadURL();
  }

  Future<void> deleteUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }

  Future<List<String>> uploadMultiple(
      List<Uint8List> files, String folder, String ext) async {
    final futures = files.map((b) => uploadBytes(b, folder, ext));
    return await Future.wait(futures);
  }

  String _mimeType(String ext) => switch (ext.toLowerCase()) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'application/octet-stream',
      };
}
