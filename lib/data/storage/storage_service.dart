import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Upload de mídia do app (camada de dados).
abstract interface class StorageService {
  /// Sobe uma imagem e devolve a URL de download dela.
  Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double progress)? onProgress});
}

String _uuid() {
  final r = Random();
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final rand = List.generate(6, (_) => r.nextInt(16).toRadixString(16)).join();
  return '$ts$rand';
}

class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._storage);
  final FirebaseStorage _storage;

  @override
  Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double)? onProgress}) async {
    final safeExt = ext.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final useExt = safeExt.isEmpty ? 'jpg' : safeExt;
    final ref = _storage.ref('content_images/${_uuid()}.$useExt');
    final task = ref.putData(bytes, SettableMetadata(contentType: 'image/${useExt == 'jpg' ? 'jpeg' : useExt}'));
    if (onProgress != null) {
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0) onProgress(s.bytesTransferred / s.totalBytes);
      });
    }
    await task;
    return ref.getDownloadURL();
  }
}

class FakeStorageService implements StorageService {
  @override
  Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double)? onProgress}) async {
    onProgress?.call(1.0);
    return 'https://fake.storage/content_images/${_uuid()}.$ext';
  }
}
